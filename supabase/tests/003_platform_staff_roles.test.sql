begin;

select plan(19);

insert into public.profiles (id, role, first_name, last_name, email)
values
  ('30000000-0000-0000-0001-000000000001', 'homeowner', 'Phase', 'Staff One', 'phase3-staff1@example.homehub'),
  ('30000000-0000-0000-0001-000000000002', 'contractor', 'Phase', 'Staff Two', 'phase3-staff2@example.homehub');

select is(
  (
    select count(*)::bigint
    from pg_enum
    where enumtypid = 'public.platform_staff_role'::regtype
      and enumlabel in ('support', 'admin', 'super_admin')
  ),
  3::bigint,
  'all approved platform staff roles exist'
);

select is(
  (
    select count(*)::bigint
    from pg_enum
    where enumtypid = 'public.platform_staff_role'::regtype
  ),
  3::bigint,
  'platform_staff_role contains exactly three values'
);

select lives_ok(
  $$
    insert into public.platform_staff_roles (
      profile_id, role, granted_by, grant_reason
    ) values (
      '30000000-0000-0000-0001-000000000001',
      'support',
      '30000000-0000-0000-0001-000000000002',
      'Provide HomeHub customer support'
    )
  $$,
  'a valid support assignment is accepted'
);

select lives_ok(
  $$
    insert into public.platform_staff_roles (
      profile_id, role, granted_by, grant_reason
    ) values (
      '30000000-0000-0000-0001-000000000001',
      'admin',
      '30000000-0000-0000-0001-000000000002',
      'Perform HomeHub platform operations'
    )
  $$,
  'a valid admin assignment is accepted'
);

select is(
  (
    select count(*)::bigint
    from public.platform_staff_roles
    where profile_id = '30000000-0000-0000-0001-000000000001'
      and revoked_at is null
  ),
  2::bigint,
  'one profile may hold two different active platform roles'
);

select lives_ok(
  $$
    insert into public.platform_staff_roles (
      profile_id, role, granted_by, grant_reason
    ) values (
      '30000000-0000-0000-0001-000000000002',
      'super_admin',
      '30000000-0000-0000-0001-000000000001',
      'Test-only highest privilege assignment'
    )
  $$,
  'a valid super_admin assignment is accepted in test fixtures'
);

select throws_ok(
  $$
    insert into public.platform_staff_roles (profile_id, role, grant_reason)
    values (
      '30000000-0000-0000-0001-000000000002',
      'operator',
      'Invalid role test'
    )
  $$,
  '22P02',
  null,
  'an arbitrary platform role is rejected'
);

select throws_ok(
  $$
    insert into public.platform_staff_roles (profile_id, role, grant_reason)
    values (
      '30000000-0000-0000-0001-000000000002',
      'admin',
      ''
    )
  $$,
  '23514',
  null,
  'a blank grant reason is rejected'
);

select throws_ok(
  $$
    insert into public.platform_staff_roles (profile_id, role, grant_reason)
    values (
      '30000000-0000-0000-0001-000000000002',
      'admin',
      '   '
    )
  $$,
  '23514',
  null,
  'a whitespace-only grant reason is rejected'
);

select throws_ok(
  $$
    insert into public.platform_staff_roles (profile_id, role, grant_reason)
    values (
      '30000000-0000-0000-0001-000000000001',
      'support',
      'Duplicate assignment test'
    )
  $$,
  '23505',
  null,
  'a duplicate active assignment of the same role is rejected'
);

insert into public.platform_staff_roles (
  profile_id, role, granted_at, grant_reason, revoked_at, revoke_reason
)
values (
  '30000000-0000-0000-0001-000000000002',
  'support',
  '2025-01-01 00:00:00+00',
  'Historical support assignment',
  '2025-12-31 00:00:00+00',
  'Assignment ended'
);

select lives_ok(
  $$
    insert into public.platform_staff_roles (
      profile_id, role, granted_at, grant_reason
    ) values (
      '30000000-0000-0000-0001-000000000002',
      'support',
      '2026-01-01 00:00:00+00',
      'Support role granted again'
    )
  $$,
  'a revoked role may be followed by a new assignment of the same role'
);

select throws_ok(
  $$
    insert into public.platform_staff_roles (
      profile_id, role, granted_at, grant_reason, revoked_at
    ) values (
      '30000000-0000-0000-0001-000000000002',
      'admin',
      '2026-02-01 00:00:00+00',
      'Invalid revocation timeline',
      '2026-01-01 00:00:00+00'
    )
  $$,
  '23514',
  null,
  'revocation cannot precede the grant'
);

select throws_ok(
  $$
    insert into public.platform_staff_roles (
      profile_id, role, grant_reason, revoked_by
    ) values (
      '30000000-0000-0000-0001-000000000002',
      'admin',
      'Invalid revocation actor state',
      '30000000-0000-0000-0001-000000000001'
    )
  $$,
  '23514',
  null,
  'revoked_by requires revoked_at'
);

select throws_ok(
  $$
    insert into public.platform_staff_roles (
      profile_id, role, grant_reason, revoke_reason
    ) values (
      '30000000-0000-0000-0001-000000000002',
      'admin',
      'Invalid revocation reason state',
      'Role ended'
    )
  $$,
  '23514',
  null,
  'revoke_reason requires revoked_at'
);

select throws_ok(
  $$
    insert into public.platform_staff_roles (
      profile_id, role, granted_at, grant_reason, revoked_at, revoke_reason
    ) values (
      '30000000-0000-0000-0001-000000000002',
      'admin',
      '2026-01-01 00:00:00+00',
      'Invalid blank revoke reason',
      '2026-02-01 00:00:00+00',
      '   '
    )
  $$,
  '23514',
  null,
  'a supplied revoke reason must contain non-whitespace text'
);

select is(
  (
    select count(*)::bigint
    from public.property_memberships
    where profile_id in (
      '30000000-0000-0000-0001-000000000001',
      '30000000-0000-0000-0001-000000000002'
    )
  ),
  0::bigint,
  'platform roles do not create property memberships'
);

select is(
  (
    select count(*)::bigint
    from public.household_members
    where profile_id in (
      '30000000-0000-0000-0001-000000000001',
      '30000000-0000-0000-0001-000000000002'
    )
  ),
  0::bigint,
  'platform roles do not create household memberships'
);

select is(
  (
    select count(*)::bigint
    from public.organization_members
    where profile_id in (
      '30000000-0000-0000-0001-000000000001',
      '30000000-0000-0000-0001-000000000002'
    )
  ),
  0::bigint,
  'platform roles do not create organization memberships'
);

select is(
  (
    select role::text
    from public.profiles
    where id = '30000000-0000-0000-0001-000000000001'
  ),
  'homeowner'::text,
  'a platform role does not alter the profile user persona'
);

select * from finish();

rollback;
