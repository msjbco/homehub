-- ============================================================
-- HomeHub Canonical Seed Data — Hampstead, NC Scenario
-- Primary homeowner: Michael Johnson
-- Email: michael@example.homehub (placeholder)
-- Location: Hampstead, North Carolina
-- All data is placeholder/demo only.
-- No real phone numbers, policy numbers, account numbers,
-- or real document contents are included.
-- Placeholder emails use @example.homehub or @placeholder.example
-- Placeholder document/media paths use placeholder/ prefix
-- ============================================================

-- ── Profiles ─────────────────────────────────────────────────

insert into public.profiles (id, role, first_name, last_name, display_name, email, phone, timezone, locale)
values
  -- Primary homeowner
  ('00000000-0000-0000-0000-000000000001',
   'homeowner', 'Michael', 'Johnson', 'Michael Johnson',
   'michael@example.homehub', '555-000-0001',
   'America/New_York', 'en-US'),

  -- Spouse / household co-owner
  ('00000000-0000-0000-0000-000000000002',
   'homeowner', 'Jennifer', 'Johnson', 'Jennifer Johnson',
   'jennifer@example.homehub', '555-000-0002',
   'America/New_York', 'en-US'),

  -- Caretaker / property helper
  ('00000000-0000-0000-0000-000000000003',
   'homeowner', 'Ray', 'Watkins', 'Ray Watkins (Caretaker)',
   'ray.watkins.caretaker@placeholder.example', '555-000-0003',
   'America/New_York', 'en-US'),

  -- Real estate agent (NC)
  ('00000000-0000-0000-0000-000000000010',
   'real_estate_agent', 'Dana', 'Hewitt', 'Dana Hewitt',
   'dana.hewitt.realtor@placeholder.example', '555-000-0010',
   'America/New_York', 'en-US'),

  -- Home inspector (NC)
  ('00000000-0000-0000-0000-000000000011',
   'inspector', 'James', 'Strickland', 'James Strickland',
   'james.strickland.inspector@placeholder.example', '555-000-0011',
   'America/New_York', 'en-US'),

  -- Insurance agent (NC)
  ('00000000-0000-0000-0000-000000000012',
   'insurance_agent', 'Carol', 'Beasley', 'Carol Beasley',
   'carol.beasley.insurance@placeholder.example', '555-000-0012',
   'America/New_York', 'en-US');

-- ── Households ────────────────────────────────────────────────

insert into public.households (id, name)
values
  ('00000000-0000-0000-0001-000000000001', 'Johnson Household');

-- ── Household Members ─────────────────────────────────────────

insert into public.household_members (
  household_id, profile_id, is_primary, role, starts_at, accepted_at
)
values
  -- Michael is primary
  ('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000001', true,
   'member', '2022-03-18 00:00:00+00', '2022-03-18 00:00:00+00'),
  -- Jennifer is co-owner
  ('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000002', false,
   'member', '2022-03-18 00:00:00+00', '2022-03-18 00:00:00+00'),
  -- Ray has limited caretaker access
  ('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000003', false,
   'caretaker', '2026-06-01 00:00:00+00', '2026-06-01 00:00:00+00');

-- ── Organizations ─────────────────────────────────────────────

insert into public.organizations (id, name, org_type, phone, email, city, state, zip)
values
  -- NC real estate agency
  ('00000000-0000-0000-0002-000000000001',
   'Coastal Carolina Realty', 'real_estate_agency',
   '555-000-0020', 'info@coastalcarolinarealty.placeholder.example',
   'Hampstead', 'NC', '28443'),

  -- NC insurance agency
  ('00000000-0000-0000-0002-000000000002',
   'Cape Fear Insurance Group', 'insurance_agency',
   '555-000-0021', 'info@capefearigroup.placeholder.example',
   'Wilmington', 'NC', '28401'),

  -- NC lender
  ('00000000-0000-0000-0002-000000000003',
   'First Bank – Coastal NC', 'lender',
   '555-000-0022', 'homelending@firstbank-coastalnc.placeholder.example',
   'Hampstead', 'NC', '28443'),

  -- NC title company
  ('00000000-0000-0000-0002-000000000004',
   'Pender County Title & Escrow', 'title_company',
   '555-000-0023', 'info@pendertitle.placeholder.example',
   'Burgaw', 'NC', '28425'),

  -- Community / HOA reference
  ('00000000-0000-0000-0002-000000000005',
   'Tidewater at Hampstead HOA', 'community_association',
   '555-000-0024', 'hoa@tidewaterhampstead.placeholder.example',
   'Hampstead', 'NC', '28443');

-- ── Vendors ───────────────────────────────────────────────────

insert into public.vendors (id, business_name, specialty, rating, review_count, status, phone, email, service_areas)
values
  -- Pool service
  ('00000000-0000-0000-0003-000000000001',
   'Coastal Pool & Spa', ARRAY['Pool & Spa', 'Water Chemistry', 'Equipment Repair'], 4.8, 34,
   'active', '555-000-0030', 'service@coastalpoolspa.placeholder.example',
   ARRAY['Hampstead, NC', 'Surf City, NC', '28443']),

  -- Landscaping
  ('00000000-0000-0000-0003-000000000002',
   'Tidewater Lawn Care', ARRAY['Landscaping', 'Lawn Care', 'Irrigation', 'Pine Straw'], 4.6, 61,
   'active', '555-000-0031', 'info@tidewaterlawn.placeholder.example',
   ARRAY['Hampstead, NC', 'Surf City, NC', 'Holly Ridge, NC', '28443']),

  -- HVAC
  ('00000000-0000-0000-0003-000000000003',
   'Cape Fear Heating & Air', ARRAY['HVAC', 'Heat Pump', 'Air Conditioning', 'Ductwork'], 4.9, 89,
   'active', '555-000-0032', 'service@capefearhvac.placeholder.example',
   ARRAY['Hampstead, NC', 'Wilmington, NC', '28443', '28401']),

  -- Electrical
  ('00000000-0000-0000-0003-000000000004',
   'Pender Electric', ARRAY['Electrical', 'Panel Upgrades', 'Generator Install', 'Wiring'], 4.7, 52,
   'active', '555-000-0033', 'info@penderelectric.placeholder.example',
   ARRAY['Hampstead, NC', 'Burgaw, NC', '28443']),

  -- Pest control
  ('00000000-0000-0000-0003-000000000005',
   'Coastal Pest Solutions', ARRAY['Pest Control', 'Termite', 'Mosquito', 'Rodent'], 4.6, 47,
   'active', '555-000-0034', 'info@coastalpest.placeholder.example',
   ARRAY['Hampstead, NC', 'Surf City, NC', 'Wilmington, NC', '28443']),

  -- General contractor / handyman
  ('00000000-0000-0000-0003-000000000006',
   'Topsail Handyman Services', ARRAY['General Repair', 'Handyman', 'Carpentry', 'Pressure Washing'], 4.5, 28,
   'active', '555-000-0035', 'info@topsailhandyman.placeholder.example',
   ARRAY['Hampstead, NC', 'Topsail Beach, NC', '28443']),

  -- Plumber
  ('00000000-0000-0000-0003-000000000007',
   'Sound Plumbing Co.', ARRAY['Plumbing', 'Water Heater', 'Septic Hook-Up', 'Leak Repair'], 4.8, 43,
   'active', '555-000-0036', 'info@soundplumbing.placeholder.example',
   ARRAY['Hampstead, NC', 'Holly Ridge, NC', '28443']),

  -- Roofing
  ('00000000-0000-0000-0003-000000000008',
   'Cape Lookout Roofing', ARRAY['Roofing', 'Shingles', 'Gutter Install', 'Storm Repair'], 4.7, 38,
   'active', '555-000-0037', 'info@capelookoutroofing.placeholder.example',
   ARRAY['Hampstead, NC', 'Wilmington, NC', '28443', '28401']);

-- ── Property ──────────────────────────────────────────────────
-- Fictional address in Hampstead, NC 28443

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
  '114 Marsh Cove Lane', 'Hampstead', 'NC', '28443',
  'single_family', 'active',
  2017, 2650, 18295,
  4, 3.0,
  489000.00, '2022-03-18', 541000.00,
  84, 79, 71,
  'Primary residence. Single-story with bonus room. Inground pool. Attached 2-car garage. On city sewer. HOA: Tidewater at Hampstead.'
);

-- ── Property Memberships ──────────────────────────────────────
-- Durable property access is explicit and separate from household membership.

insert into public.property_memberships (
  id, property_id, profile_id, role, granted_by, starts_at, accepted_at
)
values
  ('00000000-0000-0000-0022-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'owner', '00000000-0000-0000-0000-000000000001',
   '2022-03-18 00:00:00+00', '2022-03-18 00:00:00+00'),
  ('00000000-0000-0000-0022-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'owner', '00000000-0000-0000-0000-000000000001',
   '2022-03-18 00:00:00+00', '2022-03-18 00:00:00+00'),
  ('00000000-0000-0000-0022-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000003',
   'caretaker', '00000000-0000-0000-0000-000000000001',
   '2026-06-01 00:00:00+00', '2026-06-01 00:00:00+00');

-- ── HomeHub-Recorded Ownership Periods ────────────────────────
-- These reflect the canonical scenario known to HomeHub and are not an
-- authoritative statement of legal title. Percentages are intentionally null.

insert into public.property_ownership_periods (
  id, property_id, owner_profile_id, ownership_type,
  ownership_percentage, starts_on, recorded_by
)
values
  ('00000000-0000-0000-0023-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'owner', null, '2022-03-18',
   '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0023-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'co_owner', null, '2022-03-18',
   '00000000-0000-0000-0000-000000000001');

-- ── Rooms ─────────────────────────────────────────────────────

insert into public.rooms (id, property_id, name, room_type, floor_level, square_feet)
values
  ('00000000-0000-0000-0005-000000000001',
   '00000000-0000-0000-0004-000000000001', 'Kitchen', 'kitchen', 1, 240),
  ('00000000-0000-0000-0005-000000000002',
   '00000000-0000-0000-0004-000000000001', 'Living Room', 'living_room', 1, 420),
  ('00000000-0000-0000-0005-000000000003',
   '00000000-0000-0000-0004-000000000001', 'Primary Bedroom', 'bedroom', 1, 340),
  ('00000000-0000-0000-0005-000000000004',
   '00000000-0000-0000-0004-000000000001', 'Bedroom 2', 'bedroom', 1, 190),
  ('00000000-0000-0000-0005-000000000005',
   '00000000-0000-0000-0004-000000000001', 'Bedroom 3', 'bedroom', 1, 175),
  ('00000000-0000-0000-0005-000000000006',
   '00000000-0000-0000-0004-000000000001', 'Primary Bathroom', 'bathroom', 1, 130),
  ('00000000-0000-0000-0005-000000000007',
   '00000000-0000-0000-0004-000000000001', 'Bonus Room', 'bonus_room', 2, 320),
  ('00000000-0000-0000-0005-000000000008',
   '00000000-0000-0000-0004-000000000001', 'Garage', 'garage', 1, 480),
  ('00000000-0000-0000-0005-000000000009',
   '00000000-0000-0000-0004-000000000001', 'Backyard / Pool Area', 'outdoor', 1, null);

-- ── Home Systems ──────────────────────────────────────────────

insert into public.home_systems (
  id, property_id, system_type, name, brand, model,
  installed_date, last_service, next_service, warranty_expiry, condition, notes
)
values
  -- HVAC (heat pump — common in coastal NC)
  ('00000000-0000-0000-0006-000000000001',
   '00000000-0000-0000-0004-000000000001',
   'hvac', 'Heat Pump System', 'Lennox', 'XP21 (placeholder model)',
   '2017-06-01', '2026-03-10', '2026-09-10', '2027-06-01',
   'good', 'Heat pump — primary heating and cooling. Filter replaced every 60 days due to coastal humidity. Two zones.'),

  -- Water heater
  ('00000000-0000-0000-0006-000000000002',
   '00000000-0000-0000-0004-000000000001',
   'plumbing', 'Water Heater', 'Rheem', 'Performance Plus (placeholder)',
   '2021-04-15', '2025-04-15', '2026-04-15', '2029-04-15',
   'good', '50-gallon electric water heater. Garage utility closet.'),

  -- Electrical panel
  ('00000000-0000-0000-0006-000000000003',
   '00000000-0000-0000-0004-000000000001',
   'electrical', 'Main Electrical Panel', 'Square D', 'QO130L200PG (placeholder)',
   '2017-06-01', '2024-11-12', null, null,
   'good', '200-amp underground service. Whole-house surge protector installed 2024.'),

  -- Plumbing shutoff
  ('00000000-0000-0000-0006-000000000004',
   '00000000-0000-0000-0004-000000000001',
   'plumbing', 'Main Water Shutoff', null, null,
   '2017-06-01', null, null, null,
   'good', 'Ball valve shutoff located in garage utility closet, right of water heater. City water — no well.'),

  -- Roof
  ('00000000-0000-0000-0006-000000000005',
   '00000000-0000-0000-0004-000000000001',
   'roof', 'Architectural Shingle Roof', 'GAF', 'Timberline HDZ (placeholder)',
   '2017-06-01', '2025-05-20', '2028-05-20', '2032-06-01',
   'good', '30-year architectural shingles. Last inspected May 2025 — no damage. Gutters cleaned spring 2025.'),

  -- Sewer connection (city sewer — no septic)
  ('00000000-0000-0000-0006-000000000006',
   '00000000-0000-0000-0004-000000000001',
   'plumbing', 'Sewer Connection', null, null,
   '2017-06-01', null, null, null,
   'good', 'Connected to Pender County public sewer. No septic system on property. Clean-out access on north side of house.'),

  -- Pool system
  ('00000000-0000-0000-0006-000000000007',
   '00000000-0000-0000-0004-000000000001',
   'pool', 'Inground Pool System', 'Pentair', 'IntelliFlo3 (placeholder)',
   '2019-08-01', '2026-04-10', '2026-10-15', null,
   'good', 'Salt chlorine generator. Variable-speed pump. Pool opened April 2026. Equipment pad on south side of house.'),

  -- Fence
  ('00000000-0000-0000-0006-000000000008',
   '00000000-0000-0000-0004-000000000001',
   'structure', 'Privacy Fence', null, null,
   '2020-03-01', null, null, null,
   'good', '6-ft wood privacy fence enclosing backyard and pool area. Two gates. Minor board replacement in spring 2025.');

-- ── Home Services ─────────────────────────────────────────────

insert into public.home_services (
  id, property_id, vendor_id, service_type,
  provider_name, provider_phone, schedule,
  price_per_visit, price_unit, monthly_cost, is_active, notes
)
values
  -- Lawn care
  ('00000000-0000-0000-0007-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000002',
   'landscaping', 'Tidewater Lawn Care', '555-000-0031',
   'Weekly (Wednesday morning)', 75.00, 'visit', 300.00, true,
   'Mow, edge, blow. Pine straw refresh twice yearly. Irrigation check included.'),

  -- Pest control
  ('00000000-0000-0000-0007-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000005',
   'pest_control', 'Coastal Pest Solutions', '555-000-0034',
   'Quarterly', 130.00, 'visit', 43.00, true,
   'General pest and termite prevention. Mosquito treatment added spring/summer. Annual subterranean termite bond.'),

  -- Pool service
  ('00000000-0000-0000-0007-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000001',
   'pool', 'Coastal Pool & Spa', '555-000-0030',
   'Weekly (Friday)', 95.00, 'visit', 380.00, true,
   'Weekly chemical balance, brushing, skimming. Salt cell inspection monthly. Chemicals billed separately. Seasonal open/close included in annual contract.'),

  -- HVAC maintenance agreement
  ('00000000-0000-0000-0007-000000000004',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000003',
   'other', 'Cape Fear Heating & Air', '555-000-0032',
   'Bi-annual (March and September)', 149.00, 'visit', 25.00, true,
   'Spring and fall tune-up. Priority service call included. Filter replacement at each visit.');

-- ── Maintenance Tasks ─────────────────────────────────────────

insert into public.maintenance_tasks (
  id, property_id, home_system_id, title, description,
  due_date, is_recurring, recurrence_rule, priority, estimated_cost
)
values
  -- HVAC filter
  ('00000000-0000-0000-0008-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000001',
   'Change HVAC Filter', 'Replace 20x20x1 MERV-11 filter. Coastal humidity — replace every 60 days.',
   '2026-09-10', true, 'FREQ=MONTHLY;INTERVAL=2', 'normal', 20.00),

  -- Gutter cleaning
  ('00000000-0000-0000-0008-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000005',
   'Clean Gutters', 'Clear pine needles and debris from gutters and flush downspouts.',
   '2026-10-15', true, 'FREQ=YEARLY;BYMONTH=4,10', 'normal', 175.00),

  -- Water heater flush
  ('00000000-0000-0000-0008-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000002',
   'Flush Water Heater', 'Flush sediment from electric water heater tank.',
   '2026-04-15', true, 'FREQ=YEARLY', 'normal', 100.00),

  -- Smoke / CO detectors
  ('00000000-0000-0000-0008-000000000004',
   '00000000-0000-0000-0004-000000000001',
   null,
   'Check Smoke & CO Detectors', 'Test all units, replace batteries, note any units over 10 years old.',
   '2026-08-01', true, 'FREQ=YEARLY;BYMONTH=8', 'high', 30.00),

  -- Pool chemical check
  ('00000000-0000-0000-0008-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000007',
   'Pool Chemical Check', 'Test pH, alkalinity, salinity, and free chlorine.',
   '2026-07-18', true, 'FREQ=WEEKLY', 'normal', null),

  -- Roof inspection
  ('00000000-0000-0000-0008-000000000006',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000005',
   'Annual Roof Inspection', 'Inspect shingles, flashing, ridge cap, and gutters post-hurricane season.',
   '2026-11-01', true, 'FREQ=YEARLY;BYMONTH=11', 'high', 250.00),

  -- Electrical panel check
  ('00000000-0000-0000-0008-000000000007',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000003',
   'Electrical Panel Inspection', 'Visual inspection of breakers, surge protector, and main disconnect.',
   '2027-11-01', true, 'FREQ=YEARLY;INTERVAL=3', 'normal', 180.00),

  -- Sewer line flush
  ('00000000-0000-0000-0008-000000000008',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0006-000000000006',
   'Sewer Line Inspection', 'Camera inspect main sewer lateral to county connection.',
   '2027-03-18', true, 'FREQ=YEARLY;INTERVAL=5', 'normal', 350.00);

-- ── Projects ──────────────────────────────────────────────────

insert into public.projects (
  id, property_id, title, description,
  project_type, status, start_date, end_date,
  estimated_cost, actual_cost, vendor_id, is_diy, room_id, notes
)
values
  -- Pool opening (annual, completed)
  ('00000000-0000-0000-0009-000000000001',
   '00000000-0000-0000-0004-000000000001',
   'Pool Opening – Spring 2026',
   'Remove cover, re-attach equipment, prime pump, balance chemicals, inspect salt cell.',
   'maintenance', 'completed', '2026-04-08', '2026-04-10',
   275.00, 275.00,
   '00000000-0000-0000-0003-000000000001', false,
   '00000000-0000-0000-0005-000000000009',
   'Completed April 10, 2026. Salt cell cleaned. Water balanced. Ready for season.'),

  -- Roof inspection (completed)
  ('00000000-0000-0000-0009-000000000002',
   '00000000-0000-0000-0004-000000000001',
   'Roof Inspection – Spring 2025',
   'Post-winter shingle inspection and gutter cleaning.',
   'inspection', 'completed', '2025-05-19', '2025-05-20',
   250.00, 250.00,
   '00000000-0000-0000-0003-000000000008', false, null,
   'No damage found. 2 gutter spikes re-nailed. Downspout cleared.'),

  -- HVAC service (completed)
  ('00000000-0000-0000-0009-000000000003',
   '00000000-0000-0000-0004-000000000001',
   'HVAC Spring Tune-Up 2026',
   'Heat pump spring service: coil clean, refrigerant check, capacitor test, filter swap.',
   'maintenance', 'completed', '2026-03-10', '2026-03-10',
   149.00, 149.00,
   '00000000-0000-0000-0003-000000000003', false, null,
   'All clear. Refrigerant level nominal. New filter installed.'),

  -- Fence repair (in progress)
  ('00000000-0000-0000-0009-000000000004',
   '00000000-0000-0000-0004-000000000001',
   'Fence Board Replacement',
   'Replace 14 weathered fence boards on south run. Re-seal all boards.',
   'repair', 'in_progress', '2026-07-05', '2026-07-19',
   620.00, null,
   '00000000-0000-0000-0003-000000000006', false, null,
   'Materials purchased. Topsail Handyman scheduled week of July 14.'),

  -- Generator install (planned)
  ('00000000-0000-0000-0009-000000000005',
   '00000000-0000-0000-0004-000000000001',
   'Whole-House Generator Installation',
   'Install 22kW standby generator. Automatic transfer switch. Natural gas connection.',
   'installation', 'planned', '2026-10-01', null,
   12500.00, null,
   '00000000-0000-0000-0003-000000000004', false, null,
   'Quotes received from Pender Electric and one other. Decision pending. Coastal NC hurricane prep.');

-- ── Professional Contacts ─────────────────────────────────────

insert into public.professional_contacts (
  id, property_id, profile_id, contact_type,
  name, company, phone, email, city, state, extra_fields
)
values
  -- Realtor (NC)
  ('00000000-0000-0000-0010-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000010',
   'realtor', 'Dana Hewitt', 'Coastal Carolina Realty',
   '555-000-0010', 'dana.hewitt.realtor@placeholder.example',
   'Hampstead', 'NC',
   '{"license_number": "NC-PLACEHOLDER-0001", "years_active": 9, "specialties": "Coastal Residential, Pender County"}'::jsonb),

  -- Insurance agent (NC)
  ('00000000-0000-0000-0010-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000012',
   'insurance', 'Carol Beasley', 'Cape Fear Insurance Group',
   '555-000-0012', 'carol.beasley.insurance@placeholder.example',
   'Wilmington', 'NC',
   '{"policy_number": "CFI-PLACEHOLDER-0001", "coverage": "$480,000 dwelling", "renewal_date": "2027-03-18"}'::jsonb),

  -- Lender (NC)
  ('00000000-0000-0000-0010-000000000003',
   '00000000-0000-0000-0004-000000000001',
   null,
   'lender', 'Marcus Webb', 'First Bank – Coastal NC',
   '555-000-0022', 'marcus.webb@firstbank-coastalnc.placeholder.example',
   'Hampstead', 'NC',
   '{"loan_number": "FB-PLACEHOLDER-0001", "rate": "4.875% fixed 30-yr", "payoff_date": "2052-03-18"}'::jsonb),

  -- Closing attorney (NC)
  ('00000000-0000-0000-0010-000000000004',
   '00000000-0000-0000-0004-000000000001',
   null,
   'closing', 'Patricia Norris', 'Pender County Title & Escrow',
   '555-000-0023', 'patricia.norris@pendertitle.placeholder.example',
   'Burgaw', 'NC',
   '{"closing_date": "2022-03-18", "title_insurance": "Placeholder policy", "escrow_balance": "0.00"}'::jsonb),

  -- Home inspector (NC)
  ('00000000-0000-0000-0010-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000011',
   'inspector', 'James Strickland', 'Strickland Home Inspections LLC',
   '555-000-0011', 'james.strickland.inspector@placeholder.example',
   'Hampstead', 'NC',
   '{"license_number": "NC-INSP-PLACEHOLDER-0001", "inspection_date": "2022-02-28", "report_reference": "SHI-2022-PLACEHOLDER"}'::jsonb);

-- ── Phonebook Entries ─────────────────────────────────────────

insert into public.phonebook_entries (
  id, property_id, vendor_id, name, specialty,
  phone, email, rating, is_trusted, notes
)
values
  ('00000000-0000-0000-0011-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000001',
   'Coastal Pool & Spa', 'Pool & Spa',
   '555-000-0030', 'service@coastalpoolspa.placeholder.example', 5, true,
   'Tony opens and closes the pool every year. Always on time. Very thorough.'),

  ('00000000-0000-0000-0011-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000002',
   'Tidewater Lawn Care', 'Landscaping',
   '555-000-0031', 'info@tidewaterlawn.placeholder.example', 4, true,
   'Reliable. Pine straw looks great. Sometimes runs 30 min late.'),

  ('00000000-0000-0000-0011-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000003',
   'Cape Fear Heating & Air', 'HVAC',
   '555-000-0032', 'service@capefearhvac.placeholder.example', 5, true,
   'Best HVAC team on the coast. Priority response. Ask for Dave.'),

  ('00000000-0000-0000-0011-000000000004',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000004',
   'Pender Electric', 'Electrical',
   '555-000-0033', 'info@penderelectric.placeholder.example', 5, true,
   'Installed surge protector and exterior outlets. Clean work, reasonable price.'),

  ('00000000-0000-0000-0011-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000005',
   'Coastal Pest Solutions', 'Pest Control',
   '555-000-0034', 'info@coastalpest.placeholder.example', 4, true,
   'Quarterly service keeping termites and mosquitoes in check.'),

  ('00000000-0000-0000-0011-000000000006',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000006',
   'Topsail Handyman Services', 'Handyman',
   '555-000-0035', 'info@topsailhandyman.placeholder.example', 4, true,
   'Good for smaller jobs. Fair pricing. Books 2-3 weeks out.'),

  ('00000000-0000-0000-0011-000000000007',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000007',
   'Sound Plumbing Co.', 'Plumbing',
   '555-000-0036', 'info@soundplumbing.placeholder.example', 5, true,
   'Fixed slow drain and replaced supply lines under kitchen sink. Fast and clean.'),

  ('00000000-0000-0000-0011-000000000008',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0003-000000000008',
   'Cape Lookout Roofing', 'Roofing',
   '555-000-0037', 'info@capelookoutroofing.placeholder.example', 5, true,
   'Inspected roof after Hurricane Helene. No damage. Very professional report.');

-- ── Documents (metadata only) ─────────────────────────────────

insert into public.documents (
  id, property_id, uploaded_by, category,
  title, storage_path, file_name, mime_type, expiry_date, tags
)
values
  -- Homeowner insurance declaration
  ('00000000-0000-0000-0012-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'insurance',
   'Homeowner''s Insurance Declaration – Cape Fear Insurance Group',
   'placeholder/properties/marsh-cove/docs/insurance-declaration-2026.pdf',
   'insurance-declaration-2026.pdf', 'application/pdf', '2027-03-18',
   ARRAY['insurance', 'declaration', 'cape-fear', '2026']),

  -- Property survey
  ('00000000-0000-0000-0012-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'other',
   'Property Survey – 114 Marsh Cove Lane 2022',
   'placeholder/properties/marsh-cove/docs/survey-2022.pdf',
   'survey-2022.pdf', 'application/pdf', null,
   ARRAY['survey', 'plat', '2022', 'closing']),

  -- Roof warranty
  ('00000000-0000-0000-0012-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'warranty',
   'GAF Roof Warranty – 30-Year Timberline HDZ',
   'placeholder/properties/marsh-cove/docs/roof-warranty-gaf.pdf',
   'roof-warranty-gaf.pdf', 'application/pdf', '2047-06-01',
   ARRAY['roof', 'warranty', 'gaf', '30-year']),

  -- HVAC service invoice
  ('00000000-0000-0000-0012-000000000004',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'invoice',
   'HVAC Spring Tune-Up Invoice – March 2026',
   'placeholder/properties/marsh-cove/docs/hvac-invoice-2026-03.pdf',
   'hvac-invoice-2026-03.pdf', 'application/pdf', null,
   ARRAY['hvac', 'invoice', '2026', 'cape-fear-hvac']),

  -- Pool opening receipt
  ('00000000-0000-0000-0012-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'invoice',
   'Pool Opening Receipt – April 2026',
   'placeholder/properties/marsh-cove/docs/pool-opening-receipt-2026-04.pdf',
   'pool-opening-receipt-2026-04.pdf', 'application/pdf', null,
   ARRAY['pool', 'opening', 'receipt', '2026']),

  -- Sewer / utility record
  ('00000000-0000-0000-0012-000000000006',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'other',
   'Pender County Sewer Connection Record',
   'placeholder/properties/marsh-cove/docs/sewer-connection-record.pdf',
   'sewer-connection-record.pdf', 'application/pdf', null,
   ARRAY['sewer', 'utility', 'pender-county', '2017']);

-- ── Media (metadata only) ─────────────────────────────────────

insert into public.media (
  id, property_id, uploaded_by, media_type,
  title, storage_path, file_name, mime_type,
  home_system_id, room_id, tags, taken_at
)
values
  -- Front elevation photo
  ('00000000-0000-0000-0016-000000000001',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'image', 'Front Elevation – 114 Marsh Cove Lane',
   'placeholder/properties/marsh-cove/media/front-elevation.jpg',
   'front-elevation.jpg', 'image/jpeg',
   null, null, ARRAY['exterior', 'front', 'hero'], '2022-03-19 10:00:00+00'),

  -- HVAC unit
  ('00000000-0000-0000-0016-000000000002',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'image', 'HVAC Heat Pump Unit – Exterior',
   'placeholder/properties/marsh-cove/media/hvac-unit-exterior.jpg',
   'hvac-unit-exterior.jpg', 'image/jpeg',
   '00000000-0000-0000-0006-000000000001', null,
   ARRAY['hvac', 'heat-pump', 'equipment'], '2026-03-10 09:30:00+00'),

  -- Electrical panel
  ('00000000-0000-0000-0016-000000000003',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'image', 'Main Electrical Panel – Garage',
   'placeholder/properties/marsh-cove/media/electrical-panel.jpg',
   'electrical-panel.jpg', 'image/jpeg',
   '00000000-0000-0000-0006-000000000003', '00000000-0000-0000-0005-000000000008',
   ARRAY['electrical', 'panel', 'garage'], '2024-11-12 14:00:00+00'),

  -- Water heater label
  ('00000000-0000-0000-0016-000000000004',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'image', 'Water Heater Data Label – Garage',
   'placeholder/properties/marsh-cove/media/water-heater-label.jpg',
   'water-heater-label.jpg', 'image/jpeg',
   '00000000-0000-0000-0006-000000000002', '00000000-0000-0000-0005-000000000008',
   ARRAY['water-heater', 'label', 'rheem'], '2021-04-15 11:00:00+00'),

  -- Pool equipment pad
  ('00000000-0000-0000-0016-000000000005',
   '00000000-0000-0000-0004-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'image', 'Pool Equipment Pad – Pentair Pump & Salt Cell',
   'placeholder/properties/marsh-cove/media/pool-equipment-pad.jpg',
   'pool-equipment-pad.jpg', 'image/jpeg',
   '00000000-0000-0000-0006-000000000007', '00000000-0000-0000-0005-000000000009',
   ARRAY['pool', 'equipment', 'pentair', 'salt-cell'], '2026-04-10 10:00:00+00');

-- ── Tags ──────────────────────────────────────────────────────

insert into public.tags (id, property_id, name, color)
values
  ('00000000-0000-0000-0017-000000000001', '00000000-0000-0000-0004-000000000001', 'hurricane-prep', '#C86F1A'),
  ('00000000-0000-0000-0017-000000000002', '00000000-0000-0000-0004-000000000001', 'warranty-active', '#27A570'),
  ('00000000-0000-0000-0017-000000000003', '00000000-0000-0000-0004-000000000001', 'seasonal', '#1F5AE0'),
  ('00000000-0000-0000-0017-000000000004', '00000000-0000-0000-0004-000000000001', 'needs-quote', '#C94949');

-- Tag: generator project is hurricane-prep
insert into public.entity_tags (tag_id, entity_type, entity_id)
values
  ('00000000-0000-0000-0017-000000000001', 'project',       '00000000-0000-0000-0009-000000000005'),
  ('00000000-0000-0000-0017-000000000001', 'maintenance_task', '00000000-0000-0000-0008-000000000006'),
  ('00000000-0000-0000-0017-000000000002', 'home_system',   '00000000-0000-0000-0006-000000000005'),
  ('00000000-0000-0000-0017-000000000002', 'home_system',   '00000000-0000-0000-0006-000000000001'),
  ('00000000-0000-0000-0017-000000000003', 'home_service',  '00000000-0000-0000-0007-000000000003'),
  ('00000000-0000-0000-0017-000000000004', 'project',       '00000000-0000-0000-0009-000000000005');

-- ── Notes ────────────────────────────────────────────────────

insert into public.notes (id, author_id, entity_type, entity_id, body, is_pinned)
values
  ('00000000-0000-0000-0018-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'property', '00000000-0000-0000-0004-000000000001',
   'Main water shutoff is in the garage utility closet, right of the water heater. Show Ray where it is.',
   true),

  ('00000000-0000-0000-0018-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'home_system', '00000000-0000-0000-0006-000000000007',
   'Pool salt cell should be cleaned every 3 months during season. Tony at Coastal Pool handles this.',
   false),

  ('00000000-0000-0000-0018-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'project', '00000000-0000-0000-0009-000000000005',
   'Get permit from Pender County before generator install. Pender Electric handles permit pull.',
   true);

-- ── Status History ────────────────────────────────────────────

insert into public.status_history (id, changed_by, entity_type, entity_id, from_status, to_status, reason, changed_at)
values
  ('00000000-0000-0000-0019-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'project', '00000000-0000-0000-0009-000000000001',
   'in_progress', 'completed', 'Pool opened and balanced for 2026 season.',
   '2026-04-10 16:00:00+00'),

  ('00000000-0000-0000-0019-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'project', '00000000-0000-0000-0009-000000000002',
   'in_progress', 'completed', 'Roof inspection clear. No repairs needed.',
   '2025-05-20 14:00:00+00'),

  ('00000000-0000-0000-0019-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'project', '00000000-0000-0000-0009-000000000003',
   'in_progress', 'completed', 'HVAC spring tune-up completed.',
   '2026-03-10 12:00:00+00');

-- ── Audit Log ────────────────────────────────────────────────

insert into public.audit_log (id, actor_id, action, entity_type, entity_id, description, occurred_at)
values
  -- Home purchase
  ('00000000-0000-0000-0020-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'insert', 'property', '00000000-0000-0000-0004-000000000001',
   'Property 114 Marsh Cove Lane added to HomeHub after purchase.',
   '2022-03-18 17:00:00+00'),

  -- Insurance declaration uploaded
  ('00000000-0000-0000-0020-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'document_uploaded', 'document', '00000000-0000-0000-0012-000000000001',
   'Homeowner''s insurance declaration uploaded by Michael Johnson.',
   '2022-03-20 10:30:00+00'),

  -- HVAC service logged
  ('00000000-0000-0000-0020-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'insert', 'project', '00000000-0000-0000-0009-000000000003',
   'HVAC spring tune-up project logged and marked complete.',
   '2026-03-10 12:00:00+00'),

  -- Pool opening logged
  ('00000000-0000-0000-0020-000000000004',
   '00000000-0000-0000-0000-000000000001',
   'insert', 'project', '00000000-0000-0000-0009-000000000001',
   'Pool opening project logged and marked complete.',
   '2026-04-10 16:00:00+00'),

  -- Roof inspection logged
  ('00000000-0000-0000-0020-000000000005',
   '00000000-0000-0000-0000-000000000001',
   'insert', 'project', '00000000-0000-0000-0009-000000000002',
   'Roof inspection project logged and marked complete.',
   '2025-05-20 14:00:00+00'),

  -- Document shared with insurance agent
  ('00000000-0000-0000-0020-000000000006',
   '00000000-0000-0000-0000-000000000001',
   'document_uploaded', 'document', '00000000-0000-0000-0012-000000000001',
   'Insurance declaration shared with Carol Beasley at Cape Fear Insurance Group.',
   '2026-04-01 09:00:00+00');

-- ── Access Grant (Ray the caretaker, QR) ─────────────────────

insert into public.access_grants (
  id, property_id, granted_by, grantee_profile_id,
  target_type, purpose, grant_type, token_hash, label, expires_at
)
values (
  '00000000-0000-0000-0021-000000000001',
  '00000000-0000-0000-0004-000000000001',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000003',
  'profile',
  'professional',
  'qr_code',
  'd20a62eb644ca7170921389ce919a0726b57a005814240a3fb36f4d9e4da40cc',
  'Ray Watkins – Caretaker Access',
  '2027-01-01 00:00:00+00'
);

insert into public.access_grant_capabilities (
  access_grant_id, grant_purpose, capability
)
values (
  '00000000-0000-0000-0021-000000000001',
  'professional',
  'log_work'
);

-- ── Subscriptions ─────────────────────────────────────────────

insert into public.subscriptions (
  id, household_id, plan, is_gifted, is_active,
  starts_at, current_period_start, current_period_end
)
values (
  '00000000-0000-0000-0013-000000000001',
  '00000000-0000-0000-0001-000000000001',
  'pro', false, true,
  '2026-06-01', '2026-06-01', '2026-07-01'
);

-- ── Insurance Policy ──────────────────────────────────────────

insert into public.insurance_policies (
  id, property_id, insurer_name, policy_type, status,
  policy_number, agent_name, agent_phone, agent_email,
  annual_premium, coverage_amount, deductible,
  effective_date, expiry_date, renewal_reminder_days, document_id,
  insurer_organization_id, agent_profile_id
)
values (
  '00000000-0000-0000-0014-000000000001',
  '00000000-0000-0000-0004-000000000001',
  'Cape Fear Insurance Group', 'homeowners', 'active',
  'CFI-PLACEHOLDER-0001',
  'Carol Beasley', '555-000-0012', 'carol.beasley.insurance@placeholder.example',
  2640.00, 480000.00, 3000.00,
  '2026-03-18', '2027-03-18', 30,
  '00000000-0000-0000-0012-000000000001',
  '00000000-0000-0000-0002-000000000002',
  '00000000-0000-0000-0000-000000000012'
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
   'HVAC Filter Due', 'Your heat pump filter is due for replacement. Coastal humidity — replace every 60 days.',
   '00000000-0000-0000-0004-000000000001',
   'maintenance_task', '00000000-0000-0000-0008-000000000001'),

  ('00000000-0000-0000-0015-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'maintenance_reminder', 'unread',
   'Annual Roof Inspection Due November', 'Schedule post-hurricane-season roof inspection by November 1.',
   '00000000-0000-0000-0004-000000000001',
   'maintenance_task', '00000000-0000-0000-0008-000000000006'),

  ('00000000-0000-0000-0015-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'compliance_reminder', 'unread',
   'Check Smoke Detectors', 'Annual smoke and CO detector check is due August 1.',
   '00000000-0000-0000-0004-000000000001',
   'maintenance_task', '00000000-0000-0000-0008-000000000004'),

  ('00000000-0000-0000-0015-000000000004',
   '00000000-0000-0000-0000-000000000001',
   'project_update', 'unread',
   'Generator Quote Ready', 'You have an open quote for whole-house generator installation. Review and decide before hurricane season.',
   '00000000-0000-0000-0004-000000000001',
   'project', '00000000-0000-0000-0009-000000000005'),

  ('00000000-0000-0000-0015-000000000005',
   '00000000-0000-0000-0000-000000000001',
   'document_expiry', 'unread',
   'Insurance Renewal in 9 Months', 'Your Cape Fear Insurance Group policy renews March 18, 2027.',
   '00000000-0000-0000-0004-000000000001',
   'document', '00000000-0000-0000-0012-000000000001');
