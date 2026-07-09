-- ============================================================
-- Migration 0008: Indexes
-- HomeHub — performance indexes for common query patterns
-- ============================================================

-- ── profiles ─────────────────────────────────────────────────
create index idx_profiles_auth_user_id      on public.profiles(auth_user_id);
create index idx_profiles_email             on public.profiles(email);
create index idx_profiles_role              on public.profiles(role);

-- ── household_members ─────────────────────────────────────────
create index idx_household_members_profile  on public.household_members(profile_id);
create index idx_household_members_hh       on public.household_members(household_id);

-- ── organization_members ──────────────────────────────────────
create index idx_org_members_profile        on public.organization_members(profile_id);
create index idx_org_members_org            on public.organization_members(organization_id);

-- ── vendors ───────────────────────────────────────────────────
create index idx_vendors_profile            on public.vendors(profile_id);
create index idx_vendors_status             on public.vendors(status);

-- ── properties ───────────────────────────────────────────────
create index idx_properties_household       on public.properties(household_id);
create index idx_properties_status         on public.properties(status);

-- ── rooms ─────────────────────────────────────────────────────
create index idx_rooms_property             on public.rooms(property_id);

-- ── home_systems ──────────────────────────────────────────────
create index idx_home_systems_property      on public.home_systems(property_id);
create index idx_home_systems_type          on public.home_systems(system_type);

-- ── home_services ─────────────────────────────────────────────
create index idx_home_services_property     on public.home_services(property_id);
create index idx_home_services_vendor       on public.home_services(vendor_id);

-- ── maintenance_tasks ─────────────────────────────────────────
create index idx_maintenance_property       on public.maintenance_tasks(property_id);
create index idx_maintenance_due_date       on public.maintenance_tasks(due_date);
create index idx_maintenance_system        on public.maintenance_tasks(home_system_id);

-- ── projects ──────────────────────────────────────────────────
create index idx_projects_property          on public.projects(property_id);
create index idx_projects_status            on public.projects(status);
create index idx_projects_vendor            on public.projects(vendor_id);

-- ── professional_contacts ─────────────────────────────────────
create index idx_prof_contacts_property     on public.professional_contacts(property_id);
create index idx_prof_contacts_type         on public.professional_contacts(contact_type);

-- ── phonebook_entries ─────────────────────────────────────────
create index idx_phonebook_property         on public.phonebook_entries(property_id);
create index idx_phonebook_vendor           on public.phonebook_entries(vendor_id);

-- ── documents ─────────────────────────────────────────────────
create index idx_documents_property         on public.documents(property_id);
create index idx_documents_category         on public.documents(category);
create index idx_documents_project          on public.documents(project_id);
create index idx_documents_expiry           on public.documents(expiry_date);

-- ── media ─────────────────────────────────────────────────────
create index idx_media_property             on public.media(property_id);
create index idx_media_project              on public.media(project_id);
create index idx_media_room                 on public.media(room_id);

-- ── access_grants ─────────────────────────────────────────────
create index idx_access_grants_property     on public.access_grants(property_id);
create index idx_access_grants_token        on public.access_grants(token);
create index idx_access_grants_vendor       on public.access_grants(vendor_id);

-- ── notes ─────────────────────────────────────────────────────
create index idx_notes_entity               on public.notes(entity_type, entity_id);
create index idx_notes_author               on public.notes(author_id);

-- ── entity_tags ───────────────────────────────────────────────
create index idx_entity_tags_entity         on public.entity_tags(entity_type, entity_id);

-- ── status_history ────────────────────────────────────────────
create index idx_status_history_entity      on public.status_history(entity_type, entity_id);

-- ── audit_log ─────────────────────────────────────────────────
create index idx_audit_log_actor            on public.audit_log(actor_id);
create index idx_audit_log_entity           on public.audit_log(entity_type, entity_id);
create index idx_audit_log_occurred_at      on public.audit_log(occurred_at);

-- ── subscriptions ─────────────────────────────────────────────
create index idx_subscriptions_household    on public.subscriptions(household_id);
create index idx_subscriptions_plan         on public.subscriptions(plan);

-- ── insurance_policies ────────────────────────────────────────
create index idx_insurance_property         on public.insurance_policies(property_id);
create index idx_insurance_expiry           on public.insurance_policies(expiry_date);
create index idx_insurance_status           on public.insurance_policies(status);

-- ── notifications ─────────────────────────────────────────────
create index idx_notifications_recipient    on public.notifications(recipient_id);
create index idx_notifications_status       on public.notifications(status);
create index idx_notifications_property     on public.notifications(property_id);
create index idx_notifications_scheduled    on public.notifications(scheduled_for);
