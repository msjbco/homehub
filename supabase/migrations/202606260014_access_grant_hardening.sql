-- ============================================================
-- Migration 0014: Access Grant Hardening
-- HomeHub — governed, scoped, lifecycle-aware temporary access
-- ============================================================

create type public.access_grant_purpose as enum (
  'guest',
  'vendor',
  'professional',
  'support'
);

create type public.access_grant_capability as enum (
  'read',
  'upload',
  'log_work'
);

create type public.access_grant_target_type as enum (
  'profile',
  'vendor',
  'organization',
  'anonymous'
);

-- Refuse to harden contradictory legacy rows. The existing QR/invite model
-- allowed a profile, a vendor, or neither, but never legitimately both.
do $$
begin
  if exists (
    select 1 from public.access_grants
    where granted_to is not null and vendor_id is not null
  ) then
    raise exception 'access_grants contains rows with multiple legacy targets';
  end if;

  if exists (
    select 1 from public.access_grants
    where expires_at is not null and expires_at < created_at
  ) then
    raise exception 'access_grants contains expiration before creation';
  end if;

  if exists (
    select 1 from public.access_grants
    where revoked_at is not null and revoked_at < created_at
  ) then
    raise exception 'access_grants contains revocation before creation';
  end if;

  if exists (
    select 1 from public.access_grants
    where use_count < 0
       or max_uses <= 0
       or (max_uses is not null and use_count > max_uses)
  ) then
    raise exception 'access_grants contains an invalid usage lifecycle';
  end if;
end
$$;

alter table public.access_grants
  rename column granted_to to grantee_profile_id;

alter table public.access_grants
  rename column vendor_id to grantee_vendor_id;

alter table public.access_grants
  rename column token to token_hash;

alter table public.access_grants
  rename constraint access_grants_token_key to access_grants_token_hash_key;

-- The old explicit token index duplicated the unique constraint's index.
drop index public.idx_access_grants_token;

alter table public.access_grants
  add column target_type public.access_grant_target_type,
  add column purpose public.access_grant_purpose,
  add column grantee_organization_id uuid,
  add column document_id uuid,
  add column document_category public.document_category,
  add column business_reason text,
  add column starts_at timestamptz,
  add column revoked_by uuid,
  add column revoke_reason text;

update public.access_grants
set target_type = case
      when grantee_profile_id is not null then 'profile'::public.access_grant_target_type
      when grantee_vendor_id is not null then 'vendor'::public.access_grant_target_type
      else 'anonymous'::public.access_grant_target_type
    end,
    purpose = case
      when grantee_vendor_id is not null then 'vendor'::public.access_grant_purpose
      when grantee_profile_id is not null then 'professional'::public.access_grant_purpose
      else 'guest'::public.access_grant_purpose
    end,
    starts_at = created_at,
    token_hash = encode(digest(token_hash, 'sha256'), 'hex');

alter table public.access_grants
  alter column target_type set not null,
  alter column purpose set not null,
  alter column starts_at set not null,
  alter column starts_at set default now(),
  alter column token_hash drop default,
  alter column granted_by drop not null;

alter table public.access_grants
  drop constraint access_grants_property_id_fkey,
  drop constraint access_grants_granted_by_fkey,
  drop constraint access_grants_granted_to_fkey,
  drop constraint access_grants_vendor_id_fkey,
  add constraint access_grants_property_id_fkey
    foreign key (property_id) references public.properties(id) on delete restrict,
  add constraint access_grants_granted_by_fkey
    foreign key (granted_by) references public.profiles(id) on delete set null,
  add constraint access_grants_grantee_profile_id_fkey
    foreign key (grantee_profile_id) references public.profiles(id) on delete restrict,
  add constraint access_grants_grantee_vendor_id_fkey
    foreign key (grantee_vendor_id) references public.vendors(id) on delete restrict,
  add constraint access_grants_grantee_organization_id_fkey
    foreign key (grantee_organization_id) references public.organizations(id) on delete restrict,
  add constraint access_grants_property_document_fkey
    foreign key (property_id, document_id)
    references public.documents(property_id, id) on delete restrict,
  add constraint access_grants_revoked_by_fkey
    foreign key (revoked_by) references public.profiles(id) on delete set null,
  add constraint access_grants_target_check check (
    (target_type = 'profile' and grantee_profile_id is not null
      and grantee_vendor_id is null and grantee_organization_id is null)
    or
    (target_type = 'vendor' and grantee_profile_id is null
      and grantee_vendor_id is not null and grantee_organization_id is null)
    or
    (target_type = 'organization' and grantee_profile_id is null
      and grantee_vendor_id is null and grantee_organization_id is not null)
    or
    (target_type = 'anonymous' and grantee_profile_id is null
      and grantee_vendor_id is null and grantee_organization_id is null)
  ),
  add constraint access_grants_scope_check
    check (num_nonnulls(document_id, document_category) <= 1),
  add constraint access_grants_token_hash_check
    check (token_hash ~ '^[0-9a-f]{64}$'),
  add constraint access_grants_expiration_timeline_check
    check (expires_at is null or expires_at >= starts_at),
  add constraint access_grants_revocation_timeline_check
    check (revoked_at is null or revoked_at >= starts_at),
  add constraint access_grants_revoked_by_check
    check (revoked_by is null or revoked_at is not null),
  add constraint access_grants_revoke_reason_requires_revocation_check
    check (revoke_reason is null or revoked_at is not null),
  add constraint access_grants_revoke_reason_content_check
    check (revoke_reason is null or btrim(revoke_reason) <> ''),
  add constraint access_grants_max_uses_check
    check (max_uses is null or max_uses > 0),
  add constraint access_grants_use_count_check
    check (use_count >= 0),
  add constraint access_grants_usage_limit_check
    check (max_uses is null or use_count <= max_uses),
  add constraint access_grants_support_target_check
    check (purpose <> 'support' or target_type = 'profile'),
  add constraint access_grants_support_expiration_check
    check (purpose <> 'support' or expires_at is not null),
  add constraint access_grants_support_reason_check
    check (purpose <> 'support' or (business_reason is not null and btrim(business_reason) <> '')),
  add constraint access_grants_id_purpose_key unique (id, purpose);

create table public.access_grant_capabilities (
  access_grant_id uuid not null,
  grant_purpose public.access_grant_purpose not null,
  capability public.access_grant_capability not null,
  created_at timestamptz not null default now(),

  constraint access_grant_capabilities_pkey
    primary key (access_grant_id, capability),
  constraint access_grant_capabilities_grant_fkey
    foreign key (access_grant_id, grant_purpose)
    references public.access_grants(id, purpose)
    on update cascade on delete cascade,
  constraint access_grant_capabilities_support_read_only_check
    check (grant_purpose <> 'support' or capability = 'read')
);

-- The legacy grant model existed specifically for contractors/caretakers to
-- log work. Preserve that capability during the forward migration.
insert into public.access_grant_capabilities (
  access_grant_id, grant_purpose, capability
)
select id, purpose, 'log_work'
from public.access_grants;

-- Active staff-role eligibility is a cross-row, partial-state invariant and
-- cannot be expressed by CHECK/UNIQUE/FK constraints. This trigger validates
-- only that eligibility; it does not grant access or make authorization calls.
create function public.validate_support_grant_staff_role()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.purpose = 'support'
     and new.grantee_profile_id is not null
     and not exists (
       select 1
       from public.platform_staff_roles psr
       where psr.profile_id = new.grantee_profile_id
         and psr.revoked_at is null
     ) then
    raise exception 'support grant target must have an active platform staff role'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

create trigger trg_access_grants_validate_support_staff
  before insert or update of purpose, grantee_profile_id
  on public.access_grants
  for each row execute function public.validate_support_grant_staff_role();

alter table public.access_grant_log
  drop constraint access_grant_log_grant_id_fkey,
  add constraint access_grant_log_grant_id_fkey
    foreign key (grant_id) references public.access_grants(id) on delete restrict;

create index idx_access_grants_grantee_profile
  on public.access_grants(grantee_profile_id);
create index idx_access_grants_grantee_vendor
  on public.access_grants(grantee_vendor_id);
create index idx_access_grants_grantee_organization
  on public.access_grants(grantee_organization_id);
create index idx_access_grants_document
  on public.access_grants(document_id);
create index idx_access_grants_active_property
  on public.access_grants(property_id, purpose, expires_at)
  where revoked_at is null;

drop index public.idx_access_grants_vendor;

comment on column public.access_grants.token_hash is
  'SHA-256 digest of a high-entropy raw access token. Raw tokens are generated, delivered, and compared by application services and are never persisted.';
comment on column public.access_grants.document_category is
  'Optional global document-category scope. It is mutually exclusive with a single-document scope.';
comment on column public.access_grants.business_reason is
  'Required nonblank business justification for support access.';
comment on table public.access_grant_capabilities is
  'Normalized capabilities assigned to a governed access grant. Support grants are declaratively restricted to read.';
comment on table public.access_grant_log is
  'Append-only access-use history by application contract. A logged grant cannot be deleted because the grant foreign key uses RESTRICT.';
