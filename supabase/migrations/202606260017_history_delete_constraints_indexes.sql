-- ============================================================
-- Migration 0017: History, delete behavior, constraints, indexes
-- ============================================================

-- Abort rather than reinterpret existing business data.
do $$
begin
  if exists (select 1 from public.vendors where review_count < 0)
    or exists (select 1 from public.properties where year_built <= 0 or square_feet < 0 or lot_size_sqft < 0 or bedrooms < 0 or bathrooms < 0 or purchase_price < 0 or current_value < 0)
    or exists (select 1 from public.rooms where square_feet < 0)
    or exists (select 1 from public.home_services where price_per_visit < 0 or monthly_cost < 0)
    or exists (select 1 from public.maintenance_tasks where estimated_cost < 0 or actual_cost < 0)
    or exists (select 1 from public.projects where estimated_cost < 0 or actual_cost < 0 or (start_date is not null and end_date is not null and end_date < start_date))
    or exists (select 1 from public.home_systems where last_service is not null and next_service is not null and next_service < last_service)
  then raise exception 'Existing rows violate Phase 8 numeric or timeline constraints'; end if;

  if exists (select 1 from public.households where btrim(name) = '')
    or exists (select 1 from public.organizations where btrim(name) = '' or btrim(org_type) = '')
    or exists (select 1 from public.vendors where btrim(business_name) = '')
    or exists (select 1 from public.properties where btrim(address_line1) = '' or btrim(city) = '' or btrim(state) = '' or btrim(zip) = '')
    or exists (select 1 from public.rooms where btrim(name) = '')
    or exists (select 1 from public.home_systems where btrim(system_type) = '' or btrim(name) = '')
    or exists (select 1 from public.home_services where btrim(service_type) = '')
    or exists (select 1 from public.maintenance_tasks where btrim(title) = '')
    or exists (select 1 from public.projects where btrim(title) = '')
    or exists (select 1 from public.professional_contacts where btrim(contact_type) = '' or btrim(name) = '')
    or exists (select 1 from public.phonebook_entries where btrim(name) = '')
    or exists (select 1 from public.documents where btrim(title) = '')
    or exists (select 1 from public.notes where btrim(entity_type) = '' or btrim(body) = '')
    or exists (select 1 from public.tags where btrim(name) = '')
    or exists (select 1 from public.entity_tags where btrim(entity_type) = '')
    or exists (select 1 from public.status_history where btrim(entity_type) = '' or btrim(to_status) = '')
    or exists (select 1 from public.notifications where btrim(title) = '')
  then raise exception 'Existing rows violate Phase 8 structural text constraints'; end if;
end
$$;

-- Archival and logical deletion preserve the authoritative metadata rows.
alter table public.properties add column archived_at timestamptz;
alter table public.documents add column deleted_at timestamptz;
alter table public.media add column deleted_at timestamptz;
alter table public.tags add column updated_at timestamptz not null default now();

do $$
begin
  if exists (select 1 from public.properties where status = 'archived') then
    raise exception 'Existing archived property status requires an explicit archived_at migration decision';
  end if;
end
$$;

alter table public.properties
  add constraint properties_archive_state_check
    check ((status = 'archived') = (archived_at is not null));

comment on column public.properties.archived_at is
  'When set, this HomeHub property record is no longer active/current. Archival preserves property history and related records; physical deletion remains possible only when foreign-key history rules permit it. Later application workflows govern who may archive.';
comment on column public.documents.deleted_at is
  'Logical deletion of the HomeHub document metadata row. References and history remain; storage-object cleanup is a later service concern, and later Auth/RLS queries must filter deleted rows where appropriate.';
comment on column public.media.deleted_at is
  'Logical deletion of the HomeHub media metadata row. References and history remain; storage-object cleanup is a later service concern, and later Auth/RLS queries must filter deleted rows where appropriate.';
comment on column public.tags.updated_at is
  'Maintained by the existing tags updated-at trigger; added because the trigger previously targeted a missing column.';

-- Enduring historical/business rows must not disappear with a parent.
alter table public.properties
  drop constraint properties_household_id_fkey,
  add constraint properties_household_id_fkey foreign key (household_id)
    references public.households(id) on delete restrict;

alter table public.household_members
  drop constraint household_members_household_id_fkey,
  drop constraint household_members_profile_id_fkey,
  add constraint household_members_household_id_fkey foreign key (household_id)
    references public.households(id) on delete restrict,
  add constraint household_members_profile_id_fkey foreign key (profile_id)
    references public.profiles(id) on delete restrict;

alter table public.organization_members
  drop constraint organization_members_organization_id_fkey,
  drop constraint organization_members_profile_id_fkey,
  add constraint organization_members_organization_id_fkey foreign key (organization_id)
    references public.organizations(id) on delete restrict,
  add constraint organization_members_profile_id_fkey foreign key (profile_id)
    references public.profiles(id) on delete restrict;

alter table public.maintenance_tasks
  drop constraint maintenance_tasks_property_id_fkey,
  add constraint maintenance_tasks_property_id_fkey foreign key (property_id)
    references public.properties(id) on delete restrict;

alter table public.projects
  drop constraint projects_property_id_fkey,
  add constraint projects_property_id_fkey foreign key (property_id)
    references public.properties(id) on delete restrict;

alter table public.documents
  drop constraint documents_property_id_fkey,
  add constraint documents_property_id_fkey foreign key (property_id)
    references public.properties(id) on delete restrict;

alter table public.media
  drop constraint media_property_id_fkey,
  add constraint media_property_id_fkey foreign key (property_id)
    references public.properties(id) on delete restrict;

-- Notifications are historical delivery records; deleting a subject or
-- property clears the reference without erasing the notification.
alter table public.notifications
  alter column recipient_id drop not null,
  drop constraint notifications_recipient_id_fkey,
  drop constraint notifications_property_id_fkey,
  add constraint notifications_recipient_id_fkey foreign key (recipient_id)
    references public.profiles(id) on delete set null,
  add constraint notifications_property_id_fkey foreign key (property_id)
    references public.properties(id) on delete set null;

-- Remaining domain constraints with unambiguous business semantics.
alter table public.vendors
  add constraint vendors_review_count_nonnegative_check check (review_count >= 0);

alter table public.properties
  add constraint properties_year_built_check check (year_built is null or year_built > 0),
  add constraint properties_square_feet_check check (square_feet is null or square_feet >= 0),
  add constraint properties_lot_size_check check (lot_size_sqft is null or lot_size_sqft >= 0),
  add constraint properties_bedrooms_check check (bedrooms is null or bedrooms >= 0),
  add constraint properties_bathrooms_check check (bathrooms is null or bathrooms >= 0),
  add constraint properties_purchase_price_check check (purchase_price is null or purchase_price >= 0),
  add constraint properties_current_value_check check (current_value is null or current_value >= 0);

alter table public.rooms
  add constraint rooms_square_feet_check check (square_feet is null or square_feet >= 0);

alter table public.home_services
  add constraint home_services_price_per_visit_check check (price_per_visit is null or price_per_visit >= 0),
  add constraint home_services_monthly_cost_check check (monthly_cost is null or monthly_cost >= 0);

alter table public.maintenance_tasks
  add constraint maintenance_tasks_estimated_cost_check check (estimated_cost is null or estimated_cost >= 0),
  add constraint maintenance_tasks_actual_cost_check check (actual_cost is null or actual_cost >= 0);

alter table public.projects
  add constraint projects_estimated_cost_check check (estimated_cost is null or estimated_cost >= 0),
  add constraint projects_actual_cost_check check (actual_cost is null or actual_cost >= 0),
  add constraint projects_date_order_check check (end_date is null or start_date is null or end_date >= start_date);

alter table public.home_systems
  add constraint home_systems_service_date_order_check check (next_service is null or last_service is null or next_service >= last_service);

-- Required structural labels may not be blank.
alter table public.households add constraint households_name_content_check check (btrim(name) <> '');
alter table public.organizations
  add constraint organizations_name_content_check check (btrim(name) <> ''),
  add constraint organizations_type_content_check check (btrim(org_type) <> '');
alter table public.vendors add constraint vendors_business_name_content_check check (btrim(business_name) <> '');
alter table public.properties
  add constraint properties_address_content_check check (btrim(address_line1) <> ''),
  add constraint properties_city_content_check check (btrim(city) <> ''),
  add constraint properties_state_content_check check (btrim(state) <> ''),
  add constraint properties_zip_content_check check (btrim(zip) <> '');
alter table public.rooms add constraint rooms_name_content_check check (btrim(name) <> '');
alter table public.home_systems
  add constraint home_systems_type_content_check check (btrim(system_type) <> ''),
  add constraint home_systems_name_content_check check (btrim(name) <> '');
alter table public.home_services add constraint home_services_type_content_check check (btrim(service_type) <> '');
alter table public.maintenance_tasks add constraint maintenance_tasks_title_content_check check (btrim(title) <> '');
alter table public.projects add constraint projects_title_content_check check (btrim(title) <> '');
alter table public.professional_contacts
  add constraint professional_contacts_type_content_check check (btrim(contact_type) <> ''),
  add constraint professional_contacts_name_content_check check (btrim(name) <> '');
alter table public.phonebook_entries add constraint phonebook_entries_name_content_check check (btrim(name) <> '');
alter table public.documents add constraint documents_title_content_rule check (btrim(title) <> '');
alter table public.notes
  add constraint notes_entity_type_content_check check (btrim(entity_type) <> ''),
  add constraint notes_body_content_check check (btrim(body) <> '');
alter table public.tags add constraint tags_name_content_check check (btrim(name) <> '');
alter table public.entity_tags add constraint entity_tags_entity_type_content_check check (btrim(entity_type) <> '');
alter table public.status_history
  add constraint status_history_entity_type_content_check check (btrim(entity_type) <> ''),
  add constraint status_history_to_status_content_check check (btrim(to_status) <> '');
alter table public.notifications add constraint notifications_title_content_check check (btrim(title) <> '');

-- Current-state and historical lookup indexes.
create index properties_unarchived_household_idx
  on public.properties(household_id, id) where archived_at is null;
create index documents_active_property_idx
  on public.documents(property_id, created_at desc) where deleted_at is null;
create index media_active_property_idx
  on public.media(property_id, created_at desc) where deleted_at is null;
create index property_memberships_history_property_idx
  on public.property_memberships(property_id, starts_at desc);
create index property_memberships_history_profile_idx
  on public.property_memberships(profile_id, starts_at desc);
create index property_ownership_periods_owner_profile_idx on public.property_ownership_periods(owner_profile_id);
create index property_ownership_periods_owner_household_idx on public.property_ownership_periods(owner_household_id);
create index property_ownership_periods_owner_organization_idx on public.property_ownership_periods(owner_organization_id);
create index property_ownership_periods_evidence_document_idx on public.property_ownership_periods(evidence_document_id);
create index property_ownership_periods_recorded_by_idx on public.property_ownership_periods(recorded_by);
create index platform_staff_roles_profile_history_idx on public.platform_staff_roles(profile_id, granted_at desc);
create index idx_documents_uploaded_by on public.documents(uploaded_by);
create index idx_documents_home_system on public.documents(home_system_id);
create index idx_documents_vendor on public.documents(vendor_id);
create index idx_media_uploaded_by on public.media(uploaded_by);
create index idx_media_home_system on public.media(home_system_id);
create index idx_maintenance_vendor on public.maintenance_tasks(vendor_id);
create index idx_prof_contacts_profile on public.professional_contacts(profile_id);
create index idx_vendors_organization on public.vendors(organization_id);
create index idx_access_grant_log_used_by on public.access_grant_log(used_by);
create index idx_subscriptions_gifted_by_profile on public.subscriptions(gifted_by_profile_id);
create index idx_subscriptions_sponsor_organization on public.subscriptions(sponsor_organization_id);
create index idx_insurance_document on public.insurance_policies(document_id);

-- These simple indexes duplicate the leading columns of Phase 4 candidate-key
-- indexes and provide no additional ordering or predicate.
drop index public.idx_rooms_property;
drop index public.idx_home_systems_property;
drop index public.idx_projects_property;
drop index public.idx_documents_property;

-- These duplicate unique constraint indexes exactly.
drop index public.idx_profiles_auth_user_id;
drop index public.idx_profiles_email;
