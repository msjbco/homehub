-- ============================================================
-- Migration 0012: Platform Staff Roles
-- HomeHub — explicit, auditable platform staff affiliation
-- ============================================================

create type public.platform_staff_role as enum (
  'support',
  'admin',
  'super_admin'
);

comment on type public.platform_staff_role is
  'HomeHub platform roles only. super_admin is a tightly controlled platform privilege, not a customer persona.';

create table public.platform_staff_roles (
  id              uuid primary key default uuid_generate_v4(),
  profile_id      uuid not null references public.profiles(id) on delete restrict,
  role            public.platform_staff_role not null,
  granted_by      uuid references public.profiles(id) on delete set null,
  granted_at      timestamptz not null default now(),
  grant_reason    text not null,
  revoked_by      uuid references public.profiles(id) on delete set null,
  revoked_at      timestamptz,
  revoke_reason   text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  constraint platform_staff_roles_grant_reason_check
    check (btrim(grant_reason) <> ''),
  constraint platform_staff_roles_revocation_timeline_check
    check (revoked_at is null or revoked_at >= granted_at),
  constraint platform_staff_roles_revoked_by_check
    check (revoked_by is null or revoked_at is not null),
  constraint platform_staff_roles_revoke_reason_requires_revocation_check
    check (revoke_reason is null or revoked_at is not null),
  constraint platform_staff_roles_revoke_reason_content_check
    check (revoke_reason is null or btrim(revoke_reason) <> '')
);

-- This partial unique index also supports active staff lookup by profile.
create unique index platform_staff_roles_one_active_role_idx
  on public.platform_staff_roles (profile_id, role)
  where revoked_at is null;

create index platform_staff_roles_active_role_lookup_idx
  on public.platform_staff_roles (role, profile_id)
  where revoked_at is null;

create trigger trg_platform_staff_roles_updated_at
  before update on public.platform_staff_roles
  for each row execute function public.set_updated_at();

comment on table public.platform_staff_roles is
  'HomeHub platform affiliation and capability assignments only. An active role does not grant access to customer data; scoped support access uses governed access grants plus future RLS and service authorization.';
comment on column public.platform_staff_roles.profile_id is
  'Staff profile. This assignment does not create property, household, organization, document, or other customer-data access.';
comment on column public.platform_staff_roles.role is
  'Platform role. Organization admin and platform admin are unrelated concepts.';
comment on column public.platform_staff_roles.grant_reason is
  'Auditable reason for assigning this platform role.';
comment on column public.platform_staff_roles.revoked_at is
  'Null denotes an active platform-role assignment. Revoked assignments remain as history.';
