-- ============================================================
-- Migration 0007: Notifications
-- HomeHub — in-app notification records for all user types
-- ============================================================

create table public.notifications (
  id              uuid primary key default uuid_generate_v4(),
  recipient_id    uuid not null references public.profiles(id) on delete cascade,
  type            public.notification_type not null,
  status          public.notification_status not null default 'unread',
  title           text not null,
  body            text,
  action_url      text,                               -- deep-link path within the app
  entity_type     text,                               -- e.g. 'maintenance_task', 'project'
  entity_id       uuid,
  property_id     uuid references public.properties(id) on delete cascade,
  metadata        jsonb,                              -- optional structured payload
  scheduled_for   timestamptz,                        -- null = send immediately
  sent_at         timestamptz,
  read_at         timestamptz,
  dismissed_at    timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create trigger trg_notifications_updated_at
  before update on public.notifications
  for each row execute function public.set_updated_at();
