begin;

select plan(35);

insert into public.profiles (id, role, first_name, last_name, email)
values ('40000000-0000-0000-0001-000000000001', 'homeowner', 'Phase', 'Owner', 'phase4-owner@example.homehub');

insert into public.households (id, name)
values
  ('40000000-0000-0000-0002-000000000001', 'Phase 4 Household A'),
  ('40000000-0000-0000-0002-000000000002', 'Phase 4 Household B');

insert into public.properties (id, household_id, address_line1, city, state, zip)
values
  ('40000000-0000-0000-0003-000000000001', '40000000-0000-0000-0002-000000000001', '1 Scope Way', 'Hampstead', 'NC', '28443'),
  ('40000000-0000-0000-0003-000000000002', '40000000-0000-0000-0002-000000000002', '2 Scope Way', 'Hampstead', 'NC', '28443');

insert into public.rooms (id, property_id, name)
values
  ('40000000-0000-0000-0004-000000000001', '40000000-0000-0000-0003-000000000001', 'Room A'),
  ('40000000-0000-0000-0004-000000000002', '40000000-0000-0000-0003-000000000002', 'Room B');

insert into public.home_systems (id, property_id, system_type, name)
values
  ('40000000-0000-0000-0005-000000000001', '40000000-0000-0000-0003-000000000001', 'hvac', 'System A'),
  ('40000000-0000-0000-0005-000000000002', '40000000-0000-0000-0003-000000000002', 'hvac', 'System B');

insert into public.projects (id, property_id, title)
values
  ('40000000-0000-0000-0006-000000000001', '40000000-0000-0000-0003-000000000001', 'Project A'),
  ('40000000-0000-0000-0006-000000000002', '40000000-0000-0000-0003-000000000002', 'Project B');

insert into public.documents (id, property_id, title, storage_path, file_name)
values
  ('40000000-0000-0000-0007-000000000001', '40000000-0000-0000-0003-000000000001', 'Document A', 'phase4/document-a', 'document-a.pdf'),
  ('40000000-0000-0000-0007-000000000002', '40000000-0000-0000-0003-000000000002', 'Document B', 'phase4/document-b', 'document-b.pdf');

select is((select count(*)::bigint from pg_constraint where conrelid = 'public.rooms'::regclass and conname = 'rooms_property_id_id_key' and contype = 'u'), 1::bigint, 'rooms has a property-scoped candidate key');
select is((select count(*)::bigint from pg_constraint where conrelid = 'public.home_systems'::regclass and conname = 'home_systems_property_id_id_key' and contype = 'u'), 1::bigint, 'home_systems has a property-scoped candidate key');
select is((select count(*)::bigint from pg_constraint where conrelid = 'public.projects'::regclass and conname = 'projects_property_id_id_key' and contype = 'u'), 1::bigint, 'projects has a property-scoped candidate key');
select is((select count(*)::bigint from pg_constraint where conrelid = 'public.documents'::regclass and conname = 'documents_property_id_id_key' and contype = 'u'), 1::bigint, 'documents has a property-scoped candidate key');

select lives_ok($$insert into public.maintenance_tasks (property_id, home_system_id, title) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0005-000000000001','Same-property system')$$, 'maintenance task accepts a same-property home system');
select throws_ok($$insert into public.maintenance_tasks (property_id, home_system_id, title) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0005-000000000002','Cross-property system')$$, '23503', null, 'maintenance task rejects a cross-property home system');
select lives_ok($$insert into public.maintenance_tasks (property_id, home_system_id, title) values ('40000000-0000-0000-0003-000000000001',null,'No system')$$, 'maintenance task accepts a null home system');

select lives_ok($$insert into public.projects (property_id, room_id, title) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0004-000000000001','Same-property room')$$, 'project accepts a same-property room');
select throws_ok($$insert into public.projects (property_id, room_id, title) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0004-000000000002','Cross-property room')$$, '23503', null, 'project rejects a cross-property room');
select lives_ok($$insert into public.projects (property_id, room_id, title) values ('40000000-0000-0000-0003-000000000001',null,'No room')$$, 'project accepts a null room');
select lives_ok($$insert into public.projects (property_id, home_system_id, title) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0005-000000000001','Same-property system')$$, 'project accepts a same-property home system');
select throws_ok($$insert into public.projects (property_id, home_system_id, title) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0005-000000000002','Cross-property system')$$, '23503', null, 'project rejects a cross-property home system');
select lives_ok($$insert into public.projects (property_id, home_system_id, title) values ('40000000-0000-0000-0003-000000000001',null,'No system')$$, 'project accepts a null home system');

select lives_ok($$insert into public.documents (property_id, project_id, title, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0006-000000000001','Same project','phase4/doc-project-ok','ok.pdf')$$, 'document accepts a same-property project');
select throws_ok($$insert into public.documents (property_id, project_id, title, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0006-000000000002','Cross project','phase4/doc-project-bad','bad.pdf')$$, '23503', null, 'document rejects a cross-property project');
select lives_ok($$insert into public.documents (property_id, project_id, title, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001',null,'No project','phase4/doc-project-null','null.pdf')$$, 'document accepts a null project');
select lives_ok($$insert into public.documents (property_id, home_system_id, title, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0005-000000000001','Same system','phase4/doc-system-ok','ok.pdf')$$, 'document accepts a same-property home system');
select throws_ok($$insert into public.documents (property_id, home_system_id, title, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0005-000000000002','Cross system','phase4/doc-system-bad','bad.pdf')$$, '23503', null, 'document rejects a cross-property home system');
select lives_ok($$insert into public.documents (property_id, home_system_id, title, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001',null,'No system','phase4/doc-system-null','null.pdf')$$, 'document accepts a null home system');

select lives_ok($$insert into public.media (property_id, room_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0004-000000000001','phase4/media-room-ok','ok.jpg')$$, 'media accepts a same-property room');
select throws_ok($$insert into public.media (property_id, room_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0004-000000000002','phase4/media-room-bad','bad.jpg')$$, '23503', null, 'media rejects a cross-property room');
select lives_ok($$insert into public.media (property_id, room_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001',null,'phase4/media-room-null','null.jpg')$$, 'media accepts a null room');
select lives_ok($$insert into public.media (property_id, project_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0006-000000000001','phase4/media-project-ok','ok.jpg')$$, 'media accepts a same-property project');
select throws_ok($$insert into public.media (property_id, project_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0006-000000000002','phase4/media-project-bad','bad.jpg')$$, '23503', null, 'media rejects a cross-property project');
select lives_ok($$insert into public.media (property_id, project_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001',null,'phase4/media-project-null','null.jpg')$$, 'media accepts a null project');
select lives_ok($$insert into public.media (property_id, home_system_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0005-000000000001','phase4/media-system-ok','ok.jpg')$$, 'media accepts a same-property home system');
select throws_ok($$insert into public.media (property_id, home_system_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0005-000000000002','phase4/media-system-bad','bad.jpg')$$, '23503', null, 'media rejects a cross-property home system');
select lives_ok($$insert into public.media (property_id, home_system_id, storage_path, file_name) values ('40000000-0000-0000-0003-000000000001',null,'phase4/media-system-null','null.jpg')$$, 'media accepts a null home system');

select lives_ok($$insert into public.insurance_policies (property_id, document_id, insurer_name, policy_type) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0007-000000000001','Test Insurer','homeowners')$$, 'insurance policy accepts a same-property document');
select throws_ok($$insert into public.insurance_policies (property_id, document_id, insurer_name, policy_type) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0007-000000000002','Test Insurer','homeowners')$$, '23503', null, 'insurance policy rejects a cross-property document');
select lives_ok($$insert into public.insurance_policies (property_id, document_id, insurer_name, policy_type) values ('40000000-0000-0000-0003-000000000001',null,'Test Insurer','homeowners')$$, 'insurance policy accepts a null document');

select lives_ok($$insert into public.property_ownership_periods (property_id, owner_profile_id, evidence_document_id, ownership_type, starts_on) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0001-000000000001','40000000-0000-0000-0007-000000000001','owner','2026-01-01')$$, 'ownership period accepts a same-property evidence document');
select throws_ok($$insert into public.property_ownership_periods (property_id, owner_profile_id, evidence_document_id, ownership_type, starts_on, ends_on) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0001-000000000001','40000000-0000-0000-0007-000000000002','owner','2026-02-01','2026-02-02')$$, '23503', null, 'ownership period rejects a cross-property evidence document');
select lives_ok($$insert into public.property_ownership_periods (property_id, owner_profile_id, evidence_document_id, ownership_type, starts_on, ends_on) values ('40000000-0000-0000-0003-000000000001','40000000-0000-0000-0001-000000000001',null,'owner','2025-01-01','2025-12-31')$$, 'ownership period accepts a null evidence document');

select is(
  (select count(*)::bigint from pg_constraint where conname in (
    'maintenance_tasks_property_home_system_fkey', 'projects_property_room_fkey',
    'projects_property_home_system_fkey', 'documents_property_project_fkey',
    'documents_property_home_system_fkey', 'media_property_room_fkey',
    'media_property_project_fkey', 'media_property_home_system_fkey',
    'insurance_policies_property_document_fkey',
    'property_ownership_periods_property_evidence_document_fkey'
  ) and contype = 'f'),
  10::bigint,
  'all cross-property rules are declarative foreign keys rather than triggers'
);

select * from finish();

rollback;
