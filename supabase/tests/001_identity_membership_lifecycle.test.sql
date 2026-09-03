begin;

select plan(18);

insert into auth.users (id, aud, role, email, encrypted_password, created_at, updated_at)
values (
  '10000000-0000-0000-0000-000000000001',
  'authenticated',
  'authenticated',
  'phase1-auth@example.homehub',
  '',
  now(),
  now()
);

insert into public.profiles (
  id, auth_user_id, role, first_name, last_name, email
)
values (
  '10000000-0000-0000-0001-000000000001',
  '10000000-0000-0000-0000-000000000001',
  'homeowner',
  'Auth',
  'Owner',
  'phase1-owner@example.homehub'
);

select throws_ok(
  $$
    insert into public.profiles (
      id, auth_user_id, role, first_name, last_name, email
    ) values (
      '10000000-0000-0000-0001-000000000002',
      '10000000-0000-0000-0000-000000000001',
      'homeowner',
      'Duplicate',
      'Identity',
      'phase1-duplicate@example.homehub'
    )
  $$,
  '23505',
  null,
  'duplicate auth_user_id is rejected'
);

select lives_ok(
  $$
    insert into public.profiles (
      id, role, first_name, last_name, email
    ) values (
      '10000000-0000-0000-0001-000000000003',
      'contractor',
      'Invited',
      'Person',
      'phase1-invited@example.homehub'
    )
  $$,
  'a profile without an auth account is permitted'
);

select lives_ok(
  $$
    insert into public.profiles (
      id, role, first_name, last_name, email, is_active, deactivated_at
    ) values (
      '10000000-0000-0000-0001-000000000004',
      'inspector',
      'Former',
      'Person',
      'phase1-deactivated@example.homehub',
      false,
      now()
    )
  $$,
  'a deactivated profile is retained'
);

select is(
  (
    select count(*)::bigint
    from public.profiles
    where id = '10000000-0000-0000-0001-000000000004'
      and is_active = false
      and deactivated_at is not null
  ),
  1::bigint,
  'the deactivated profile row remains queryable'
);

select throws_ok(
  $$
    insert into public.profiles (
      id, role, first_name, last_name, email, is_active, deactivated_at
    ) values (
      '10000000-0000-0000-0001-000000000005',
      'inspector',
      'Invalid',
      'Active',
      'phase1-invalid-active@example.homehub',
      true,
      now()
    )
  $$,
  '23514',
  null,
  'a deactivated profile cannot remain active'
);

select throws_ok(
  $$
    insert into public.profiles (
      id, role, first_name, last_name, email, is_active, created_at, deactivated_at
    ) values (
      '10000000-0000-0000-0001-000000000006',
      'inspector',
      'Invalid',
      'Timeline',
      'phase1-invalid-timeline@example.homehub',
      false,
      '2026-02-01 00:00:00+00',
      '2026-01-01 00:00:00+00'
    )
  $$,
  '23514',
  null,
  'profile deactivation cannot precede profile creation'
);

insert into public.households (id, name)
values ('10000000-0000-0000-0002-000000000001', 'Phase 1 Test Household');

insert into public.household_members (
  household_id, profile_id, role, starts_at, accepted_at, is_primary
)
values (
  '10000000-0000-0000-0002-000000000001',
  '10000000-0000-0000-0001-000000000001',
  'member',
  '2026-01-01 00:00:00+00',
  '2026-01-01 00:00:00+00',
  true
);

select throws_ok(
  $$
    insert into public.household_members (
      household_id, profile_id, role, starts_at
    ) values (
      '10000000-0000-0000-0002-000000000001',
      '10000000-0000-0000-0001-000000000001',
      'member',
      '2026-02-01 00:00:00+00'
    )
  $$,
  '23505',
  null,
  'duplicate current household membership is rejected'
);

insert into public.household_members (
  household_id, profile_id, role, starts_at, accepted_at, ends_at
)
values (
  '10000000-0000-0000-0002-000000000001',
  '10000000-0000-0000-0001-000000000003',
  'caretaker',
  '2025-01-01 00:00:00+00',
  '2025-01-01 00:00:00+00',
  '2025-12-31 00:00:00+00'
);

select lives_ok(
  $$
    insert into public.household_members (
      household_id, profile_id, role, starts_at, accepted_at
    ) values (
      '10000000-0000-0000-0002-000000000001',
      '10000000-0000-0000-0001-000000000003',
      'caretaker',
      '2026-01-01 00:00:00+00',
      '2026-01-01 00:00:00+00'
    )
  $$,
  'an ended household membership may be followed by a new period'
);

select throws_ok(
  $$
    insert into public.household_members (
      household_id, profile_id, role, starts_at, is_primary
    ) values (
      '10000000-0000-0000-0002-000000000001',
      '10000000-0000-0000-0001-000000000004',
      'member',
      '2026-01-01 00:00:00+00',
      true
    )
  $$,
  '23505',
  null,
  'only one current primary household member is permitted'
);

select throws_ok(
  $$
    insert into public.household_members (
      household_id, profile_id, role, starts_at, invited_at, accepted_at
    ) values (
      '10000000-0000-0000-0002-000000000001',
      '10000000-0000-0000-0001-000000000004',
      'member',
      '2026-01-01 00:00:00+00',
      '2026-02-01 00:00:00+00',
      '2026-01-15 00:00:00+00'
    )
  $$,
  '23514',
  null,
  'household acceptance cannot precede its invitation'
);

select throws_ok(
  $$
    insert into public.household_members (
      household_id, profile_id, role, starts_at, ends_at
    ) values (
      '10000000-0000-0000-0002-000000000001',
      '10000000-0000-0000-0001-000000000004',
      'member',
      '2026-02-01 00:00:00+00',
      '2026-01-01 00:00:00+00'
    )
  $$,
  '23514',
  null,
  'household membership cannot end before it starts'
);

insert into public.organizations (id, name, org_type)
values (
  '10000000-0000-0000-0003-000000000001',
  'Phase 1 Test Organization',
  'test'
);

select throws_ok(
  $$
    insert into public.organization_members (
      organization_id, profile_id, member_role
    ) values (
      '10000000-0000-0000-0003-000000000001',
      '10000000-0000-0000-0001-000000000001',
      'supervisor'
    )
  $$,
  '22P02',
  null,
  'arbitrary organization role text is rejected'
);

insert into public.organization_members (
  organization_id, profile_id, member_role, starts_at, accepted_at
)
values (
  '10000000-0000-0000-0003-000000000001',
  '10000000-0000-0000-0001-000000000001',
  'admin',
  '2026-01-01 00:00:00+00',
  '2026-01-01 00:00:00+00'
);

select throws_ok(
  $$
    insert into public.organization_members (
      organization_id, profile_id, member_role
    ) values (
      '10000000-0000-0000-0003-000000000001',
      '10000000-0000-0000-0001-000000000001',
      'member'
    )
  $$,
  '23505',
  null,
  'duplicate current organization membership is rejected'
);

insert into public.organization_members (
  organization_id, profile_id, member_role, starts_at, accepted_at, ends_at
)
values (
  '10000000-0000-0000-0003-000000000001',
  '10000000-0000-0000-0001-000000000003',
  'agent',
  '2025-01-01 00:00:00+00',
  '2025-01-01 00:00:00+00',
  '2025-12-31 00:00:00+00'
);

select lives_ok(
  $$
    insert into public.organization_members (
      organization_id, profile_id, member_role, starts_at, accepted_at
    ) values (
      '10000000-0000-0000-0003-000000000001',
      '10000000-0000-0000-0001-000000000003',
      'agent',
      '2026-01-01 00:00:00+00',
      '2026-01-01 00:00:00+00'
    )
  $$,
  'an ended organization membership may be followed by a new period'
);

select is(
  (
    select count(*)::bigint
    from pg_enum
    where enumtypid = 'public.user_role'::regtype
      and enumlabel in (
        'homeowner',
        'contractor',
        'inspector',
        'insurance_agent',
        'real_estate_agent'
      )
  ),
  5::bigint,
  'all five approved user_role personas remain available'
);

select is(
  (
    select count(*)::bigint
    from pg_enum
    where enumtypid = 'public.user_role'::regtype
      and enumlabel in (
        'insurance_agency',
        'real_estate_agency',
        'np_admin',
        'homehub_admin',
        'homehub_superadmin'
      )
  ),
  0::bigint,
  'removed user_role values are unavailable'
);

select lives_ok(
  $$
    update public.profiles
    set role = 'real_estate_agent'
    where id = '10000000-0000-0000-0001-000000000003'
  $$,
  'a retained user_role value remains assignable'
);

select throws_ok(
  $$
    update public.profiles
    set role = 'homehub_admin'
    where id = '10000000-0000-0000-0001-000000000003'
  $$,
  '22P02',
  null,
  'a removed user_role value cannot be assigned'
);

select * from finish();

rollback;
