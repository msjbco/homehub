-- ============================================================
-- Migration 0010: Identity and Membership Lifecycle
-- HomeHub — application identity and membership period hardening
-- ============================================================

-- public.profiles remains the sole HomeHub application identity. Supabase
-- auth.users owns authentication credentials and provider identities.

alter table public.profiles
  add column deactivated_at timestamptz,
  add constraint profiles_auth_user_id_fkey
    foreign key (auth_user_id) references auth.users(id) on delete set null,
  add constraint profiles_deactivated_at_check
    check (deactivated_at is null or deactivated_at >= created_at),
  add constraint profiles_deactivation_consistency_check
    check (deactivated_at is null or is_active = false);

comment on column public.profiles.auth_user_id is
  'Optional one-to-one link to Supabase auth.users. Null is permitted for invited or pre-created people.';
comment on column public.profiles.email is
  'HomeHub contact email; not the authoritative authentication identity key.';
comment on column public.profiles.is_active is
  'Compatibility flag retained for Foundation v1.0. Auth/RLS implementation will determine whether it remains or is retired.';
comment on column public.profiles.deactivated_at is
  'When set, the profile must also have is_active = false. The profile and its historical references are retained.';

-- Platform privileges and organization types are not person/business personas.
-- Fail rather than guessing how to map any profile that uses a removed value.
do $$
begin
  if exists (
    select 1
    from public.profiles
    where role::text in (
      'insurance_agency',
      'real_estate_agency',
      'np_admin',
      'homehub_admin',
      'homehub_superadmin'
    )
  ) then
    raise exception
      'Cannot replace public.user_role: at least one profile uses a removed role';
  end if;
end;
$$;

alter table public.profiles alter column role drop default;
alter type public.user_role rename to user_role_legacy;

create type public.user_role as enum (
  'homeowner',
  'contractor',
  'inspector',
  'insurance_agent',
  'real_estate_agent'
);

alter table public.profiles
  alter column role type public.user_role
  using role::text::public.user_role,
  alter column role set default 'homeowner'::public.user_role;

drop type public.user_role_legacy;

-- ── Household membership lifecycle ───────────────────────────

create type public.household_member_role as enum (
  'member',
  'caretaker',
  'manager'
);

alter table public.household_members
  drop constraint household_members_household_id_profile_id_key;

alter table public.household_members
  rename column joined_at to starts_at;

alter table public.household_members
  add column role public.household_member_role not null default 'member',
  add column invited_by uuid references public.profiles(id) on delete set null,
  add column invited_at timestamptz,
  add column accepted_at timestamptz,
  add column ends_at timestamptz,
  add column ended_by uuid references public.profiles(id) on delete set null,
  add column end_reason text;

update public.household_members
set accepted_at = starts_at;

alter table public.household_members
  add constraint household_members_acceptance_timeline_check
    check (accepted_at is null or invited_at is null or accepted_at >= invited_at),
  add constraint household_members_end_timeline_check
    check (ends_at is null or ends_at >= starts_at),
  add constraint household_members_ended_by_check
    check (ended_by is null or ends_at is not null),
  add constraint household_members_end_reason_check
    check (end_reason is null or ends_at is not null);

create unique index household_members_one_current_membership_idx
  on public.household_members (household_id, profile_id)
  where ends_at is null;

create unique index household_members_one_active_primary_idx
  on public.household_members (household_id)
  where is_primary and ends_at is null;

comment on column public.household_members.role is
  'Role within this household only; it does not grant HomeHub platform privileges.';
comment on column public.household_members.ends_at is
  'Null denotes the current membership period. Ended periods are retained as history.';

-- ── Organization membership lifecycle ────────────────────────

create type public.organization_member_role as enum (
  'owner',
  'admin',
  'member',
  'agent'
);

-- Validate legacy free-form roles before converting the column to an enum.
do $$
begin
  if exists (
    select 1
    from public.organization_members
    where member_role not in ('owner', 'admin', 'member', 'agent')
  ) then
    raise exception
      'Cannot convert organization_members.member_role: unsupported role value exists';
  end if;
end;
$$;

alter table public.organization_members
  drop constraint organization_members_organization_id_profile_id_key,
  alter column member_role drop default,
  alter column member_role type public.organization_member_role
    using member_role::public.organization_member_role,
  alter column member_role set default 'member'::public.organization_member_role;

alter table public.organization_members
  rename column joined_at to starts_at;

alter table public.organization_members
  add column invited_by uuid references public.profiles(id) on delete set null,
  add column invited_at timestamptz,
  add column accepted_at timestamptz,
  add column ends_at timestamptz,
  add column ended_by uuid references public.profiles(id) on delete set null,
  add column end_reason text;

update public.organization_members
set accepted_at = starts_at;

alter table public.organization_members
  add constraint organization_members_acceptance_timeline_check
    check (accepted_at is null or invited_at is null or accepted_at >= invited_at),
  add constraint organization_members_end_timeline_check
    check (ends_at is null or ends_at >= starts_at),
  add constraint organization_members_ended_by_check
    check (ended_by is null or ends_at is not null),
  add constraint organization_members_end_reason_check
    check (end_reason is null or ends_at is not null);

create unique index organization_members_one_current_membership_idx
  on public.organization_members (organization_id, profile_id)
  where ends_at is null;

comment on column public.organization_members.member_role is
  'Role within this organization. admin means organization administrator, not HomeHub platform administrator.';
comment on column public.organization_members.ends_at is
  'Null denotes the current membership period. Ended periods are retained as history.';
