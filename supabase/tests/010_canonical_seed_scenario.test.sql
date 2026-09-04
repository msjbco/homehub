begin;

select plan(39);

select is(
  (select count(*)::bigint from public.households where id in ('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0001-000000000002')),
  2::bigint,
  'canonical seed contains two independent households'
);
select is(
  (select count(*)::bigint from public.properties where id in ('00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0004-000000000002')),
  2::bigint,
  'canonical seed contains two properties'
);
select is(
  (select household_id from public.properties where id = '00000000-0000-0000-0004-000000000002'),
  '00000000-0000-0000-0001-000000000002'::uuid,
  'second property belongs to the Carter household'
);
select is(
  (select count(*)::bigint
   from public.property_memberships pm
   join public.properties p on p.id = pm.property_id
   join public.household_members hm on hm.profile_id = pm.profile_id and hm.ends_at is null
   where pm.ends_at is null and hm.household_id <> p.household_id),
  0::bigint,
  'current household and property memberships do not cross canonical household boundaries'
);
select ok(
  exists (select 1 from public.property_memberships where property_id = '00000000-0000-0000-0004-000000000002' and profile_id = '00000000-0000-0000-0000-000000000020' and role = 'owner' and ends_at is null),
  'Olivia has current owner membership on the second property'
);
select ok(
  exists (select 1 from public.property_ownership_periods where property_id = '00000000-0000-0000-0004-000000000002' and owner_profile_id = '00000000-0000-0000-0000-000000000020' and ends_on is null),
  'Olivia is the current ownership subject known to HomeHub for the second property'
);

select is(
  (select count(*)::bigint from public.household_members where id in ('00000000-0000-0000-0024-000000000001', '00000000-0000-0000-0024-000000000002', '00000000-0000-0000-0024-000000000003') and created_at is not null and updated_at is not null),
  3::bigint,
  'original canonical household memberships have timestamps'
);
select is(
  (select count(*)::bigint from public.household_members where id in ('00000000-0000-0000-0024-000000000001', '00000000-0000-0000-0024-000000000002') and created_at = '2022-03-18 00:00:00+00' and updated_at = '2022-03-18 00:00:00+00'),
  2::bigint,
  'original homeowner membership timestamps are deterministic'
);
select ok(
  exists (select 1 from public.household_members where id = '00000000-0000-0000-0024-000000000004' and created_at = '2024-02-15 14:00:00+00' and updated_at = created_at),
  'Carter household membership timestamps are deterministic'
);
select is(
  (select count(*)::bigint from public.organization_members where id in ('00000000-0000-0000-0026-000000000001', '00000000-0000-0000-0026-000000000002', '00000000-0000-0000-0026-000000000003', '00000000-0000-0000-0026-000000000004') and created_at is not null and updated_at is not null),
  4::bigint,
  'canonical organization memberships have timestamps'
);
select is(
  (select count(*)::bigint from public.organization_members where id in ('00000000-0000-0000-0026-000000000001', '00000000-0000-0000-0026-000000000002', '00000000-0000-0000-0026-000000000003', '00000000-0000-0000-0026-000000000004') and created_at = starts_at and updated_at = starts_at),
  4::bigint,
  'canonical organization membership timestamps follow their deterministic lifecycle starts'
);

select ok(
  exists (select 1 from public.property_memberships where id = '00000000-0000-0000-0022-000000000005' and profile_id = '00000000-0000-0000-0000-000000000021' and ends_at = '2024-02-15 13:59:59+00'),
  'former owner property membership is retained as ended history'
);
select ok(
  exists (select 1 from public.property_ownership_periods where id = '00000000-0000-0000-0023-000000000003' and owner_profile_id = '00000000-0000-0000-0000-000000000021' and ends_on = '2024-02-14'),
  'former ownership period is retained as ended history'
);
select is(
  (select count(*)::bigint from public.property_memberships where property_id = '00000000-0000-0000-0004-000000000002' and profile_id = '00000000-0000-0000-0000-000000000020' and ends_at is null),
  1::bigint,
  'second property has one current membership for Olivia'
);
select is(
  (select count(*)::bigint from public.property_ownership_periods where property_id = '00000000-0000-0000-0004-000000000002' and ends_on is null),
  1::bigint,
  'second property has one unambiguous current ownership period'
);

select is(
  (select array_agg(member_role::text order by member_role::text) from public.organization_members where id in ('00000000-0000-0000-0026-000000000001', '00000000-0000-0000-0026-000000000002', '00000000-0000-0000-0026-000000000003', '00000000-0000-0000-0026-000000000004')),
  array['admin', 'agent', 'member', 'owner']::text[],
  'canonical organization memberships cover current organization roles'
);
select ok(
  exists (select 1 from public.organization_members where id = '00000000-0000-0000-0026-000000000004' and member_role = 'admin'),
  'Olivia is an organization-local admin'
);
select is(
  (select count(*)::bigint from public.platform_staff_roles where profile_id = '00000000-0000-0000-0000-000000000020' and revoked_at is null),
  0::bigint,
  'organization admin does not imply a platform staff role'
);
select is(
  (select count(*)::bigint from public.platform_staff_roles where role = 'super_admin' and revoked_at is null),
  0::bigint,
  'canonical seed contains no active super_admin'
);

select is(
  (select array_agg(distinct target_type::text order by target_type::text) from public.access_grants),
  array['anonymous', 'organization', 'profile', 'vendor']::text[],
  'canonical access grants represent every target type'
);
select ok(
  exists (select 1 from public.access_grants where id = '00000000-0000-0000-0021-000000000001' and target_type = 'profile' and purpose = 'professional' and grantee_profile_id = '00000000-0000-0000-0000-000000000003'),
  'profile-targeted professional grant is present'
);
select ok(
  exists (select 1 from public.access_grants where id = '00000000-0000-0000-0021-000000000005' and revoked_at is not null and max_uses = use_count),
  'revoked and exhausted grant remains as history'
);
select ok(
  exists (select 1 from public.access_grants where id = '00000000-0000-0000-0021-000000000004' and target_type = 'anonymous' and expires_at > starts_at),
  'anonymous grant is explicitly expiring'
);
select ok(
  exists (select 1 from public.access_grant_log where id = '00000000-0000-0000-0027-000000000001' and grant_id = '00000000-0000-0000-0021-000000000005'),
  'canonical access-use log is retained'
);
select is(
  (select count(*)::bigint from public.access_grants where token_hash !~ '^[0-9a-f]{64}$'),
  0::bigint,
  'all access-grant credentials are lowercase SHA-256 hashes'
);
select is(
  (select count(*)::bigint from information_schema.columns where table_schema = 'public' and table_name = 'access_grants' and column_name = 'token'),
  0::bigint,
  'access grants expose no raw token column'
);
select is(
  (select count(*)::bigint from public.access_grant_capabilities c join public.access_grants g on g.id = c.access_grant_id where c.grant_purpose <> g.purpose),
  0::bigint,
  'canonical capability purpose metadata matches its parent grant'
);

select ok(
  exists (select 1 from public.subscriptions where id = '00000000-0000-0000-0013-000000000001' and not is_gifted and is_active and ends_at is null),
  'normal household subscription remains current and valid'
);
select ok(
  exists (select 1 from public.subscriptions where id = '00000000-0000-0000-0013-000000000002' and is_gifted and is_active and ends_at is null),
  'Carter household has a current gifted subscription'
);
select ok(
  exists (select 1 from public.subscriptions where id = '00000000-0000-0000-0013-000000000002' and gifted_by_profile_id = '00000000-0000-0000-0000-000000000001' and sponsor_organization_id = '00000000-0000-0000-0002-000000000005'),
  'gifted subscription distinguishes initiating profile and sponsoring organization'
);
select ok(
  exists (select 1 from public.subscription_gift_claims where id = '00000000-0000-0000-0028-000000000001' and subscription_is_gifted and claimed_by_profile_id = '00000000-0000-0000-0000-000000000020' and claimed_at between created_at and expires_at and revoked_at is null),
  'gift claim has a valid claimed lifecycle'
);
select is(
  (select count(*)::bigint from public.subscription_gift_claims where token_hash !~ '^[0-9a-f]{64}$'),
  0::bigint,
  'gift-claim credentials are lowercase SHA-256 hashes'
);
select is(
  (select count(*)::bigint from information_schema.columns where table_schema = 'public' and table_name = 'subscription_gift_claims' and column_name = 'token'),
  0::bigint,
  'gift claims expose no raw credential column'
);

select ok(
  exists (select 1 from public.promo_codes where id = '00000000-0000-0000-0029-000000000001' and code = 'COASTAL10' and is_active and discount_pct = 10 and redemption_count <= max_redemptions and expires_at >= created_at),
  'canonical promo code has a valid deterministic lifecycle'
);

select ok(
  exists (select 1 from public.insurance_policies where id = '00000000-0000-0000-0014-000000000001' and property_id = '00000000-0000-0000-0004-000000000001' and insurer_organization_id = '00000000-0000-0000-0002-000000000002' and agent_profile_id = '00000000-0000-0000-0000-000000000012'),
  'insurance policy links its property, structured insurer, and agent'
);
select ok(
  exists (select 1 from public.insurance_policies ip join public.documents d on d.id = ip.document_id and d.property_id = ip.property_id where ip.id = '00000000-0000-0000-0014-000000000001' and ip.expiry_date >= ip.effective_date and ip.annual_premium >= 0 and ip.coverage_amount >= 0 and ip.deductible >= 0),
  'insurance dates, financial values, and supporting document scope are valid'
);

select ok(
  exists (select 1 from public.documents where id = '00000000-0000-0000-0012-000000000007' and property_id = '00000000-0000-0000-0004-000000000002' and storage_path = 'properties/00000000-0000-0000-0004-000000000002/documents/00000000-0000-0000-0012-000000000007/sound-view-overview.pdf'),
  'second-property document uses its exact UUID-scoped object path'
);
select is(
  (select count(*)::bigint from public.documents where storage_path !~ ('^properties/' || property_id::text || '/documents/' || id::text || '/[^/]+$')),
  0::bigint,
  'all canonical document paths remain under their property and document UUID prefix'
);
select ok(
  exists (select 1 from public.notifications where id = '00000000-0000-0000-0015-000000000006' and recipient_id = '00000000-0000-0000-0000-000000000020' and property_id = '00000000-0000-0000-0004-000000000002' and entity_id = '00000000-0000-0000-0012-000000000007'),
  'second-property notification remains scoped to Olivia and her document'
);

select * from finish();
rollback;
