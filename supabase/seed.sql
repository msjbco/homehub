-- ============================================================
-- HomeHub Canonical Seed Data
-- Primary homeowner: Michael Johnson
-- All data is placeholder/demo only.
-- No real phone numbers, policy numbers, account numbers,
-- or real document contents are included.
-- ============================================================

-- ── Profiles ─────────────────────────────────────────────────

insert into public.profiles (id, role, first_name, last_name, display_name, email, phone, timezone, locale)
values
  -- Primary homeowner
  ('00000000-0000-0000-0000-000000000001',
   'homeowner', 'Michael', 'Johnson', 'Michael Johnson',
   'michael.johnson@placeholder.example', '555-000-0001',
   'America/Chicago', 'en-US'),

  -- Realtor
  ('00000000-0000-0000-0000-000000000010',
   'real_estate_agent', 'Sarah', 'Johnson', 'Sarah Johnson',
   'sarah.johnson.realtor@placeholder.example', '555-000-0010',
   'America/Chicago', 'en-US'),

  -- Inspector
  ('00000000-0000-0000-0000-000000000011',
   'inspector', 'Mike', 'Torres', 'Mike Torres',
   'mike.torres.inspector@placeholder.example', '555-000-0011',
   'America/Chicago', 'en-US'),

  -- Insurance agent
  ('00000000-0000-0000-0000-000000000012',
   'insurance_agent', 'Linda', 'Park', 'Linda Park',
   'linda.park.insurance@placeholder.example', '555-000-0012',
   'America/Chicago', 'en-US');

-- ── Households ────────────────────────────────────────────────

insert into public.households (id, name)
values
  ('00000000-0000-0000-0001-000000000001', 'Johnson Household');

-- ── Household Members ─────────────────────────────────────────

insert into public.household_members (household_id, profile_id, is_primary)
values
  ('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000001', true);

-- ── Organizations ─────────────────────────────────────────────

insert into public.organizations (id, name, org_type, phone, email, city, state, zip)
values
  ('00000000-0000-0000-0002-000000000001',
   'Austin Realty Partners', 'real_estate_agency',
   '555-000-0020', 'info@austinrealtypartners.placeholder.example',
   'Austin', 'TX', '78701'),

  ('00000000-0000-0000-0002-000000000002',
   'State Farm – Austin Central', 'insurance_agency',
   '555-000-0021', 'info@statefarm-austincentral.placeholder.example',
   'Austin', 'TX', '78702'),

  ('00000000-0000-0000-0002-000000000003',
   'Chase Home Lending', 'lender',
   '555-000-0022', 'homelending@chase.placeholder.example',
   'Austin', 'TX', '78703'),

  ('00000000-0000-0000-0002-000000000004',
   'Austin Title Company', 'title_company',
   '555-000-0023', 'info@austintitle.placeholder.example',
   'Austin', 'TX', '78704');

-- ── Vendors ───────────────────────────────────────────────────

insert into public.vendors (id, business_name, specialty, rating, review_count, status, phone, email, service_areas)
values
  ('00000000-0000-0000-0003-000000000001',
   'AquaPro Pool Service', ARRAY['Pool & Spa', 'Water Chemistry'], 4.8, 47,
   'active', '555-000-0030', 'service@aquapro.placeholder.example',
   ARRAY['Austin, TX', '78745', '78748']),

  ('00000000-0000-0000-0003-000000000002',
   'GreenThumb Landscaping', ARRAY['Landscaping', 'Lawn Care', 'Irrigation'], 4.6, 83,
   'active', '555-000-0031', 'info@greenthumb.placeholder.example',
   ARRAY['Austin, TX', '78745', '78749']),

  ('00000000-0000-0000-0003-000000000003',
   'CoolBreeze HVAC', ARRAY['HVAC', 'Air Conditioning', 'Heating'], 4.9, 112,
   'active', '555-000-0032', 'service@coolbreeze.placeholder.example',
   ARRAY['Austin, TX', '78745', '78704']),

  ('00000000-0000-0000-0003-000000000004',
   'Sparks Electric', ARRAY['Electrical', 'Panel Upgrades', 'Wiring'], 4.7, 64,
   'active', '555-000-0033', 'info@sparkselectric.placeholder.example',
   ARRAY['Austin, TX', '78745']),

  ('00000000-0000-0000-0003-000000000005',
   'ProPaint Austin', ARRAY['Interior Painting', 'Exterior Painting'], 4.5, 38,
   'active', '555-000-0034', 'jobs@propaint.placeholder.example',
   ARRAY['Austin, TX', '78745', '78701']),

  ('00000000-0000-0000-0003-000000000006',
   'Handy Mike Repairs', ARRAY['General Repair', 'Handyman'], 4.4, 29,
   'active', '555-000-0035', 'handymike@placeholder.example',
   ARRAY['Austin, TX', '78745']),

  ('00000000-0000-0000-0003-000000000007',
   'Sparkle Home Services', ARRAY['House Cleaning', 'Deep Clean'], 4.7, 55,
   'active', '555-000-0036', 'info@sparklehome.placeholder.example',
   ARRAY['Austin, TX', '78745']),

  ('00000000-0000-0000-0003-000000000008',
   'TexPest Control', ARRAY['Pest Control', 'Termite', 'Rodent'], 4.6, 41,
   'active', '555-000-0037', 'info@texpest.placeholder.example',
   ARRAY['Austin, TX', '78745']);

-- ── Property ──────────────────────────────────────────────────

insert into public.properties (
  id, household_id,
  address_line1, city, state, zip,
  property_type, status,
  year_built, square_feet, lot_size_sqft,
  bedrooms, bathrooms,
  purchase_price, purchase_date, current_value,
  health_score, home_strength_score, energy_score,
  notes
)
values (
  '00000000-0000-0000-0004-000000000001',
  '00000000-0000-0000-0001-000000000001',
  '2847 Willow Creek Drive', 'Austin', 'TX', '78745',
  'single_family', 'active',
  2009, 2400, 8200,
  4, 2.5,
  425000.00, '2021-06-15', 512000.00,
  87, 74, 68,
  'Primary residence. Pool and spa in backyard. Tile roof.'
);

-- ── Rooms ─────────────────────────────────────────────────────

insert into public.rooms (id, property_id, name, room_type, floor_level, square_feet)
values
  ('00000000-0000-0000-0005-000000000001',
   '00000000-0000-0000-0004-000000000001', 'Kitchen', 'kitchen', 1, 220),
  ('00000000-0000-0000-0005-000000000002',
   '00000000-0000-0000-0004-000000000001', 'Living Room', 'living_room', 1, 380),
  ('00000000-0000-0000-0005-000000000003',
   '00000000-0000-0000-0004-000000000001', 'Master Bedroom', 'bedroom', 2, 320),
  ('00000000-0000-0000-0005-000000000004',
   '00000000-0000-0000-0004-000000000001', 'Guest Bedroom', 'bedroom', 2, 180),
  ('00000000-0000-0000-0005-000000000005',
   '00000000-0000-0000-0004-000000000001', 'Master Bathroom', 'bathroom', 2, 120),
  ('00000000-0000-0000-0005-000000000006',
   '00000000-0000-0000-0004-000000000001', 'Garage', 'garage', 1, 440),
  ('00000000-0000-0000-0005-000000000007',
   '00000000-0000-0000-0004-000000000001', 'Backyard / Pool Area', 'outdoor', 1, null);

-- ── Home Systems ──────────────────────────────────────────────

insert into public.home_systems (
  id, property_id, system_type, name, brand, model,
  installed_date, last_service, next_service, warranty_expiry, condition, notes
)
values
  ('00000000-0000-0000-0006-000000000001',
   '00000000-0000-0000-0004-000000000001',
   'hvac', 'Central HVAC System', 'Carrier', 'Infinity 24 (placeholder model)',
   '2019-04-10', '2025-09-15', '2026-03-15', '2027-04-10',
   'good', 'Dual-zone system. Filter replaced every 90 days.'),

  ('00000000-0000-0000-0006-000000000002',
   '00000000-0000-0000-0004-000000000001',
   'plumbing', 'Water Heater', 'Rheem', 'Performance Platinum (placeholder)',
   '2020-07-22', '2024-07-22', '2026-07-22', '2028-07-22',
   'good', '50-gallon gas water heater.'),

  ('00000000-0000-0000-0006-000000000003',
   '00000000-0000-0000-0004-000000000001',
   'electrical', 'Main Electrical Panel', 'Square D', '200A (placeholder)',
   '2009-01-01', '2023-11-01', null, null,
   'good', '200-amp service. No issues noted at last inspection.'),

  ('00000000-0000-0000-0006-000000000004',
   '00000000-0000-0000-0004-000000000001',
   'roof', 'Tile Roof', 'Boral', 'Saxony 900 (placeholder)',
   '2009-01-01', '2024-04-10', '2027-04-10', null,
   'good', 'Concrete tile. Last inspected April 2024 — no cracked tiles found.'),

  ('00000000-0000-0000-0006-000000000005',
   '00000000-0000-0000-0004-000000000001',
   'security', 'Security System', 'Ring', 'Alarm Pro (placeholder)',
   '2022-03-01', '2025-03-01', '2026-03-01', '2025-03-01',
   'good', 'Cameras at front door, garage, and backyard.'),

  ('00000000-0000-0000-0006-000000000006',
   '00000000-0000-0000-0004-000000000001',
   'pool', 'Pool & Spa System', 'Pentair', 'IntelliFlo (placeholder)',
   '2015-06-01', '2025-12-01', '2026-03-01', null,
   'good', 'Saltwater pool. Pump and filter serviced annually.');

-- ── Home Services ─────────────────────────────────────────────

insert into public.home_services (
  id, property_id, vendor_id, service_type,
  provider_name, provider_phone, schedule,
  price_per_visit, price_unit, monthly_cost, is_active, notes
)
values
  ('00000000-0000-0000-0007-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000002',
   'landscaping', 'GreenThumb Landscaping', '555-000-0031',
   'Weekly (Tuesday morning)', 85.00, 'visit', 340.00, true,
   'Mowing, edging, and blowing. Seasonal pruning included.'),

  ('00000000-0000-0000-0007-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000007',
   'cleaning', 'Sparkle Home Services', '555-000-0036',
   'Weekly (Thursday 10am-2pm)', 150.00, 'visit', 600.00, true,
   'Full house cleaning. Supplies provided by service.'),

  ('00000000-0000-0000-0007-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000008',
   'pest_control', 'TexPest Control', '555-000-0037',
   'Quarterly', 120.00, 'visit', 40.00, true,
   'General pest prevention. Annual termite inspection included.'),

  ('00000000-0000-0000-0007-000000000004',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000001',
   'pool', 'AquaPro Pool Service', '555-000-0030',
   'Weekly (Friday)', 85.00, 'visit', 340.00, true,
   'Weekly chemical balance, brushing, and skimming. Chemicals billed separately.');

-- ── Maintenance Tasks ─────────────────────────────────────────

insert into public.maintenance_tasks (
  id, property_id, home_system_id, title, description,
  due_date, is_recurring, recurrence_rule, priority, estimated_cost
)
values
  ('00000000-0000-0000-0008-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000001',
   'Change HVAC Filter', 'Replace 20x25x1 MERV-11 filter.',
   '2026-09-15', true, 'FREQ=MONTHLY;INTERVAL=3', 'normal', 25.00),

  ('00000000-0000-0000-0008-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000004',
   'Clean Gutters', 'Clear debris from gutters and downspouts.',
   '2026-10-01', true, 'FREQ=YEARLY;BYMONTH=4,10', 'normal', 150.00),

  ('00000000-0000-0000-0008-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000002',
   'Service Water Heater', 'Flush sediment and inspect anode rod.',
   '2026-07-22', true, 'FREQ=YEARLY', 'normal', 120.00),

  ('00000000-0000-0000-0008-000000000004',
   '00000000-0000-0000-0004-000000000001',
   null,
   'Check Smoke & CO Detectors', 'Test all units and replace batteries.',
   '2026-08-01', true, 'FREQ=YEARLY;BYMONTH=8', 'high', 30.00),

  ('00000000-0000-0000-0008-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000006',
   'Pool Chemical Check', 'Test pH, alkalinity, and chlorine levels.',
   '2026-07-18', true, 'FREQ=WEEKLY', 'normal', null);

-- ── Projects ──────────────────────────────────────────────────

insert into public.projects (
  id, property_id, title, description,
  project_type, status, start_date, end_date,
  estimated_cost, actual_cost, vendor_id, is_diy, room_id, notes
)
values
  ('00000000-0000-0000-0009-000000000001',
   '00000000-0000-0000-0004-000000000001',
   'Kitchen Remodel', 'Full kitchen renovation including cabinets, countertops, and appliances.',
   'renovation', 'completed', '2023-03-01', '2023-06-15',
   38000.00, 41200.00, null, false,
   '00000000-0000-0000-0005-000000000001',
   'Completed on time. Final cost over budget due to added backsplash.'),

  ('00000000-0000-0000-0009-000000000002',
   '00000000-0000-0000-0004-000000000001',
   'Bathroom Tile Refresh', 'Retile master shower and replace fixtures.',
   'renovation', 'completed', '2024-01-10', '2024-02-05',
   6500.00, 6200.00, null, false,
   '00000000-0000-0000-0005-000000000005',
   'Under budget. Used leftover tile for accent wall.'),

  ('00000000-0000-0000-0009-000000000003',
   '00000000-0000-0000-0004-000000000001',
   'Roof Inspection & Repair', 'Annual tile inspection and re-seal of ridge caps.',
   'inspection', 'completed', '2024-04-08', '2024-04-10',
   450.00, 425.00,
   null, false, null,
   'No cracked tiles. Ridge cap re-sealed.'),

  ('00000000-0000-0000-0009-000000000004',
   '00000000-0000-0000-0004-000000000001',
   'Deck Staining', 'Sand and re-stain rear deck boards.',
   'maintenance', 'in_progress', '2026-07-01', '2026-07-20',
   800.00, null, null, true, null,
   'DIY project. Semi-transparent cedar stain.'),

  ('00000000-0000-0000-0009-000000000005',
   '00000000-0000-0000-0004-000000000001',
   'Garage Door Replacement', 'Replace aging single-panel garage door with insulated roll-up.',
   'installation', 'planned', '2026-09-01', null,
   3200.00, null, null, false, null,
   'Getting three quotes. Prefer Wayne Dalton or Clopay.');

-- ── Professional Contacts ─────────────────────────────────────

insert into public.professional_contacts (
  id, property_id, profile_id, contact_type,
  name, company, phone, email, city, state, extra_fields
)
values
  ('00000000-0000-0000-0010-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000010',
   'realtor', 'Sarah Johnson', 'Austin Realty Partners',
   '555-000-0010', 'sarah.johnson.realtor@placeholder.example',
   'Austin', 'TX',
   '{"license_number": "TX-PLACEHOLDER-0001", "years_active": 12, "specialties": "Residential, First-Time Buyers"}'::jsonb),

  ('00000000-0000-0000-0010-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000012',
   'insurance', 'Linda Park', 'State Farm – Austin Central',
   '555-000-0012', 'linda.park.insurance@placeholder.example',
   'Austin', 'TX',
   '{"policy_number": "SF-PLACEHOLDER-0001", "coverage": "$350,000 dwelling", "renewal_date": "2027-01-15"}'::jsonb),

  ('00000000-0000-0000-0010-000000000003',
   '00000000-0000-0000-0004-000000000001',
   null,
   'lender', 'Tom Bradley', 'Chase Home Lending',
   '555-000-0022', 'tom.bradley@chase.placeholder.example',
   'Austin', 'TX',
   '{"loan_number": "CHASE-PLACEHOLDER-0001", "rate": "3.25% fixed 30-yr", "payoff_date": "2051-06-15"}'::jsonb),

  ('00000000-0000-0000-0010-000000000004',
   '00000000-0000-0000-0004-000000000001',
   null,
   'closing', 'Jennifer Walsh', 'Austin Title Company',
   '555-000-0023', 'jennifer.walsh@austintitle.placeholder.example',
   'Austin', 'TX',
   '{"closing_date": "2021-06-15", "title_insurance": "Placeholder policy", "escrow_balance": "0.00"}'::jsonb),

  ('00000000-0000-0000-0010-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000011',
   'inspector', 'Mike Torres', 'Torres Home Inspections',
   '555-000-0011', 'mike.torres.inspector@placeholder.example',
   'Austin', 'TX',
   '{"license_number": "TX-INSP-PLACEHOLDER-0001", "inspection_date": "2021-05-28", "report_reference": "THI-2021-PLACEHOLDER"}'::jsonb);

-- ── Phonebook Entries ─────────────────────────────────────────

insert into public.phonebook_entries (
  id, property_id, vendor_id, name, specialty,
  phone, email, rating, is_trusted, notes
)
values
  ('00000000-0000-0000-0011-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000001',
   'AquaPro Pool Service', 'Pool & Spa',
   '555-000-0030', 'service@aquapro.placeholder.example', 5, true,
   'Carlos is great. Always on time. 5 stars.'),

  ('00000000-0000-0000-0011-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000002',
   'GreenThumb Landscaping', 'Lawn & Garden',
   '555-000-0031', 'info@greenthumb.placeholder.example', 4, true,
   'Reliable crew. Good seasonal pruning.'),

  ('00000000-0000-0000-0011-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000003',
   'CoolBreeze HVAC', 'HVAC',
   '555-000-0032', 'service@coolbreeze.placeholder.example', 5, true,
   'Best HVAC tech in Austin. Fast response.'),

  ('00000000-0000-0000-0011-000000000004',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000004',
   'Sparks Electric', 'Electrical',
   '555-000-0033', 'info@sparkselectric.placeholder.example', 5, true,
   'Did panel inspection and outlet install. Very professional.'),

  ('00000000-0000-0000-0011-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000005',
   'ProPaint Austin', 'Painting',
   '555-000-0034', 'jobs@propaint.placeholder.example', 4, false,
   'Good work on living room. Slightly over schedule.'),

  ('00000000-0000-0000-0011-000000000006',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000006',
   'Handy Mike Repairs', 'Handyman',
   '555-000-0035', 'handymike@placeholder.example', 4, true,
   'Great for small repairs. Books up fast.');

-- ── Documents ─────────────────────────────────────────────────

insert into public.documents (
  id, property_id, uploaded_by, category,
  title, storage_path, file_name, mime_type, expiry_date, tags
)
values
  ('00000000-0000-0000-0012-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'inspection',
   'Home Inspection Report – Pre-Purchase 2021',
   'placeholder/properties/willow-creek/docs/inspection-2021.pdf',
   'inspection-report-2021.pdf', 'application/pdf', null,
   ARRAY['inspection', '2021', 'pre-purchase']),

  ('00000000-0000-0000-0012-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'warranty',
   'HVAC System Warranty',
   'placeholder/properties/willow-creek/docs/hvac-warranty.pdf',
   'hvac-warranty.pdf', 'application/pdf', '2027-04-10',
   ARRAY['hvac', 'warranty', 'carrier']),

  ('00000000-0000-0000-0012-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'insurance',
   'Homeowner''s Insurance Policy – State Farm',
   'placeholder/properties/willow-creek/docs/insurance-policy-statefarm.pdf',
   'insurance-policy-statefarm.pdf', 'application/pdf', '2027-01-15',
   ARRAY['insurance', 'state-farm', 'policy']),

  ('00000000-0000-0000-0012-000000000004',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'deed',
   'Property Deed – 2847 Willow Creek Drive',
   'placeholder/properties/willow-creek/docs/deed-2021.pdf',
   'deed-2021.pdf', 'application/pdf', null,
   ARRAY['deed', 'closing', '2021']),

  ('00000000-0000-0000-0012-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'permit',
   'Pool Construction Permit – 2015',
   'placeholder/properties/willow-creek/docs/pool-permit-2015.pdf',
   'pool-permit-2015.pdf', 'application/pdf', null,
   ARRAY['pool', 'permit', '2015']),

  ('00000000-0000-0000-0012-000000000006',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'inspection',
   'Roof Inspection Report – April 2024',
   'placeholder/properties/willow-creek/docs/roof-inspection-2024.pdf',
   'roof-inspection-2024.pdf', 'application/pdf', null,
   ARRAY['roof', 'inspection', '2024']);

-- ── Subscriptions ─────────────────────────────────────────────

insert into public.subscriptions (
  id, household_id, plan, is_gifted, is_active,
  current_period_start, current_period_end
)
values (
  '00000000-0000-0000-0013-000000000001',
  '00000000-0000-0000-0001-000000000001',
  'pro', false, true,
  '2026-06-01', '2026-07-01'
);

-- ── Insurance Policies ────────────────────────────────────────

insert into public.insurance_policies (
  id, property_id, insurer_name, policy_type, status,
  policy_number, agent_name, agent_phone, agent_email,
  annual_premium, coverage_amount, deductible,
  effective_date, expiry_date, renewal_reminder_days, document_id
)
values (
  '00000000-0000-0000-0014-000000000001',
  '00000000-0000-0000-0004-000000000001',
  'State Farm', 'homeowners', 'active',
  'SF-PLACEHOLDER-0001',
  'Linda Park', '555-000-0012', 'linda.park.insurance@placeholder.example',
  2100.00, 350000.00, 2500.00,
  '2026-01-15', '2027-01-15', 30,
  '00000000-0000-0000-0012-000000000003'
);

-- ── Notifications ─────────────────────────────────────────────

insert into public.notifications (
  id, recipient_id, type, status, title, body,
  property_id, entity_type, entity_id
)
values
  ('00000000-0000-0000-0015-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'maintenance_reminder', 'unread',
   'HVAC Filter Due', 'Your HVAC filter is due for replacement by September 15.',
   '00000000-0000-0000-0004-000000000001',
   'maintenance_task', '00000000-0000-0000-0008-000000000001'),

  ('00000000-0000-0000-0015-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'document_expiry', 'unread',
   'HVAC Warranty Expiring', 'Your HVAC warranty expires April 10, 2027. Consider an extended plan.',
   '00000000-0000-0000-0004-000000000001',
   'document', '00000000-0000-0000-0012-000000000002'),

  ('00000000-0000-0000-0015-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'compliance_reminder', 'unread',
   'Check Smoke Detectors', 'Annual smoke and CO detector check is due August 1.',
   '00000000-0000-0000-0004-000000000001',
   'maintenance_task', '00000000-0000-0000-0008-000000000004');
