-- ============================================================
-- Migration 0018: Membership Timestamp Integrity
-- HomeHub — repair membership update-trigger prerequisites
-- ============================================================

alter table public.household_members
  add column created_at timestamptz,
  add column updated_at timestamptz;

alter table public.organization_members
  add column created_at timestamptz,
  add column updated_at timestamptz;

-- These triggers predate the timestamp columns. Disable them only while the
-- deterministic backfill is applied; they are preserved and re-enabled below.
alter table public.household_members
  disable trigger trg_household_members_updated_at;

update public.household_members
set created_at = starts_at,
    updated_at = starts_at;

alter table public.household_members
  enable trigger trg_household_members_updated_at;

alter table public.organization_members
  disable trigger trg_organization_members_updated_at;

update public.organization_members
set created_at = starts_at,
    updated_at = starts_at;

alter table public.organization_members
  enable trigger trg_organization_members_updated_at;

alter table public.household_members
  alter column created_at set default now(),
  alter column created_at set not null,
  alter column updated_at set default now(),
  alter column updated_at set not null,
  add constraint household_members_timestamp_order_check
    check (updated_at >= created_at);

alter table public.organization_members
  alter column created_at set default now(),
  alter column created_at set not null,
  alter column updated_at set default now(),
  alter column updated_at set not null,
  add constraint organization_members_timestamp_order_check
    check (updated_at >= created_at);

comment on column public.household_members.created_at is
  'Row creation time. Pre-0018 rows use starts_at as a deterministic Foundation backfill approximation because creation timestamps were not previously recorded.';
comment on column public.household_members.updated_at is
  'Last row update time. Pre-0018 rows use starts_at as a deterministic Foundation backfill approximation because update timestamps were not previously recorded.';
comment on column public.organization_members.created_at is
  'Row creation time. Pre-0018 rows use starts_at as a deterministic Foundation backfill approximation because creation timestamps were not previously recorded.';
comment on column public.organization_members.updated_at is
  'Last row update time. Pre-0018 rows use starts_at as a deterministic Foundation backfill approximation because update timestamps were not previously recorded.';
