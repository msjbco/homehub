-- ============================================================
-- Migration 0005: Generic Notes, Tags, Status History, Audit Log
-- HomeHub — cross-entity notes, tagging, status tracking, audit
-- ============================================================

-- ── Notes ────────────────────────────────────────────────────
-- Generic notes attachable to any entity via polymorphic reference.
create table public.notes (
  id              uuid primary key default uuid_generate_v4(),
  author_id       uuid references public.profiles(id) on delete set null,
  entity_type     text not null,                      -- e.g. 'property', 'project', 'home_system'
  entity_id       uuid not null,
  body            text not null,
  is_pinned       boolean not null default false,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Tags ──────────────────────────────────────────────────────
-- User-defined labels attachable to any entity.
create table public.tags (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid references public.properties(id) on delete cascade,
  name            text not null,
  color           text,                               -- hex color, e.g. '#27A570'
  created_at      timestamptz not null default now()
);

create table public.entity_tags (
  id              uuid primary key default uuid_generate_v4(),
  tag_id          uuid not null references public.tags(id) on delete cascade,
  entity_type     text not null,
  entity_id       uuid not null,
  tagged_at       timestamptz not null default now(),
  unique (tag_id, entity_type, entity_id)
);

-- ── Status History ────────────────────────────────────────────
-- Immutable log of status transitions for projects, properties, etc.
create table public.status_history (
  id              uuid primary key default uuid_generate_v4(),
  changed_by      uuid references public.profiles(id) on delete set null,
  entity_type     text not null,
  entity_id       uuid not null,
  from_status     text,
  to_status       text not null,
  reason          text,
  changed_at      timestamptz not null default now()
);

-- ── Audit Log ────────────────────────────────────────────────
-- Append-only record of significant system actions.
-- Not a replacement for Supabase's built-in logging; supplemental only.
create table public.audit_log (
  id              uuid primary key default uuid_generate_v4(),
  actor_id        uuid references public.profiles(id) on delete set null,
  action          public.audit_action not null,
  entity_type     text,
  entity_id       uuid,
  description     text,
  metadata        jsonb,                              -- arbitrary structured context
  ip_address      text,                               -- placeholder; do not store real IPs in seed
  occurred_at     timestamptz not null default now()
);

-- ── updated_at trigger function ───────────────────────────────
-- Reusable trigger to keep updated_at current on any table.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Apply updated_at triggers to all mutable tables
do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles',
    'households',
    'household_members',
    'organizations',
    'organization_members',
    'vendors',
    'properties',
    'rooms',
    'home_systems',
    'home_services',
    'maintenance_tasks',
    'projects',
    'professional_contacts',
    'phonebook_entries',
    'documents',
    'media',
    'access_grants',
    'notes',
    'tags'
  ]
  loop
    execute format(
      'create trigger trg_%s_updated_at
       before update on public.%s
       for each row execute function public.set_updated_at()',
      t, t
    );
  end loop;
end;
$$;
