begin;

select plan(78);

insert into auth.users (id,aud,role,email,encrypted_password,created_at,updated_at)
values ('80000000-0000-0000-0000-000000000003','authenticated','authenticated','phase8-auth@example.homehub','',now(),now());

insert into public.profiles (id,auth_user_id,role,first_name,last_name,email)
values
 ('80000000-0000-0000-0000-000000000001',null,'homeowner','History','Subject','phase8-subject@example.homehub'),
 ('80000000-0000-0000-0000-000000000002',null,'homeowner','History','Actor','phase8-actor@example.homehub'),
 ('80000000-0000-0000-0000-000000000003','80000000-0000-0000-0000-000000000003','homeowner','Auth','Subject','phase8-auth@example.homehub'),
 ('80000000-0000-0000-0000-000000000004',null,'homeowner','Notify','Subject','phase8-notify@example.homehub');

insert into public.households (id,name) values
 ('80000000-0000-0000-0002-000000000001','Phase 8 History'),
 ('80000000-0000-0000-0002-000000000002','Phase 8 Notification');
insert into public.organizations (id,name,org_type) values ('80000000-0000-0000-0003-000000000001','Phase 8 Organization','service_business');
insert into public.vendors (id,business_name,review_count) values ('80000000-0000-0000-0003-000000000002','Phase 8 Vendor',0);
insert into public.properties (id,household_id,address_line1,city,state,zip,year_built,square_feet,lot_size_sqft,bedrooms,bathrooms,purchase_price,current_value)
values
 ('80000000-0000-0000-0004-000000000001','80000000-0000-0000-0002-000000000001','8 History Way','Hampstead','NC','28443',2020,1000,2000,3,2,100000,120000),
 ('80000000-0000-0000-0004-000000000002','80000000-0000-0000-0002-000000000002','9 Notify Way','Hampstead','NC','28443',2021,1000,2000,3,2,100000,120000);
insert into public.household_members (id,household_id,profile_id) values ('80000000-0000-0000-0005-000000000001','80000000-0000-0000-0002-000000000001','80000000-0000-0000-0000-000000000001');
insert into public.organization_members (id,organization_id,profile_id) values ('80000000-0000-0000-0005-000000000002','80000000-0000-0000-0003-000000000001','80000000-0000-0000-0000-000000000001');
insert into public.rooms (id,property_id,name,square_feet) values ('80000000-0000-0000-0005-000000000003','80000000-0000-0000-0004-000000000001','Room',100);
insert into public.home_systems (id,property_id,system_type,name,last_service,next_service) values ('80000000-0000-0000-0006-000000000001','80000000-0000-0000-0004-000000000001','hvac','HVAC','2026-01-01','2026-02-01');
insert into public.home_services (id,property_id,service_type,price_per_visit,monthly_cost) values ('80000000-0000-0000-0007-000000000001','80000000-0000-0000-0004-000000000001','cleaning',10,20);
insert into public.maintenance_tasks (id,property_id,title,estimated_cost,actual_cost) values ('80000000-0000-0000-0008-000000000001','80000000-0000-0000-0004-000000000001','Task',10,20);
insert into public.projects (id,property_id,title,start_date,end_date,estimated_cost,actual_cost) values ('80000000-0000-0000-0009-000000000001','80000000-0000-0000-0004-000000000001','Project','2026-01-01','2026-02-01',10,20);
insert into public.professional_contacts (id,property_id,contact_type,name) values ('80000000-0000-0000-0010-000000000001','80000000-0000-0000-0004-000000000001','inspector','Inspector');
insert into public.phonebook_entries (id,property_id,name) values ('80000000-0000-0000-0011-000000000001','80000000-0000-0000-0004-000000000001','Plumber');
insert into public.documents (id,property_id,title,storage_path,file_name) values ('80000000-0000-0000-0012-000000000001','80000000-0000-0000-0004-000000000001','Document','properties/80000000-0000-0000-0004-000000000001/documents/80000000-0000-0000-0012-000000000001/document.pdf','document.pdf');
insert into public.media (id,property_id,storage_path,file_name) values ('80000000-0000-0000-0013-000000000001','80000000-0000-0000-0004-000000000001','properties/80000000-0000-0000-0004-000000000001/media/80000000-0000-0000-0013-000000000001/photo.jpg','photo.jpg');
insert into public.notes (id,entity_type,entity_id,body) values ('80000000-0000-0000-0014-000000000001','property','80000000-0000-0000-0004-000000000001','Note');
insert into public.tags (id,property_id,name) values ('80000000-0000-0000-0015-000000000001','80000000-0000-0000-0004-000000000001','Tag');
insert into public.entity_tags (id,tag_id,entity_type,entity_id) values ('80000000-0000-0000-0015-000000000002','80000000-0000-0000-0015-000000000001','property','80000000-0000-0000-0004-000000000001');
insert into public.status_history (id,entity_type,entity_id,to_status) values ('80000000-0000-0000-0016-000000000001','property','80000000-0000-0000-0004-000000000001','active');
insert into public.notifications (id,recipient_id,type,title,property_id) values ('80000000-0000-0000-0017-000000000001','80000000-0000-0000-0000-000000000004','system_alert','Notification','80000000-0000-0000-0004-000000000002');

select has_column('public','properties','archived_at','properties has archived_at');
select has_column('public','documents','deleted_at','documents has deleted_at');
select has_column('public','media','deleted_at','media has deleted_at');
select has_column('public','tags','updated_at','tags has the column required by its existing update trigger');
select ok(col_description('public.properties'::regclass,(select attnum from pg_attribute where attrelid='public.properties'::regclass and attname='archived_at')) is not null,'properties archival semantics are documented');
select ok(col_description('public.documents'::regclass,(select attnum from pg_attribute where attrelid='public.documents'::regclass and attname='deleted_at')) is not null,'document soft-delete semantics are documented');
select ok(col_description('public.media'::regclass,(select attnum from pg_attribute where attrelid='public.media'::regclass and attname='deleted_at')) is not null,'media soft-delete semantics are documented');

select throws_ok($$update public.properties set archived_at=now() where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'archive timestamp without archived status is rejected');
select throws_ok($$update public.properties set status='archived' where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'archived status without archive timestamp is rejected');
select lives_ok($$update public.properties set status='archived',archived_at=now() where id='80000000-0000-0000-0004-000000000001'$$,'consistent property archival is accepted');
select is((select count(*)::bigint from public.properties where id='80000000-0000-0000-0004-000000000001'),1::bigint,'archived property remains stored');
select lives_ok($$update public.documents set deleted_at=now() where id='80000000-0000-0000-0012-000000000001'$$,'document soft deletion is accepted');
select is((select count(*)::bigint from public.documents where id='80000000-0000-0000-0012-000000000001'),1::bigint,'soft-deleted document remains stored');
select lives_ok($$update public.media set deleted_at=now() where id='80000000-0000-0000-0013-000000000001'$$,'media soft deletion is accepted');
select is((select count(*)::bigint from public.media where id='80000000-0000-0000-0013-000000000001'),1::bigint,'soft-deleted media remains stored');

select lives_ok($$delete from auth.users where id='80000000-0000-0000-0000-000000000003'$$,'auth identity deletion is allowed');
select is((select count(*)::bigint from public.profiles where id='80000000-0000-0000-0000-000000000003'),1::bigint,'auth deletion retains profile');
select is((select auth_user_id from public.profiles where id='80000000-0000-0000-0000-000000000003'),null::uuid,'auth deletion clears only auth link');
select lives_ok($$delete from public.profiles where id='80000000-0000-0000-0000-000000000004'$$,'notification recipient profile can be removed');
select is((select count(*)::bigint from public.notifications where id='80000000-0000-0000-0017-000000000001'),1::bigint,'recipient deletion retains notification');
select is((select recipient_id from public.notifications where id='80000000-0000-0000-0017-000000000001'),null::uuid,'recipient deletion nulls notification actor');
select lives_ok($$delete from public.properties where id='80000000-0000-0000-0004-000000000002'$$,'notification-only property can be physically removed');
select is((select count(*)::bigint from public.notifications where id='80000000-0000-0000-0017-000000000001'),1::bigint,'property deletion retains notification');
select is((select property_id from public.notifications where id='80000000-0000-0000-0017-000000000001'),null::uuid,'property deletion nulls notification reference');
select throws_ok($$delete from public.profiles where id='80000000-0000-0000-0000-000000000001'$$,'23503',null,'historical membership blocks profile deletion');
select throws_ok($$delete from public.households where id='80000000-0000-0000-0002-000000000001'$$,'23503',null,'historical membership/property blocks household deletion');
select throws_ok($$delete from public.organizations where id='80000000-0000-0000-0003-000000000001'$$,'23503',null,'historical organization membership blocks organization deletion');
select throws_ok($$delete from public.properties where id='80000000-0000-0000-0004-000000000001'$$,'23503',null,'historical property records block physical property deletion');

select is((select count(*)::bigint from pg_constraint where connamespace='public'::regnamespace and contype='f' and confdeltype='r' and conname in ('properties_household_id_fkey','household_members_household_id_fkey','household_members_profile_id_fkey','organization_members_organization_id_fkey','organization_members_profile_id_fkey','maintenance_tasks_property_id_fkey','projects_property_id_fkey','documents_property_id_fkey','media_property_id_fkey')),9::bigint,'Phase 8 historical foreign keys use RESTRICT');
select is((select count(*)::bigint from pg_constraint where connamespace='public'::regnamespace and contype='f' and confdeltype='n' and conname in ('notifications_recipient_id_fkey','notifications_property_id_fkey','audit_log_actor_id_fkey','access_grant_log_used_by_fkey')),4::bigint,'notification and audit actors use SET NULL');

select throws_ok($$update public.vendors set review_count=-1 where id='80000000-0000-0000-0003-000000000002'$$,'23514',null,'negative review count is rejected');
select throws_ok($$update public.properties set year_built=0 where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'nonpositive construction year is rejected');
select throws_ok($$update public.properties set square_feet=-1 where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'negative property square feet is rejected');
select throws_ok($$update public.properties set lot_size_sqft=-1 where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'negative lot size is rejected');
select throws_ok($$update public.properties set bedrooms=-1 where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'negative bedroom count is rejected');
select throws_ok($$update public.properties set bathrooms=-1 where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'negative bathroom count is rejected');
select throws_ok($$update public.properties set purchase_price=-1 where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'negative purchase price is rejected');
select throws_ok($$update public.properties set current_value=-1 where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'negative current value is rejected');
select throws_ok($$update public.rooms set square_feet=-1 where id='80000000-0000-0000-0005-000000000003'$$,'23514',null,'negative room square feet is rejected');
select throws_ok($$update public.home_services set price_per_visit=-1 where id='80000000-0000-0000-0007-000000000001'$$,'23514',null,'negative visit price is rejected');
select throws_ok($$update public.home_services set monthly_cost=-1 where id='80000000-0000-0000-0007-000000000001'$$,'23514',null,'negative monthly service cost is rejected');
select throws_ok($$update public.maintenance_tasks set estimated_cost=-1 where id='80000000-0000-0000-0008-000000000001'$$,'23514',null,'negative maintenance estimate is rejected');
select throws_ok($$update public.maintenance_tasks set actual_cost=-1 where id='80000000-0000-0000-0008-000000000001'$$,'23514',null,'negative maintenance actual cost is rejected');
select throws_ok($$update public.projects set estimated_cost=-1 where id='80000000-0000-0000-0009-000000000001'$$,'23514',null,'negative project estimate is rejected');
select throws_ok($$update public.projects set actual_cost=-1 where id='80000000-0000-0000-0009-000000000001'$$,'23514',null,'negative project actual cost is rejected');
select throws_ok($$update public.projects set end_date='2025-01-01' where id='80000000-0000-0000-0009-000000000001'$$,'23514',null,'project end before start is rejected');
select throws_ok($$update public.home_systems set next_service='2025-01-01' where id='80000000-0000-0000-0006-000000000001'$$,'23514',null,'next service before last service is rejected');
select lives_ok($$update public.properties set square_feet=0,current_value=0 where id='80000000-0000-0000-0004-000000000001'$$,'zero-valued nonnegative property metrics are accepted');

select throws_ok($$update public.households set name=' ' where id='80000000-0000-0000-0002-000000000001'$$,'23514',null,'blank household name is rejected');
select throws_ok($$update public.organizations set name=' ' where id='80000000-0000-0000-0003-000000000001'$$,'23514',null,'blank organization name is rejected');
select throws_ok($$update public.organizations set org_type=' ' where id='80000000-0000-0000-0003-000000000001'$$,'23514',null,'blank organization type is rejected');
select throws_ok($$update public.vendors set business_name=' ' where id='80000000-0000-0000-0003-000000000002'$$,'23514',null,'blank vendor name is rejected');
select throws_ok($$update public.properties set address_line1=' ' where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'blank property address is rejected');
select throws_ok($$update public.properties set city=' ' where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'blank property city is rejected');
select throws_ok($$update public.properties set state=' ' where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'blank property state is rejected');
select throws_ok($$update public.properties set zip=' ' where id='80000000-0000-0000-0004-000000000001'$$,'23514',null,'blank property zip is rejected');
select throws_ok($$update public.rooms set name=' ' where id='80000000-0000-0000-0005-000000000003'$$,'23514',null,'blank room name is rejected');
select throws_ok($$update public.home_systems set system_type=' ' where id='80000000-0000-0000-0006-000000000001'$$,'23514',null,'blank system type is rejected');
select throws_ok($$update public.home_systems set name=' ' where id='80000000-0000-0000-0006-000000000001'$$,'23514',null,'blank system name is rejected');
select throws_ok($$update public.home_services set service_type=' ' where id='80000000-0000-0000-0007-000000000001'$$,'23514',null,'blank service type is rejected');
select throws_ok($$update public.maintenance_tasks set title=' ' where id='80000000-0000-0000-0008-000000000001'$$,'23514',null,'blank maintenance title is rejected');
select throws_ok($$update public.projects set title=' ' where id='80000000-0000-0000-0009-000000000001'$$,'23514',null,'blank project title is rejected');
select throws_ok($$update public.professional_contacts set contact_type=' ' where id='80000000-0000-0000-0010-000000000001'$$,'23514',null,'blank professional contact type is rejected');
select throws_ok($$update public.professional_contacts set name=' ' where id='80000000-0000-0000-0010-000000000001'$$,'23514',null,'blank professional contact name is rejected');
select throws_ok($$update public.phonebook_entries set name=' ' where id='80000000-0000-0000-0011-000000000001'$$,'23514',null,'blank phonebook name is rejected');
select throws_ok($$update public.documents set title=' ' where id='80000000-0000-0000-0012-000000000001'$$,'23514',null,'blank document title is rejected');
select throws_ok($$update public.notes set entity_type=' ' where id='80000000-0000-0000-0014-000000000001'$$,'23514',null,'blank note entity type is rejected');
select throws_ok($$update public.notes set body=' ' where id='80000000-0000-0000-0014-000000000001'$$,'23514',null,'blank note body is rejected');
select throws_ok($$update public.tags set name=' ' where id='80000000-0000-0000-0015-000000000001'$$,'23514',null,'blank tag name is rejected');
select throws_ok($$update public.entity_tags set entity_type=' ' where id='80000000-0000-0000-0015-000000000002'$$,'23514',null,'blank tagged entity type is rejected');
select throws_ok($$update public.status_history set entity_type=' ' where id='80000000-0000-0000-0016-000000000001'$$,'23514',null,'blank status entity type is rejected');
select throws_ok($$update public.status_history set to_status=' ' where id='80000000-0000-0000-0016-000000000001'$$,'23514',null,'blank target status is rejected');
select throws_ok($$update public.notifications set title=' ' where id='80000000-0000-0000-0017-000000000001'$$,'23514',null,'blank notification title is rejected');

select is((select count(*)::bigint from pg_indexes where schemaname='public' and indexname in ('properties_unarchived_household_idx','documents_active_property_idx','media_active_property_idx','property_memberships_history_property_idx','property_memberships_history_profile_idx','property_ownership_periods_owner_profile_idx','property_ownership_periods_owner_household_idx','property_ownership_periods_owner_organization_idx','property_ownership_periods_evidence_document_idx','property_ownership_periods_recorded_by_idx','platform_staff_roles_profile_history_idx','idx_documents_uploaded_by','idx_documents_home_system','idx_documents_vendor','idx_media_uploaded_by','idx_media_home_system','idx_maintenance_vendor','idx_prof_contacts_profile','idx_vendors_organization','idx_access_grant_log_used_by','idx_subscriptions_gifted_by_profile','idx_subscriptions_sponsor_organization','idx_insurance_document')),23::bigint,'all deliberate Phase 8 indexes exist');
select is((select count(*)::bigint from pg_indexes where schemaname='public' and indexname in ('idx_rooms_property','idx_home_systems_property','idx_projects_property','idx_documents_property','idx_profiles_auth_user_id','idx_profiles_email')),0::bigint,'provably redundant indexes are absent');
select is((select count(*)::bigint from pg_indexes where schemaname='public' and indexname in ('household_members_one_current_membership_idx','organization_members_one_current_membership_idx','property_memberships_one_current_membership_idx','platform_staff_roles_one_active_role_idx','subscriptions_one_current_household_idx','subscription_gift_claims_one_open_idx')),6::bigint,'current-state partial uniqueness remains intact');
select is((select count(*)::bigint from pg_constraint where conname in ('documents_property_id_id_key','projects_property_id_id_key','access_grants_property_document_fkey','subscription_gift_claims_subscription_fkey','documents_storage_path_key')),5::bigint,'Phases 4 through 7 structural invariants remain intact');
select is((select count(*)::bigint from information_schema.table_constraints where constraint_schema='public' and table_name in ('notes','entity_tags','status_history','audit_log') and constraint_type='FOREIGN KEY' and constraint_name not like '%actor%' and constraint_name not like '%author%' and constraint_name not like '%changed_by%'),1::bigint,'generic references remain deliberately polymorphic without fabricated entity foreign keys');

select * from finish();
rollback;
