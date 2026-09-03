-- ============================================================
-- Migration 0015: Billing and Insurance Integrity
-- HomeHub — lifecycle-safe subscription, gift, promo, and policy data
-- ============================================================

do $$
begin
  if exists (
    select 1 from public.subscriptions
    where current_period_start is not null
      and current_period_end is not null
      and current_period_end < current_period_start
  ) then raise exception 'subscriptions contains an invalid current billing period'; end if;

  if exists (
    select 1 from public.subscriptions
    where gifted_at is not null
      and gifted_expires_at is not null
      and gifted_expires_at < gifted_at
  ) then raise exception 'subscriptions contains an invalid gift period'; end if;

  if exists (
    select 1 from public.subscriptions
    where (not is_gifted and num_nonnulls(gifted_by, gifted_reason, gifted_at, gifted_expires_at) > 0)
       or (is_gifted and (gifted_by is null or gifted_at is null))
  ) then raise exception 'subscriptions contains contradictory gift state'; end if;

  if exists (
    select household_id from public.subscriptions
    where is_active
    group by household_id having count(*) > 1
  ) then raise exception 'subscriptions contains duplicate current household subscriptions'; end if;

  if exists (
    select 1 from public.promo_codes
    where redemption_count < 0
       or max_redemptions <= 0
       or (max_redemptions is not null and redemption_count > max_redemptions)
       or (expires_at is not null and expires_at < created_at)
       or (discount_pct is not null and (discount_pct <= 0 or discount_pct > 100))
  ) then raise exception 'promo_codes contains invalid usage, dates, or discount values'; end if;

  if exists (
    select 1 from public.insurance_policies
    where (effective_date is not null and expiry_date is not null and expiry_date < effective_date)
       or annual_premium < 0
       or coverage_amount < 0
       or deductible < 0
       or renewal_reminder_days < 0
  ) then raise exception 'insurance_policies contains invalid dates or numeric values'; end if;
end
$$;

-- Subscriptions are household-scoped plan periods. Provider billing periods
-- remain distinct from the HomeHub subscription lifecycle.
alter table public.subscriptions
  rename column gifted_by to gifted_by_profile_id;

alter table public.subscriptions
  rename constraint subscriptions_gifted_by_fkey
  to subscriptions_gifted_by_profile_id_fkey;

alter table public.subscriptions
  add column starts_at timestamptz,
  add column ends_at timestamptz,
  add column sponsor_organization_id uuid;

update public.subscriptions
set starts_at = coalesce(current_period_start, created_at),
    ends_at = case
      when is_active then null
      else coalesce(cancelled_at, current_period_end, created_at)
    end;

alter table public.subscriptions
  alter column starts_at set not null,
  alter column starts_at set default now(),
  drop constraint subscriptions_household_id_fkey,
  drop constraint subscriptions_gifted_by_profile_id_fkey,
  add constraint subscriptions_household_id_fkey
    foreign key (household_id) references public.households(id) on delete restrict,
  add constraint subscriptions_gifted_by_profile_id_fkey
    foreign key (gifted_by_profile_id) references public.profiles(id) on delete restrict,
  add constraint subscriptions_sponsor_organization_id_fkey
    foreign key (sponsor_organization_id) references public.organizations(id) on delete set null,
  add constraint subscriptions_lifecycle_check
    check (ends_at is null or ends_at >= starts_at),
  add constraint subscriptions_active_state_check
    check (is_active = (ends_at is null)),
  add constraint subscriptions_current_period_check
    check (current_period_end is null or current_period_start is null or current_period_end >= current_period_start),
  add constraint subscriptions_cancellation_timeline_check
    check (cancelled_at is null or cancelled_at >= starts_at),
  add constraint subscriptions_gift_state_check check (
    (not is_gifted
      and gifted_by_profile_id is null
      and sponsor_organization_id is null
      and gifted_reason is null
      and gifted_at is null
      and gifted_expires_at is null)
    or
    (is_gifted
      and gifted_by_profile_id is not null
      and gifted_at is not null
      and (gifted_reason is null or btrim(gifted_reason) <> '')
      and (gifted_expires_at is null or gifted_expires_at >= gifted_at))
  ),
  add constraint subscriptions_id_is_gifted_key unique (id, is_gifted);

create unique index subscriptions_one_current_household_idx
  on public.subscriptions(household_id)
  where ends_at is null;

create unique index subscriptions_stripe_customer_id_idx
  on public.subscriptions(stripe_customer_id)
  where stripe_customer_id is not null;

create unique index subscriptions_stripe_sub_id_idx
  on public.subscriptions(stripe_sub_id)
  where stripe_sub_id is not null;

comment on column public.subscriptions.starts_at is
  'Start of the HomeHub subscription lifecycle; distinct from a provider billing-period start.';
comment on column public.subscriptions.ends_at is
  'End of the HomeHub subscription lifecycle. Null denotes the single current household subscription.';
comment on column public.subscriptions.sponsor_organization_id is
  'Optional sponsoring entity. This is distinct from the human profile that initiated the gift.';
comment on column public.subscriptions.gifted_by_profile_id is
  'Human actor who initiated the gift. RESTRICT preserves the actor relationship and subscription history.';

create table public.subscription_gift_claims (
  id                       uuid primary key default uuid_generate_v4(),
  subscription_id          uuid not null,
  subscription_is_gifted   boolean not null default true,
  token_hash               text not null unique,
  intended_recipient_email citext,
  created_at               timestamptz not null default now(),
  expires_at               timestamptz not null,
  claimed_at               timestamptz,
  claimed_by_profile_id    uuid references public.profiles(id) on delete set null,
  revoked_at               timestamptz,
  revoked_by               uuid references public.profiles(id) on delete set null,
  revoke_reason            text,

  constraint subscription_gift_claims_gifted_subscription_check
    check (subscription_is_gifted),
  constraint subscription_gift_claims_subscription_fkey
    foreign key (subscription_id, subscription_is_gifted)
    references public.subscriptions(id, is_gifted) on update cascade on delete restrict,
  constraint subscription_gift_claims_token_hash_check
    check (token_hash ~ '^[0-9a-f]{64}$'),
  constraint subscription_gift_claims_expiration_check
    check (expires_at >= created_at),
  constraint subscription_gift_claims_claim_timeline_check
    check (claimed_at is null or claimed_at >= created_at),
  constraint subscription_gift_claims_revocation_timeline_check
    check (revoked_at is null or revoked_at >= created_at),
  constraint subscription_gift_claims_claimed_by_check
    check (claimed_by_profile_id is null or claimed_at is not null),
  constraint subscription_gift_claims_revoked_by_check
    check (revoked_by is null or revoked_at is not null),
  constraint subscription_gift_claims_revoke_reason_requires_revocation_check
    check (revoke_reason is null or revoked_at is not null),
  constraint subscription_gift_claims_revoke_reason_content_check
    check (revoke_reason is null or btrim(revoke_reason) <> ''),
  constraint subscription_gift_claims_claim_before_revocation_check
    check (claimed_at is null or revoked_at is null or revoked_at >= claimed_at)
);

create unique index subscription_gift_claims_one_open_idx
  on public.subscription_gift_claims(subscription_id)
  where claimed_at is null and revoked_at is null;

comment on table public.subscription_gift_claims is
  'Hashed claim credentials and lifecycle history for gifted subscriptions. A claim may be revoked after being claimed, preserving both historical events.';
comment on column public.subscription_gift_claims.token_hash is
  'SHA-256 digest of a high-entropy claim token generated and delivered outside SQL. Raw claim credentials are never persisted.';
comment on column public.subscription_gift_claims.subscription_is_gifted is
  'Declarative discriminator paired with subscriptions.is_gifted so claims cannot reference non-gifted subscriptions.';

alter table public.promo_codes
  drop constraint promo_codes_discount_pct_check,
  add constraint promo_codes_code_content_check
    check (btrim(code) <> ''),
  add constraint promo_codes_discount_pct_check
    check (discount_pct is null or (discount_pct > 0 and discount_pct <= 100)),
  add constraint promo_codes_max_redemptions_check
    check (max_redemptions is null or max_redemptions > 0),
  add constraint promo_codes_redemption_count_check
    check (redemption_count >= 0),
  add constraint promo_codes_redemption_limit_check
    check (max_redemptions is null or redemption_count <= max_redemptions),
  add constraint promo_codes_validity_check
    check (expires_at is null or expires_at >= created_at);

alter table public.insurance_policies
  add column insurer_organization_id uuid,
  add column agent_profile_id uuid,
  drop constraint insurance_policies_property_id_fkey,
  add constraint insurance_policies_property_id_fkey
    foreign key (property_id) references public.properties(id) on delete restrict,
  add constraint insurance_policies_insurer_organization_id_fkey
    foreign key (insurer_organization_id) references public.organizations(id) on delete set null,
  add constraint insurance_policies_agent_profile_id_fkey
    foreign key (agent_profile_id) references public.profiles(id) on delete set null,
  add constraint insurance_policies_date_order_check
    check (expiry_date is null or effective_date is null or expiry_date >= effective_date),
  add constraint insurance_policies_annual_premium_check
    check (annual_premium is null or annual_premium >= 0),
  add constraint insurance_policies_coverage_amount_check
    check (coverage_amount is null or coverage_amount >= 0),
  add constraint insurance_policies_deductible_check
    check (deductible is null or deductible >= 0),
  add constraint insurance_policies_renewal_reminder_days_check
    check (renewal_reminder_days >= 0);

create index idx_insurance_insurer_organization
  on public.insurance_policies(insurer_organization_id);
create index idx_insurance_agent_profile
  on public.insurance_policies(agent_profile_id);

comment on column public.insurance_policies.insurer_organization_id is
  'Optional business/entity association for the policy; not proof of carrier status, appointment, or licensure.';
comment on column public.insurance_policies.agent_profile_id is
  'Optional individual agent association; not proof of carrier appointment or licensure.';
