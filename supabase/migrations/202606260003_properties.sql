-- ============================================================
-- Migration 0003: Properties
-- HomeHub — property, rooms, systems, services, maintenance,
--            projects, professional contacts, and phonebook
-- ============================================================

-- ── Properties ───────────────────────────────────────────────
create table public.properties (
  id                  uuid primary key default uuid_generate_v4(),
  household_id        uuid not null references public.households(id) on delete cascade,
  address_line1       text not null,
  address_line2       text,
  city                text not null,
  state               text not null,
  zip                 text not null,
  country             text not null default 'US',
  property_type       public.property_type not null default 'single_family',
  status              public.property_status not null default 'active',
  year_built          integer,
  square_feet         integer,
  lot_size_sqft       integer,
  bedrooms            integer,
  bathrooms           numeric(4,1),
  purchase_price      numeric(12,2),
  purchase_date       date,
  current_value       numeric(12,2),
  health_score        integer check (health_score >= 0 and health_score <= 100),
  home_strength_score integer check (home_strength_score >= 0 and home_strength_score <= 100),
  energy_score        integer check (energy_score >= 0 and energy_score <= 100),
  hero_image_url      text,                           -- storage path placeholder
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- ── Rooms ─────────────────────────────────────────────────────
create table public.rooms (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  name            text not null,                      -- e.g. 'Kitchen', 'Master Bedroom'
  room_type       text,                               -- e.g. 'kitchen', 'bedroom', 'bathroom'
  floor_level     integer,
  square_feet     integer,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Home Systems ──────────────────────────────────────────────
create table public.home_systems (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  system_type     text not null,                      -- e.g. 'hvac', 'plumbing', 'electrical'
  name            text not null,
  brand           text,
  model           text,
  serial_number   text,                               -- placeholder only
  installed_date  date,
  last_service    date,
  next_service    date,
  warranty_expiry date,
  condition       text,                               -- e.g. 'good', 'fair', 'poor'
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Home Services ─────────────────────────────────────────────
create table public.home_services (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  vendor_id       uuid references public.vendors(id) on delete set null,
  service_type    text not null,                      -- e.g. 'landscaping', 'cleaning', 'pest_control'
  provider_name   text,
  provider_phone  text,                               -- placeholder only
  schedule        text,                               -- e.g. 'Weekly (Thursday 10am-2pm)'
  price_per_visit numeric(10,2),
  price_unit      text,                               -- e.g. 'visit', 'month', 'year'
  monthly_cost    numeric(10,2),
  is_active       boolean not null default true,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Maintenance Tasks ─────────────────────────────────────────
create table public.maintenance_tasks (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  home_system_id  uuid references public.home_systems(id) on delete set null,
  title           text not null,
  description     text,
  due_date        date,
  completed_at    timestamptz,
  is_recurring    boolean not null default false,
  recurrence_rule text,                               -- e.g. 'FREQ=MONTHLY;INTERVAL=3'
  priority        text not null default 'normal',     -- 'low', 'normal', 'high', 'urgent'
  estimated_cost  numeric(10,2),
  actual_cost     numeric(10,2),
  vendor_id       uuid references public.vendors(id) on delete set null,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Projects ──────────────────────────────────────────────────
create table public.projects (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  title           text not null,
  description     text,
  project_type    public.project_type not null default 'other',
  status          public.project_status not null default 'planned',
  start_date      date,
  end_date        date,
  estimated_cost  numeric(12,2),
  actual_cost     numeric(12,2),
  vendor_id       uuid references public.vendors(id) on delete set null,
  is_diy          boolean not null default false,
  room_id         uuid references public.rooms(id) on delete set null,
  home_system_id  uuid references public.home_systems(id) on delete set null,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Professional Contacts ─────────────────────────────────────
-- Homeowner's personal rolodex of professionals (realtor, lender, inspector, etc.)
create table public.professional_contacts (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  profile_id      uuid references public.profiles(id) on delete set null,
  contact_type    text not null,                      -- 'realtor', 'lender', 'inspector', 'insurance', 'closing'
  name            text not null,
  company         text,
  phone           text,                               -- placeholder only
  email           citext,
  city            text,
  state           text,
  notes           text,
  extra_fields    jsonb,                              -- type-specific fields (license #, policy #, etc.)
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Phonebook (Contractor Phonebook) ──────────────────────────
-- Homeowner's personal list of known/trusted contractors for a property.
create table public.phonebook_entries (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  vendor_id       uuid references public.vendors(id) on delete set null,
  name            text not null,
  specialty       text,
  phone           text,                               -- placeholder only
  email           citext,
  rating          integer check (rating >= 1 and rating <= 5),
  is_trusted      boolean not null default false,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
