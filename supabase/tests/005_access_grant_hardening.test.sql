begin;

select plan(47);

insert into public.profiles (id, role, first_name, last_name, email)
values
  ('50000000-0000-0000-0001-000000000001', 'homeowner', 'Phase', 'Grantor', 'phase5-grantor@example.homehub'),
  ('50000000-0000-0000-0001-000000000002', 'contractor', 'Phase', 'Target', 'phase5-target@example.homehub'),
  ('50000000-0000-0000-0001-000000000003', 'contractor', 'Phase', 'Staff', 'phase5-staff@example.homehub'),
  ('50000000-0000-0000-0001-000000000004', 'contractor', 'Phase', 'Nonstaff', 'phase5-nonstaff@example.homehub');

insert into public.households (id, name)
values
  ('50000000-0000-0000-0002-000000000001', 'Phase 5 Household A'),
  ('50000000-0000-0000-0002-000000000002', 'Phase 5 Household B');

insert into public.properties (id, household_id, address_line1, city, state, zip)
values
  ('50000000-0000-0000-0003-000000000001', '50000000-0000-0000-0002-000000000001', '1 Grant Way', 'Hampstead', 'NC', '28443'),
  ('50000000-0000-0000-0003-000000000002', '50000000-0000-0000-0002-000000000002', '2 Grant Way', 'Hampstead', 'NC', '28443');

insert into public.organizations (id, name, org_type)
values ('50000000-0000-0000-0004-000000000001', 'Phase 5 Organization', 'test');

insert into public.vendors (id, business_name)
values ('50000000-0000-0000-0005-000000000001', 'Phase 5 Vendor');

insert into public.documents (id, property_id, title, storage_path, file_name)
values
  ('50000000-0000-0000-0006-000000000001', '50000000-0000-0000-0003-000000000001', 'Grant Document A', 'phase5/document-a', 'a.pdf'),
  ('50000000-0000-0000-0006-000000000002', '50000000-0000-0000-0003-000000000002', 'Grant Document B', 'phase5/document-b', 'b.pdf');

insert into public.platform_staff_roles (profile_id, role, grant_reason)
values ('50000000-0000-0000-0001-000000000003', 'support', 'Phase 5 support eligibility fixture');

select is(
  (select string_agg(enumlabel, ',' order by enumsortorder) from pg_enum where enumtypid = 'public.access_grant_purpose'::regtype),
  'guest,vendor,professional,support',
  'access_grant_purpose has exactly the approved values'
);

select is(
  (select string_agg(enumlabel, ',' order by enumsortorder) from pg_enum where enumtypid = 'public.access_grant_capability'::regtype),
  'read,upload,log_work',
  'access_grant_capability has exactly the approved values'
);

select is(
  (select string_agg(enumlabel, ',' order by enumsortorder) from pg_enum where enumtypid = 'public.access_grant_target_type'::regtype),
  'profile,vendor,organization,anonymous',
  'access_grant_target_type has exactly the governed target modes'
);

select lives_ok($$insert into public.access_grants (id,property_id,granted_by,target_type,purpose,grantee_profile_id,token_hash) values ('50000000-0000-0000-0010-000000000001','50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','profile','professional','50000000-0000-0000-0001-000000000002',encode(digest('profile grant','sha256'),'hex'))$$, 'a profile-target grant is accepted');
select lives_ok($$insert into public.access_grants (id,property_id,granted_by,target_type,purpose,grantee_vendor_id,token_hash) values ('50000000-0000-0000-0010-000000000002','50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','vendor','vendor','50000000-0000-0000-0005-000000000001',encode(digest('vendor grant','sha256'),'hex'))$$, 'a vendor-target grant is accepted');
select lives_ok($$insert into public.access_grants (id,property_id,granted_by,target_type,purpose,grantee_organization_id,token_hash) values ('50000000-0000-0000-0010-000000000003','50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','organization','professional','50000000-0000-0000-0004-000000000001',encode(digest('organization grant','sha256'),'hex'))$$, 'an organization-target grant is accepted');
select lives_ok($$insert into public.access_grants (id,property_id,granted_by,target_type,purpose,token_hash) values ('50000000-0000-0000-0010-000000000004','50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','anonymous','guest',encode(digest('anonymous grant','sha256'),'hex'))$$, 'an anonymous grant is accepted');
select throws_ok($$insert into public.access_grants (property_id,granted_by,target_type,purpose,grantee_profile_id,grantee_vendor_id,token_hash) values ('50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','profile','professional','50000000-0000-0000-0001-000000000002','50000000-0000-0000-0005-000000000001',encode(digest('multiple targets','sha256'),'hex'))$$, '23514', null, 'multiple target subjects are rejected');
select throws_ok($$insert into public.access_grants (property_id,granted_by,target_type,purpose,grantee_profile_id,token_hash) values ('50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','anonymous','guest','50000000-0000-0000-0001-000000000002',encode(digest('bad anonymous','sha256'),'hex'))$$, '23514', null, 'anonymous target mode rejects a populated subject');

select throws_ok($$insert into public.access_grants (property_id,granted_by,target_type,purpose,token_hash) values (null,'50000000-0000-0000-0001-000000000001','anonymous','guest',encode(digest('no property','sha256'),'hex'))$$, '23502', null, 'property scope is required');
select lives_ok($$insert into public.access_grants (property_id,granted_by,target_type,purpose,document_id,token_hash) values ('50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','anonymous','guest','50000000-0000-0000-0006-000000000001',encode(digest('same document','sha256'),'hex'))$$, 'a same-property document scope is accepted');
select throws_ok($$insert into public.access_grants (property_id,granted_by,target_type,purpose,document_id,token_hash) values ('50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','anonymous','guest','50000000-0000-0000-0006-000000000002',encode(digest('cross document','sha256'),'hex'))$$, '23503', null, 'a cross-property document scope is rejected');
select lives_ok($$insert into public.access_grants (property_id,granted_by,target_type,purpose,document_category,token_hash) values ('50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','anonymous','guest','warranty',encode(digest('category scope','sha256'),'hex'))$$, 'a global document-category scope is accepted');
select throws_ok($$insert into public.access_grants (property_id,granted_by,target_type,purpose,document_id,document_category,token_hash) values ('50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','anonymous','guest','50000000-0000-0000-0006-000000000001','warranty',encode(digest('two scopes','sha256'),'hex'))$$, '23514', null, 'document and category scope cannot both be populated');

select lives_ok($$insert into public.access_grant_capabilities values ('50000000-0000-0000-0010-000000000004','guest','read',default)$$, 'read is a valid capability');
select lives_ok($$insert into public.access_grant_capabilities values ('50000000-0000-0000-0010-000000000004','guest','upload',default)$$, 'upload is a valid capability');
select lives_ok($$insert into public.access_grant_capabilities values ('50000000-0000-0000-0010-000000000004','guest','log_work',default)$$, 'log_work is a valid capability');
select throws_ok($$insert into public.access_grant_capabilities values ('50000000-0000-0000-0010-000000000004','guest','read',default)$$, '23505', null, 'a duplicate capability is rejected');
select throws_ok($$insert into public.access_grant_capabilities (access_grant_id,grant_purpose,capability) values ('50000000-0000-0000-0010-000000000004','guest','manage')$$, '22P02', null, 'an arbitrary capability is rejected');

select lives_ok($$insert into public.access_grants (property_id,granted_by,target_type,purpose,starts_at,expires_at,token_hash) values ('50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','anonymous','guest','2026-01-01','2026-02-01',encode(digest('valid expiry','sha256'),'hex'))$$, 'a valid expiring grant is accepted');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,starts_at,expires_at,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest','2026-02-01','2026-01-01',encode(digest('bad expiry','sha256'),'hex'))$$, '23514', null, 'expiration before start is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,starts_at,revoked_at,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest','2026-02-01','2026-01-01',encode(digest('bad revocation','sha256'),'hex'))$$, '23514', null, 'revocation before start is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,revoked_by,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest','50000000-0000-0000-0001-000000000001',encode(digest('revoker no date','sha256'),'hex'))$$, '23514', null, 'revoked_by without revoked_at is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,revoke_reason,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest','ended',encode(digest('reason no date','sha256'),'hex'))$$, '23514', null, 'revoke_reason without revoked_at is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,revoked_at,revoke_reason,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest',now(),'   ',encode(digest('blank reason','sha256'),'hex'))$$, '23514', null, 'a whitespace-only revoke reason is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,max_uses,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest',0,encode(digest('zero max','sha256'),'hex'))$$, '23514', null, 'max_uses of zero is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,use_count,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest',-1,encode(digest('negative use','sha256'),'hex'))$$, '23514', null, 'negative use_count is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,max_uses,use_count,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest',1,2,encode(digest('over max','sha256'),'hex'))$$, '23514', null, 'use_count above max_uses is rejected');

select is((select count(*)::bigint from information_schema.columns where table_schema='public' and table_name='access_grants' and column_name='token'), 0::bigint, 'the raw token column is absent');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest',encode(digest('profile grant','sha256'),'hex'))$$, '23505', null, 'token_hash uniqueness is enforced');

select lives_ok($$insert into public.access_grants (id,property_id,granted_by,target_type,purpose,grantee_profile_id,expires_at,business_reason,token_hash) values ('50000000-0000-0000-0010-000000000005','50000000-0000-0000-0003-000000000001','50000000-0000-0000-0001-000000000001','profile','support','50000000-0000-0000-0001-000000000003',now()+interval '1 day','Investigate customer-reported document issue',encode(digest('support grant','sha256'),'hex'))$$, 'a valid staff-targeted support grant is accepted');
select lives_ok($$insert into public.access_grant_capabilities values ('50000000-0000-0000-0010-000000000005','support','read',default)$$, 'read is accepted for a support grant');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,grantee_profile_id,expires_at,business_reason,token_hash) values ('50000000-0000-0000-0003-000000000001','profile','support','50000000-0000-0000-0001-000000000004',now()+interval '1 day','Nonstaff test',encode(digest('nonstaff support','sha256'),'hex'))$$, '23514', null, 'a nonstaff profile support grant is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,expires_at,business_reason,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','support',now()+interval '1 day','Anonymous test',encode(digest('anonymous support','sha256'),'hex'))$$, '23514', null, 'an anonymous support grant is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,grantee_profile_id,business_reason,token_hash) values ('50000000-0000-0000-0003-000000000001','profile','support','50000000-0000-0000-0001-000000000003','No expiration test',encode(digest('support no expiry','sha256'),'hex'))$$, '23514', null, 'a support grant without expiration is rejected');
select throws_ok($$insert into public.access_grants (property_id,target_type,purpose,grantee_profile_id,expires_at,token_hash) values ('50000000-0000-0000-0003-000000000001','profile','support','50000000-0000-0000-0001-000000000003',now()+interval '1 day',encode(digest('support no reason','sha256'),'hex'))$$, '23514', null, 'a support grant without a business reason is rejected');
select throws_ok($$insert into public.access_grant_capabilities values ('50000000-0000-0000-0010-000000000005','support','upload',default)$$, '23514', null, 'upload is rejected for a support grant');
select throws_ok($$insert into public.access_grant_capabilities values ('50000000-0000-0000-0010-000000000005','support','log_work',default)$$, '23514', null, 'log_work is rejected for a support grant');
select is((select count(*)::bigint from public.property_memberships where profile_id='50000000-0000-0000-0001-000000000003'), 0::bigint, 'platform staff role alone creates no property membership');
select is((select count(*)::bigint from public.household_members where profile_id='50000000-0000-0000-0001-000000000003'), 0::bigint, 'platform staff role alone creates no household membership');
select is((select count(*)::bigint from public.organization_members where profile_id='50000000-0000-0000-0001-000000000003'), 0::bigint, 'platform staff role alone creates no organization membership');

select lives_ok($$insert into public.access_grant_log (grant_id,used_by) values ('50000000-0000-0000-0010-000000000001','50000000-0000-0000-0001-000000000002')$$, 'access-grant usage history can be recorded');
select throws_ok($$delete from public.access_grants where id='50000000-0000-0000-0010-000000000001'$$, '23503', null, 'a grant with access history cannot be deleted');
select is((select count(*)::bigint from public.access_grant_log where grant_id='50000000-0000-0000-0010-000000000001'), 1::bigint, 'access history remains after a blocked grant deletion');

select lives_ok($$insert into public.access_grants (property_id,target_type,purpose,starts_at,revoked_at,revoke_reason,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest','2025-01-01','2025-02-01','Access ended',encode(digest('historical revoked','sha256'),'hex'))$$, 'a historical revoked grant remains valid stored history');
select lives_ok($$insert into public.access_grants (property_id,target_type,purpose,starts_at,expires_at,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest','2025-01-01','2025-02-01',encode(digest('historical expired','sha256'),'hex'))$$, 'a historical expired grant remains valid stored history');
select lives_ok($$insert into public.access_grants (property_id,target_type,purpose,max_uses,use_count,token_hash) values ('50000000-0000-0000-0003-000000000001','anonymous','guest',1,1,encode(digest('historical exhausted','sha256'),'hex'))$$, 'an exhausted grant remains valid stored history');

select * from finish();

rollback;
