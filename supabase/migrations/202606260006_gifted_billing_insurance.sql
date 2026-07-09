-- ============================================================
-- Migration 0006: Gifted Billing and Insurance
-- HomeHub — subscription/billing plans and insurance policies
-- ============================================================

-- ── Subscriptions ─────────────────────────────────────────────
-- Tracks each household's HomeHub plan and billing state.
-- Stripe integration is NOT implemented in this foundation step.
create table public.subscriptions (
  id                  uuid primary key default uuid_generate_v4(),
  household_id        uuid not null references public.households(id) on delete cascade,
  plan                public.billing_plan not null default 'free',
  is_gifted           boolean not null default false,
  gifted_by           uuid references public.profiles(id) on delete set null,   -- org or admin that gifted
  gifted_reason       text,
  gifted_at           timestamptz,
  gifted_expires_at   timestamptz,
  stripe_customer_id  text,                           -- placeholder; do not populate with real IDs
  stripe_sub_id       text,                           -- placeholder; do not populate with real IDs
  current_period_start timestamptz,
  current_period_end   timestamptz,
  cancelled_at        timestamptz,
  is_active           boolean not null default true,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create trigger trg_subscriptions_updated_at
  before update on public.subscriptions
  for each row execute function public.set_updated_at();

-- ── Promo Codes ───────────────────────────────────────────────
create table public.promo_codes (
  id              uuid primary key default uuid_generate_v4(),
  code            text unique not null,
  description     text,
  plan_override   public.billing_plan,
  discount_pct    integer check (discount_pct >= 0 and discount_pct <= 100),
  max_redemptions integer,
  redemption_count integer not null default 0,
  expires_at      timestamptz,
  is_active       boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create trigger trg_promo_codes_updated_at
  before update on public.promo_codes
  for each row execute function public.set_updated_at();

-- ── Insurance Policies ────────────────────────────────────────
-- Homeowner's insurance policy records. No real policy numbers in seed.
create table public.insurance_policies (
  id                  uuid primary key default uuid_generate_v4(),
  property_id         uuid not null references public.properties(id) on delete cascade,
  insurer_name        text not null,
  policy_type         text not null,                  -- e.g. 'homeowners', 'flood', 'umbrella'
  status              public.insurance_policy_status not null default 'active',
  policy_number       text,                           -- placeholder only; do not use real numbers
  agent_name          text,
  agent_phone         text,                           -- placeholder only
  agent_email         citext,
  annual_premium      numeric(10,2),
  coverage_amount     numeric(12,2),
  deductible          numeric(10,2),
  effective_date      date,
  expiry_date         date,
  renewal_reminder_days integer not null default 30,
  document_id         uuid references public.documents(id) on delete set null,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create trigger trg_insurance_policies_updated_at
  before update on public.insurance_policies
  for each row execute function public.set_updated_at();
