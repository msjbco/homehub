-- ============================================================
-- Migration 0002: Identity, Households, Organizations, Vendors
-- HomeHub — core user identity and organizational entities
-- ============================================================

-- ── Profiles ─────────────────────────────────────────────────
-- Extends Supabase auth.users with HomeHub-specific identity data.
-- auth.users is managed by Supabase Auth; do not replicate auth columns here.
create table public.profiles (
  id              uuid primary key default uuid_generate_v4(),
  auth_user_id    uuid unique,                        -- links to auth.users.id when auth is implemented
  role            public.user_role not null default 'homeowner',
  first_name      text not null,
  last_name       text not null,
  display_name    text,
  email           citext unique not null,
  phone           text,                               -- placeholder only; do not store real numbers
  avatar_url      text,                               -- storage path placeholder
  timezone        text not null default 'America/Chicago',
  locale          text not null default 'en-US',
  is_active       boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Households ────────────────────────────────────────────────
-- A household groups one or more profiles sharing a property.
create table public.households (
  id              uuid primary key default uuid_generate_v4(),
  name            text not null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Household Members ─────────────────────────────────────────
create table public.household_members (
  id              uuid primary key default uuid_generate_v4(),
  household_id    uuid not null references public.households(id) on delete cascade,
  profile_id      uuid not null references public.profiles(id) on delete cascade,
  is_primary      boolean not null default false,
  joined_at       timestamptz not null default now(),
  unique (household_id, profile_id)
);

-- ── Organizations ─────────────────────────────────────────────
-- Agencies, brokerages, inspection firms, insurance companies, etc.
create table public.organizations (
  id              uuid primary key default uuid_generate_v4(),
  name            text not null,
  org_type        text not null,                      -- e.g. 'real_estate_agency', 'insurance_agency'
  website         text,
  phone           text,                               -- placeholder only
  email           citext,
  address_line1   text,
  address_line2   text,
  city            text,
  state           text,
  zip             text,
  country         text not null default 'US',
  is_active       boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Organization Members ──────────────────────────────────────
create table public.organization_members (
  id              uuid primary key default uuid_generate_v4(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  profile_id      uuid not null references public.profiles(id) on delete cascade,
  member_role     text not null default 'member',     -- e.g. 'owner', 'admin', 'member', 'agent'
  joined_at       timestamptz not null default now(),
  unique (organization_id, profile_id)
);

-- ── Vendors ───────────────────────────────────────────────────
-- Independent contractors and service businesses available in the HomeHub network.
create table public.vendors (
  id              uuid primary key default uuid_generate_v4(),
  profile_id      uuid references public.profiles(id) on delete set null,
  organization_id uuid references public.organizations(id) on delete set null,
  business_name   text not null,
  specialty       text[],                             -- e.g. ARRAY['HVAC', 'Plumbing']
  license_number  text,                               -- placeholder only
  insurance_cert  text,                               -- storage path placeholder
  rating          numeric(3,2) check (rating >= 0 and rating <= 5),
  review_count    integer not null default 0,
  status          public.contractor_status not null default 'active',
  service_areas   text[],                             -- e.g. ARRAY['Austin, TX', '78745']
  bio             text,
  website         text,
  phone           text,                               -- placeholder only
  email           citext,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
