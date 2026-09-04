begin;

select plan(35);

select has_column('public', 'household_members', 'created_at', 'household memberships have created_at');
select has_column('public', 'household_members', 'updated_at', 'household memberships have updated_at');
select has_column('public', 'organization_members', 'created_at', 'organization memberships have created_at');
select has_column('public', 'organization_members', 'updated_at', 'organization memberships have updated_at');

select col_type_is('public', 'household_members', 'created_at', 'timestamp with time zone', 'household created_at is timestamptz');
select col_type_is('public', 'household_members', 'updated_at', 'timestamp with time zone', 'household updated_at is timestamptz');
select col_type_is('public', 'organization_members', 'created_at', 'timestamp with time zone', 'organization created_at is timestamptz');
select col_type_is('public', 'organization_members', 'updated_at', 'timestamp with time zone', 'organization updated_at is timestamptz');

select col_not_null('public', 'household_members', 'created_at', 'household created_at is required');
select col_not_null('public', 'household_members', 'updated_at', 'household updated_at is required');
select col_not_null('public', 'organization_members', 'created_at', 'organization created_at is required');
select col_not_null('public', 'organization_members', 'updated_at', 'organization updated_at is required');

select ok((select column_default is not null from information_schema.columns where table_schema = 'public' and table_name = 'household_members' and column_name = 'created_at'), 'household created_at has a default');
select ok((select column_default is not null from information_schema.columns where table_schema = 'public' and table_name = 'household_members' and column_name = 'updated_at'), 'household updated_at has a default');
select ok((select column_default is not null from information_schema.columns where table_schema = 'public' and table_name = 'organization_members' and column_name = 'created_at'), 'organization created_at has a default');
select ok((select column_default is not null from information_schema.columns where table_schema = 'public' and table_name = 'organization_members' and column_name = 'updated_at'), 'organization updated_at has a default');

select has_trigger('public', 'household_members', 'trg_household_members_updated_at', 'household update trigger remains installed');
select has_trigger('public', 'organization_members', 'trg_organization_members_updated_at', 'organization update trigger remains installed');
select ok(
  exists (select 1 from pg_constraint where conrelid = 'public.household_members'::regclass and conname = 'household_members_timestamp_order_check' and contype = 'c'),
  'household timestamp chronology is constrained'
);
select ok(
  exists (select 1 from pg_constraint where conrelid = 'public.organization_members'::regclass and conname = 'organization_members_timestamp_order_check' and contype = 'c'),
  'organization timestamp chronology is constrained'
);

select is(
  (select count(*)::bigint from public.household_members where created_at is not null and updated_at is not null),
  (select count(*)::bigint from public.household_members),
  'pre-existing canonical household memberships were backfilled'
);

insert into public.profiles (id, role, first_name, last_name, email)
values
  ('90000000-0000-0000-0000-000000000001', 'homeowner', 'Timestamp', 'Household Default', 'phase9-hh-default@example.homehub'),
  ('90000000-0000-0000-0000-000000000002', 'homeowner', 'Timestamp', 'Household Update', 'phase9-hh-update@example.homehub'),
  ('90000000-0000-0000-0000-000000000003', 'contractor', 'Timestamp', 'Organization Default', 'phase9-org-default@example.homehub'),
  ('90000000-0000-0000-0000-000000000004', 'contractor', 'Timestamp', 'Organization Update', 'phase9-org-update@example.homehub');

insert into public.households (id, name)
values ('90000000-0000-0000-0001-000000000001', 'Timestamp Repair Household');

insert into public.organizations (id, name, org_type)
values ('90000000-0000-0000-0002-000000000001', 'Timestamp Repair Organization', 'service_business');

select lives_ok(
  $$insert into public.household_members (id, household_id, profile_id, role) values ('90000000-0000-0000-0003-000000000001', '90000000-0000-0000-0001-000000000001', '90000000-0000-0000-0000-000000000001', 'member')$$,
  'valid household membership insert receives defaults'
);
select ok((select created_at is not null and updated_at is not null from public.household_members where id = '90000000-0000-0000-0003-000000000001'), 'household insert receives both timestamps');

insert into public.household_members (id, household_id, profile_id, role, created_at, updated_at)
values ('90000000-0000-0000-0003-000000000002', '90000000-0000-0000-0001-000000000001', '90000000-0000-0000-0000-000000000002', 'member', '2000-01-01 00:00:00+00', '2000-01-01 00:00:00+00');
select lives_ok($$update public.household_members set role = 'caretaker' where id = '90000000-0000-0000-0003-000000000002'$$, 'household role update succeeds');
select is((select created_at from public.household_members where id = '90000000-0000-0000-0003-000000000002'), '2000-01-01 00:00:00+00'::timestamptz, 'household created_at is unchanged by update');
select ok((select updated_at > '2000-01-01 00:00:00+00'::timestamptz from public.household_members where id = '90000000-0000-0000-0003-000000000002'), 'household updated_at advances without sleeping');
select is((select role from public.household_members where id = '90000000-0000-0000-0003-000000000002'), 'caretaker'::public.household_member_role, 'household lifecycle change persists');
select ok((select updated_at >= created_at from public.household_members where id = '90000000-0000-0000-0003-000000000002'), 'household timestamp order remains valid');

select lives_ok(
  $$insert into public.organization_members (id, organization_id, profile_id, member_role) values ('90000000-0000-0000-0004-000000000001', '90000000-0000-0000-0002-000000000001', '90000000-0000-0000-0000-000000000003', 'member')$$,
  'valid organization membership insert receives defaults'
);
select ok((select created_at is not null and updated_at is not null from public.organization_members where id = '90000000-0000-0000-0004-000000000001'), 'organization insert receives both timestamps');

insert into public.organization_members (id, organization_id, profile_id, member_role, created_at, updated_at)
values ('90000000-0000-0000-0004-000000000002', '90000000-0000-0000-0002-000000000001', '90000000-0000-0000-0000-000000000004', 'member', '2000-01-01 00:00:00+00', '2000-01-01 00:00:00+00');
select lives_ok($$update public.organization_members set member_role = 'agent' where id = '90000000-0000-0000-0004-000000000002'$$, 'organization role update succeeds');
select is((select created_at from public.organization_members where id = '90000000-0000-0000-0004-000000000002'), '2000-01-01 00:00:00+00'::timestamptz, 'organization created_at is unchanged by update');
select ok((select updated_at > '2000-01-01 00:00:00+00'::timestamptz from public.organization_members where id = '90000000-0000-0000-0004-000000000002'), 'organization updated_at advances without sleeping');
select is((select member_role from public.organization_members where id = '90000000-0000-0000-0004-000000000002'), 'agent'::public.organization_member_role, 'organization lifecycle change persists');
select ok((select updated_at >= created_at from public.organization_members where id = '90000000-0000-0000-0004-000000000002'), 'organization timestamp order remains valid');

select * from finish();
rollback;
