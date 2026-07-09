-- ============================================================
-- Migration 0004: Documents, Media, and Access Grants
-- HomeHub — file vault, photo/video media, and QR/invite access
-- ============================================================

-- ── Documents ─────────────────────────────────────────────────
-- Homeowner document vault: warranties, permits, contracts, invoices, etc.
create table public.documents (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  uploaded_by     uuid references public.profiles(id) on delete set null,
  category        public.document_category not null default 'other',
  title           text not null,
  description     text,
  storage_path    text not null,                      -- placeholder path; real upload not implemented
  file_name       text not null,
  file_size_bytes integer,
  mime_type       text,
  expiry_date     date,
  is_shared       boolean not null default false,
  project_id      uuid references public.projects(id) on delete set null,
  home_system_id  uuid references public.home_systems(id) on delete set null,
  vendor_id       uuid references public.vendors(id) on delete set null,
  tags            text[],
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Media ─────────────────────────────────────────────────────
-- Photos and videos attached to properties, rooms, projects, or systems.
create table public.media (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  uploaded_by     uuid references public.profiles(id) on delete set null,
  media_type      public.media_type not null default 'image',
  title           text,
  description     text,
  storage_path    text not null,                      -- placeholder path; real upload not implemented
  file_name       text not null,
  file_size_bytes integer,
  mime_type       text,
  width_px        integer,
  height_px       integer,
  duration_secs   integer,                            -- for video
  room_id         uuid references public.rooms(id) on delete set null,
  project_id      uuid references public.projects(id) on delete set null,
  home_system_id  uuid references public.home_systems(id) on delete set null,
  is_before_photo boolean not null default false,
  is_after_photo  boolean not null default false,
  tags            text[],
  taken_at        timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Access Grants ─────────────────────────────────────────────
-- QR code and invite-link based access for contractors to log work on a property.
create table public.access_grants (
  id              uuid primary key default uuid_generate_v4(),
  property_id     uuid not null references public.properties(id) on delete cascade,
  granted_by      uuid not null references public.profiles(id) on delete cascade,
  granted_to      uuid references public.profiles(id) on delete set null,
  vendor_id       uuid references public.vendors(id) on delete set null,
  grant_type      public.access_grant_type not null default 'qr_code',
  token           text unique not null default encode(gen_random_bytes(32), 'hex'),
  label           text,                               -- e.g. 'Pool Service - AquaPro'
  expires_at      timestamptz,
  revoked_at      timestamptz,
  last_used_at    timestamptz,
  use_count       integer not null default 0,
  max_uses        integer,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── Access Grant Log ──────────────────────────────────────────
-- Record of each time an access grant token is used.
create table public.access_grant_log (
  id              uuid primary key default uuid_generate_v4(),
  grant_id        uuid not null references public.access_grants(id) on delete cascade,
  used_by         uuid references public.profiles(id) on delete set null,
  used_at         timestamptz not null default now(),
  ip_address      text,                               -- placeholder; do not store real IPs in seed
  user_agent      text
);
