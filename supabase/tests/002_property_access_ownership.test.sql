begin;

select plan(23);

insert into public.profiles (id, role, first_name, last_name, email)
values
  ('20000000-0000-0000-0001-000000000001', 'homeowner', 'Phase', 'Owner One', 'phase2-owner1@example.homehub'),
  ('20000000-0000-0000-0001-000000000002', 'homeowner', 'Phase', 'Owner Two', 'phase2-owner2@example.homehub'),
  ('20000000-0000-0000-0001-000000000003', 'homeowner', 'Phase', 'Owner Three', 'phase2-owner3@example.homehub'),
  ('20000000-0000-0000-0001-000000000004', 'contractor', 'Phase', 'Manager', 'phase2-manager@example.homehub'),
  ('20000000-0000-0000-0001-000000000005', 'inspector', 'Phase', 'Viewer', 'phase2-viewer@example.homehub'),
  ('20000000-0000-0000-0001-000000000006', 'homeowner', 'Household', 'Only', 'phase2-household@example.homehub'),
  ('20000000-0000-0000-0001-000000000007', 'homeowner', 'Ownership', 'Only', 'phase2-ownership@example.homehub');

insert into public.households (id, name)
values
  ('20000000-0000-0000-0002-000000000001', 'Phase 2 Property Household'),
  ('20000000-0000-0000-0002-000000000002', 'Phase 2 Owner Household');

insert into public.organizations (id, name, org_type)
values ('20000000-0000-0000-0003-000000000001', 'Phase 2 Owner Organization', 'test');

insert into public.properties (id, household_id, address_line1, city, state, zip)
values (
  '20000000-0000-0000-0004-000000000001',
  '20000000-0000-0000-0002-000000000001',
  '1 Foundation Way',
  'Hampstead',
  'NC',
  '28443'
);

select lives_ok(
  $$
    insert into public.property_memberships (
      property_id, profile_id, role, starts_at, accepted_at
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000001',
      'owner',
      '2026-01-01 00:00:00+00',
      '2026-01-01 00:00:00+00'
    )
  $$,
  'a valid current property membership is accepted'
);

select throws_ok(
  $$
    insert into public.property_memberships (property_id, profile_id, role)
    values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000001',
      'viewer'
    )
  $$,
  '23505',
  null,
  'a duplicate current property membership is rejected'
);

insert into public.property_memberships (
  property_id, profile_id, role, starts_at, accepted_at, ends_at
)
values (
  '20000000-0000-0000-0004-000000000001',
  '20000000-0000-0000-0001-000000000002',
  'household_member',
  '2025-01-01 00:00:00+00',
  '2025-01-01 00:00:00+00',
  '2025-12-31 00:00:00+00'
);

select lives_ok(
  $$
    insert into public.property_memberships (
      property_id, profile_id, role, starts_at, accepted_at
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000002',
      'household_member',
      '2026-01-01 00:00:00+00',
      '2026-01-01 00:00:00+00'
    )
  $$,
  'an ended property membership may be followed by a new period'
);

select throws_ok(
  $$
    insert into public.property_memberships (
      property_id, profile_id, role, starts_at, invited_at, accepted_at
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000003',
      'caretaker',
      '2026-01-01 00:00:00+00',
      '2026-02-01 00:00:00+00',
      '2026-01-15 00:00:00+00'
    )
  $$,
  '23514',
  null,
  'property membership acceptance cannot precede invitation'
);

select throws_ok(
  $$
    insert into public.property_memberships (
      property_id, profile_id, role, starts_at, ends_at
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000003',
      'caretaker',
      '2026-02-01 00:00:00+00',
      '2026-01-01 00:00:00+00'
    )
  $$,
  '23514',
  null,
  'property membership cannot end before it starts'
);

select lives_ok(
  $$
    insert into public.property_memberships (property_id, profile_id, role, ends_at)
    values
      ('20000000-0000-0000-0004-000000000001', '20000000-0000-0000-0001-000000000003', 'caretaker', now()),
      ('20000000-0000-0000-0004-000000000001', '20000000-0000-0000-0001-000000000004', 'property_manager', now()),
      ('20000000-0000-0000-0004-000000000001', '20000000-0000-0000-0001-000000000005', 'viewer', now())
  $$,
  'all approved property membership roles are accepted'
);

select throws_ok(
  $$
    insert into public.property_memberships (property_id, profile_id, role)
    values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000003',
      'administrator'
    )
  $$,
  '22P02',
  null,
  'an arbitrary property membership role is rejected'
);

insert into public.household_members (
  household_id, profile_id, role, starts_at, accepted_at
)
values (
  '20000000-0000-0000-0002-000000000001',
  '20000000-0000-0000-0001-000000000006',
  'member',
  '2026-01-01 00:00:00+00',
  '2026-01-01 00:00:00+00'
);

select is(
  (
    select count(*)::bigint
    from public.property_memberships
    where profile_id = '20000000-0000-0000-0001-000000000006'
  ),
  0::bigint,
  'household membership is structurally separate from property membership'
);

select is(
  (
    select count(*)::bigint
    from pg_constraint
    where conrelid = 'public.property_ownership_periods'::regclass
      and conname = 'property_ownership_periods_one_subject_check'
      and contype = 'c'
  ),
  1::bigint,
  'ownership periods require exactly one ownership subject'
);

select throws_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, ownership_type, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001', 'owner', '2026-01-01'
    )
  $$,
  '23514',
  null,
  'an ownership period with no subject is rejected'
);

select throws_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, owner_household_id, ownership_type, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000001',
      '20000000-0000-0000-0002-000000000002',
      'owner',
      '2026-01-01'
    )
  $$,
  '23514',
  null,
  'an ownership period with multiple subjects is rejected'
);

select lives_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000001',
      'owner',
      '2026-01-01'
    )
  $$,
  'a valid profile ownership period is accepted'
);

select lives_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_household_id, ownership_type, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0002-000000000002',
      'owner',
      '2026-01-01'
    )
  $$,
  'a valid household ownership period is accepted'
);

select lives_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_organization_id, ownership_type, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0003-000000000001',
      'owner',
      '2026-01-01'
    )
  $$,
  'a valid organization ownership period is accepted'
);

select throws_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, starts_on, ends_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000003',
      'co_owner',
      '2026-02-01',
      '2026-01-01'
    )
  $$,
  '23514',
  null,
  'an ownership period cannot end before it starts'
);

select throws_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, ownership_percentage, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000003',
      'co_owner',
      0,
      '2026-01-01'
    )
  $$,
  '23514',
  null,
  'an ownership percentage of zero is rejected'
);

select throws_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, ownership_percentage, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000003',
      'co_owner',
      -0.01,
      '2026-01-01'
    )
  $$,
  '23514',
  null,
  'a negative ownership percentage is rejected'
);

select throws_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, ownership_percentage, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000003',
      'co_owner',
      100.01,
      '2026-01-01'
    )
  $$,
  '23514',
  null,
  'an ownership percentage above 100 is rejected'
);

select lives_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, ownership_percentage, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000002',
      'co_owner',
      null,
      '2026-01-01'
    )
  $$,
  'a null ownership percentage is accepted'
);

select lives_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000007',
      'co_owner',
      '2026-01-01'
    )
  $$,
  'multiple different co-owners for one property are accepted'
);

select throws_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000001',
      'co_owner',
      '2026-02-01'
    )
  $$,
  '23505',
  null,
  'a duplicate current ownership period for the same subject is rejected'
);

insert into public.property_ownership_periods (
  property_id, owner_profile_id, ownership_type, starts_on, ends_on
)
values (
  '20000000-0000-0000-0004-000000000001',
  '20000000-0000-0000-0001-000000000004',
  'other',
  '2025-01-01',
  '2025-12-31'
);

select lives_ok(
  $$
    insert into public.property_ownership_periods (
      property_id, owner_profile_id, ownership_type, starts_on
    ) values (
      '20000000-0000-0000-0004-000000000001',
      '20000000-0000-0000-0001-000000000004',
      'other',
      '2026-01-01'
    )
  $$,
  'an ended ownership period may be followed by a new current period'
);

select is(
  (
    select count(*)::bigint
    from public.property_memberships
    where profile_id = '20000000-0000-0000-0001-000000000007'
  ),
  0::bigint,
  'ownership does not create a property membership'
);

select * from finish();

rollback;
