begin;

select plan(45);

insert into public.profiles (id, role, first_name, last_name, email)
values
  ('60000000-0000-0000-0001-000000000001', 'homeowner', 'Phase', 'Gift Actor', 'phase6-actor@example.homehub'),
  ('60000000-0000-0000-0001-000000000002', 'homeowner', 'Phase', 'Claimant', 'phase6-claimant@example.homehub'),
  ('60000000-0000-0000-0001-000000000003', 'insurance_agent', 'Phase', 'Agent', 'phase6-agent@example.homehub');

insert into public.households (id, name)
values
  ('60000000-0000-0000-0002-000000000001', 'Phase 6 Household A'),
  ('60000000-0000-0000-0002-000000000002', 'Phase 6 Household B'),
  ('60000000-0000-0000-0002-000000000003', 'Phase 6 Household C'),
  ('60000000-0000-0000-0002-000000000004', 'Phase 6 Household D');

insert into public.organizations (id, name, org_type)
values ('60000000-0000-0000-0003-000000000001', 'Phase 6 Insurance Sponsor', 'insurance_agency');

insert into public.properties (id, household_id, address_line1, city, state, zip)
values
  ('60000000-0000-0000-0004-000000000001', '60000000-0000-0000-0002-000000000001', '1 Billing Way', 'Hampstead', 'NC', '28443'),
  ('60000000-0000-0000-0004-000000000002', '60000000-0000-0000-0002-000000000002', '2 Billing Way', 'Hampstead', 'NC', '28443'),
  ('60000000-0000-0000-0004-000000000003', '60000000-0000-0000-0002-000000000004', '3 Billing Way', 'Hampstead', 'NC', '28443');

insert into public.documents (id, property_id, title, storage_path, file_name)
values
  ('60000000-0000-0000-0005-000000000001', '60000000-0000-0000-0004-000000000001', 'Policy A', 'phase6/policy-a', 'a.pdf'),
  ('60000000-0000-0000-0005-000000000002', '60000000-0000-0000-0004-000000000002', 'Policy B', 'phase6/policy-b', 'b.pdf');

select is(
  (select string_agg(enumlabel, ',' order by enumsortorder) from pg_enum where enumtypid='public.billing_plan'::regtype),
  'free,basic,pro,gifted,enterprise',
  'billing_plan retains its exact Foundation values'
);

select is(
  (select count(*)::bigint from pg_indexes where schemaname='public' and tablename='subscriptions' and indexname='subscriptions_one_current_household_idx'),
  1::bigint,
  'the current-household subscription partial unique index exists'
);

select lives_ok($$insert into public.subscriptions (id,household_id,plan,starts_at) values ('60000000-0000-0000-0010-000000000001','60000000-0000-0000-0002-000000000001','basic','2026-01-01')$$, 'a valid current subscription is accepted');
select throws_ok($$insert into public.subscriptions (household_id,plan,starts_at) values ('60000000-0000-0000-0002-000000000001','pro','2026-02-01')$$, '23505', null, 'a duplicate current subscription for one household is rejected');
select lives_ok($$update public.subscriptions set ends_at='2026-06-30',is_active=false where id='60000000-0000-0000-0010-000000000001'$$, 'a current subscription can be ended without deleting it');
select lives_ok($$insert into public.subscriptions (id,household_id,plan,starts_at) values ('60000000-0000-0000-0010-000000000002','60000000-0000-0000-0002-000000000001','pro','2026-07-01')$$, 'an ended subscription may be followed by a new current subscription');
select is((select count(*)::bigint from public.subscriptions where household_id='60000000-0000-0000-0002-000000000001'), 2::bigint, 'the ended subscription remains as history');
select throws_ok($$insert into public.subscriptions (household_id,starts_at,ends_at,is_active) values ('60000000-0000-0000-0002-000000000003','2026-02-01','2026-01-01',false)$$, '23514', null, 'subscription end before start is rejected');

select lives_ok($$insert into public.subscriptions (id,household_id,plan,is_gifted,gifted_by_profile_id,sponsor_organization_id,gifted_reason,gifted_at,gifted_expires_at,starts_at) values ('60000000-0000-0000-0010-000000000003','60000000-0000-0000-0002-000000000002','gifted',true,'60000000-0000-0000-0001-000000000001','60000000-0000-0000-0003-000000000001','Community benefit','2026-01-01','2027-01-01','2026-01-01')$$, 'a valid sponsoring organization and human gift actor are accepted');
select throws_ok($$insert into public.subscriptions (household_id,is_gifted,gifted_by_profile_id,sponsor_organization_id,gifted_at,starts_at,ends_at,is_active) values ('60000000-0000-0000-0002-000000000003',true,'60000000-0000-0000-0001-000000000001','ffffffff-ffff-ffff-ffff-ffffffffffff','2026-01-01','2026-01-01','2026-02-01',false)$$, '23503', null, 'an invalid sponsor organization reference is rejected');
select throws_ok($$insert into public.subscriptions (household_id,is_gifted,gifted_by_profile_id,gifted_at,starts_at,ends_at,is_active) values ('60000000-0000-0000-0002-000000000003',true,'ffffffff-ffff-ffff-ffff-ffffffffffff','2026-01-01','2026-01-01','2026-02-01',false)$$, '23503', null, 'an invalid gift actor reference is rejected');
select throws_ok($$insert into public.subscriptions (household_id,is_gifted,gifted_reason,starts_at,ends_at,is_active) values ('60000000-0000-0000-0002-000000000003',false,'Contradictory gift','2026-01-01','2026-02-01',false)$$, '23514', null, 'gift metadata on a non-gifted subscription is rejected');
select throws_ok($$delete from public.profiles where id='60000000-0000-0000-0001-000000000001'$$, '23503', null, 'gift actor deletion is restricted to preserve gift history');

select lives_ok($$insert into public.subscription_gift_claims (id,subscription_id,token_hash,intended_recipient_email,created_at,expires_at) values ('60000000-0000-0000-0011-000000000001','60000000-0000-0000-0010-000000000003',encode(digest('valid gift claim','sha256'),'hex'),'recipient@example.homehub','2026-01-01','2026-02-01')$$, 'a valid gift claim is accepted');
select is((select count(*)::bigint from information_schema.columns where table_schema='public' and table_name='subscription_gift_claims' and column_name='token'), 0::bigint, 'gift claims have no raw token column');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at) values ('60000000-0000-0000-0010-000000000003',encode(digest('valid gift claim','sha256'),'hex'),'2026-01-01','2026-02-01')$$, '23505', null, 'gift claim token_hash is unique');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at) values ('60000000-0000-0000-0010-000000000003',encode(digest('bad expiry','sha256'),'hex'),'2026-02-01','2026-01-01')$$, '23514', null, 'gift claim expiry before creation is rejected');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at,claimed_at) values ('60000000-0000-0000-0010-000000000003',encode(digest('bad claim time','sha256'),'hex'),'2026-02-01','2026-03-01','2026-01-01')$$, '23514', null, 'claim before creation is rejected');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at,claimed_by_profile_id) values ('60000000-0000-0000-0010-000000000003',encode(digest('claimant no time','sha256'),'hex'),'2026-01-01','2026-02-01','60000000-0000-0000-0001-000000000002')$$, '23514', null, 'claimed_by without claimed_at is rejected');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at,revoked_by) values ('60000000-0000-0000-0010-000000000003',encode(digest('revoker no time','sha256'),'hex'),'2026-01-01','2026-02-01','60000000-0000-0000-0001-000000000001')$$, '23514', null, 'revoked_by without revoked_at is rejected');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at,revoke_reason) values ('60000000-0000-0000-0010-000000000003',encode(digest('reason no revoke','sha256'),'hex'),'2026-01-01','2026-02-01','Ended')$$, '23514', null, 'revoke_reason without revoked_at is rejected');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at,revoked_at,revoke_reason) values ('60000000-0000-0000-0010-000000000003',encode(digest('blank reason','sha256'),'hex'),'2026-01-01','2026-02-01','2026-01-15','   ')$$, '23514', null, 'blank gift-claim revoke reason is rejected');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at,claimed_at,revoked_at) values ('60000000-0000-0000-0010-000000000003',encode(digest('claim after revoke','sha256'),'hex'),'2026-01-01','2026-04-01','2026-03-01','2026-02-01')$$, '23514', null, 'claiming after historical revocation is rejected');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at) values ('60000000-0000-0000-0010-000000000002',encode(digest('nongift claim','sha256'),'hex'),'2026-01-01','2026-02-01')$$, '23503', null, 'a claim cannot reference a non-gifted subscription');
select throws_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at) values ('60000000-0000-0000-0010-000000000003',encode(digest('second open claim','sha256'),'hex'),'2026-01-01','2026-02-01')$$, '23505', null, 'a gifted subscription cannot have two open claims');

select lives_ok($$insert into public.promo_codes (code,discount_pct,max_redemptions,redemption_count,created_at,expires_at) values ('PHASE6VALID',20,10,2,'2026-01-01','2026-12-31')$$, 'valid promo usage and discount values are accepted');
select throws_ok($$insert into public.promo_codes (code,redemption_count) values ('PHASE6NEG',-1)$$, '23514', null, 'negative promo redemption count is rejected');
select throws_ok($$insert into public.promo_codes (code,max_redemptions) values ('PHASE6ZERO',0)$$, '23514', null, 'nonpositive promo max redemptions is rejected');
select throws_ok($$insert into public.promo_codes (code,max_redemptions,redemption_count) values ('PHASE6OVER',1,2)$$, '23514', null, 'promo redemption count above maximum is rejected');
select throws_ok($$insert into public.promo_codes (code,created_at,expires_at) values ('PHASE6DATE','2026-02-01','2026-01-01')$$, '23514', null, 'promo expiration before creation is rejected');
select throws_ok($$insert into public.promo_codes (code,discount_pct) values ('PHASE6DISC',0)$$, '23514', null, 'an invalid percentage discount is rejected');

select lives_ok($$insert into public.insurance_policies (id,property_id,insurer_name,policy_type,effective_date,expiry_date,annual_premium,coverage_amount,deductible,document_id,insurer_organization_id,agent_profile_id) values ('60000000-0000-0000-0012-000000000001','60000000-0000-0000-0004-000000000001','Phase Insurer','homeowners','2026-01-01','2027-01-01',1000,500000,2500,'60000000-0000-0000-0005-000000000001','60000000-0000-0000-0003-000000000001','60000000-0000-0000-0001-000000000003')$$, 'a valid policy with organization and agent links is accepted');
select throws_ok($$insert into public.insurance_policies (property_id,insurer_name,policy_type,effective_date,expiry_date) values ('60000000-0000-0000-0004-000000000001','Phase Insurer','homeowners','2027-01-01','2026-01-01')$$, '23514', null, 'policy expiry before effective date is rejected');
select throws_ok($$insert into public.insurance_policies (property_id,insurer_name,policy_type,annual_premium) values ('60000000-0000-0000-0004-000000000001','Phase Insurer','homeowners',-1)$$, '23514', null, 'negative annual premium is rejected');
select throws_ok($$insert into public.insurance_policies (property_id,insurer_name,policy_type,coverage_amount) values ('60000000-0000-0000-0004-000000000001','Phase Insurer','homeowners',-1)$$, '23514', null, 'negative coverage amount is rejected');
select throws_ok($$insert into public.insurance_policies (property_id,insurer_name,policy_type,deductible) values ('60000000-0000-0000-0004-000000000001','Phase Insurer','homeowners',-1)$$, '23514', null, 'negative deductible is rejected');
select throws_ok($$insert into public.insurance_policies (property_id,insurer_name,policy_type,insurer_organization_id) values ('60000000-0000-0000-0004-000000000001','Phase Insurer','homeowners','ffffffff-ffff-ffff-ffff-ffffffffffff')$$, '23503', null, 'invalid insurer organization reference is rejected');
select throws_ok($$insert into public.insurance_policies (property_id,insurer_name,policy_type,agent_profile_id) values ('60000000-0000-0000-0004-000000000001','Phase Insurer','homeowners','ffffffff-ffff-ffff-ffff-ffffffffffff')$$, '23503', null, 'invalid agent profile reference is rejected');
select throws_ok($$insert into public.insurance_policies (property_id,insurer_name,policy_type,document_id) values ('60000000-0000-0000-0004-000000000001','Phase Insurer','homeowners','60000000-0000-0000-0005-000000000002')$$, '23503', null, 'cross-property policy document is rejected');
select lives_ok($$insert into public.insurance_policies (id,property_id,insurer_name,policy_type,document_id,insurer_organization_id,agent_profile_id) values ('60000000-0000-0000-0012-000000000002','60000000-0000-0000-0004-000000000003','Phase Insurer','homeowners',null,null,null)$$, 'nullable policy document, organization, and agent links are accepted');
select throws_ok($$delete from public.properties where id='60000000-0000-0000-0004-000000000003'$$, '23503', null, 'property deletion is restricted when insurance history exists');

select throws_ok($$insert into public.subscriptions (household_id,starts_at,ends_at,is_active) values ('60000000-0000-0000-0002-000000000003','2026-01-01','2026-02-01',true)$$, '23514', null, 'subscription active flag must agree with lifecycle state');
select throws_ok($$insert into public.subscriptions (household_id,is_gifted,gifted_by_profile_id,gifted_at,gifted_expires_at,starts_at,ends_at,is_active) values ('60000000-0000-0000-0002-000000000003',true,'60000000-0000-0000-0001-000000000001','2026-02-01','2026-01-01','2026-01-01','2026-03-01',false)$$, '23514', null, 'gift expiration before gift date is rejected');
select throws_ok($$insert into public.subscriptions (household_id,starts_at,ends_at,is_active,current_period_start,current_period_end) values ('60000000-0000-0000-0002-000000000003','2026-01-01','2026-03-01',false,'2026-02-01','2026-01-01')$$, '23514', null, 'provider billing period end before start is rejected');
select lives_ok($$insert into public.subscription_gift_claims (subscription_id,token_hash,created_at,expires_at,claimed_at,claimed_by_profile_id,revoked_at,revoked_by,revoke_reason) values ('60000000-0000-0000-0010-000000000003',encode(digest('claimed then revoked','sha256'),'hex'),'2025-01-01','2025-12-31','2025-02-01','60000000-0000-0000-0001-000000000002','2025-03-01','60000000-0000-0000-0001-000000000001','Benefit withdrawn')$$, 'a claim may be revoked after claim while preserving both lifecycle events');

select * from finish();

rollback;
