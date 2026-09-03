-- ============================================================
-- Migration 0011: Property Access and Ownership History
-- HomeHub — durable property access and recorded ownership periods
-- ============================================================

-- properties.household_id identifies the current household that organizes
-- and administers the HomeHub property record. It is not authoritative proof
-- of ownership and is not the sole source of application authorization.
comment on column public.properties.household_id is
  'Current organizing/administrative household for this HomeHub property record; not authoritative proof of ownership and not the sole authorization source.';

-- ── Durable property membership ───────────────────────────────

create type public.property_member_role as enum (
  'owner',
  'household_member',
  'caretaker',
  'property_manager',
  'viewer'
);

create table public.property_memberships (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete restrict,
  profile_id      uuid not null references public.profiles(id) on delete restrict,
  role            public.property_member_role not null,
  granted_by      uuid references public.profiles(id) on delete set null,
  invited_at      timestamptz,
  accepted_at     timestamptz,
  starts_at       timestamptz not null default now(),
  ends_at         timestamptz,
  ended_by        uuid references public.profiles(id) on delete set null,
  end_reason      text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  constraint property_memberships_acceptance_timeline_check
    check (accepted_at is null or invited_at is null or accepted_at >= invited_at),
  constraint property_memberships_end_timeline_check
    check (ends_at is null or ends_at >= starts_at),
  constraint property_memberships_ended_by_check
    check (ended_by is null or ends_at is not null),
  constraint property_memberships_end_reason_check
    check (end_reason is null or ends_at is not null)
);

create unique index property_memberships_one_current_membership_idx
  on public.property_memberships (property_id, profile_id)
  where ends_at is null;

create index property_memberships_current_profile_lookup_idx
  on public.property_memberships (profile_id, property_id)
  where ends_at is null;

create trigger trg_property_memberships_updated_at
  before update on public.property_memberships
  for each row execute function public.set_updated_at();

comment on table public.property_memberships is
  'Durable access to one HomeHub property. Household association, ownership history, and temporary grants are modeled separately.';
comment on column public.property_memberships.ends_at is
  'Null denotes the current membership period. Ended periods are retained as history.';

-- ── HomeHub-recorded ownership history ───────────────────────

create type public.property_ownership_type as enum (
  'owner',
  'co_owner',
  'trustee',
  'estate',
  'other'
);

create table public.property_ownership_periods (
  id                      uuid primary key default uuid_generate_v4(),
  property_id             uuid not null references public.properties(id) on delete restrict,
  owner_profile_id        uuid references public.profiles(id) on delete restrict,
  owner_household_id      uuid references public.households(id) on delete restrict,
  owner_organization_id   uuid references public.organizations(id) on delete restrict,
  ownership_type          public.property_ownership_type not null,
  ownership_percentage    numeric(5,2),
  starts_on               date not null,
  ends_on                 date,
  evidence_document_id    uuid,
  recorded_by             uuid references public.profiles(id) on delete set null,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now(),

  constraint property_ownership_periods_one_subject_check
    check (
      num_nonnulls(
        owner_profile_id,
        owner_household_id,
        owner_organization_id
      ) = 1
    ),
  constraint property_ownership_periods_date_order_check
    check (ends_on is null or ends_on >= starts_on),
  constraint property_ownership_periods_percentage_check
    check (
      ownership_percentage is null
      or (
        ownership_percentage > 0
        and ownership_percentage <= 100
      )
    )
);

create unique index property_ownership_periods_one_current_profile_idx
  on public.property_ownership_periods (property_id, owner_profile_id)
  where ends_on is null and owner_profile_id is not null;

create unique index property_ownership_periods_one_current_household_idx
  on public.property_ownership_periods (property_id, owner_household_id)
  where ends_on is null and owner_household_id is not null;

create unique index property_ownership_periods_one_current_organization_idx
  on public.property_ownership_periods (property_id, owner_organization_id)
  where ends_on is null and owner_organization_id is not null;

create trigger trg_property_ownership_periods_updated_at
  before update on public.property_ownership_periods
  for each row execute function public.set_updated_at();

comment on table public.property_ownership_periods is
  'Ownership or association information known to HomeHub. These records are not an authoritative legal-title registry.';
comment on column public.property_ownership_periods.evidence_document_id is
  'Optional supporting document ID. Its property-aware foreign key is intentionally deferred until migration 0013.';
