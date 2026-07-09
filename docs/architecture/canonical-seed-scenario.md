# Canonical Seed Scenario — HomeHub

> **Status:** Active  
> **Last updated:** 2026-06-26  
> **Seed file:** `supabase/seed.sql`

This document describes the canonical demo scenario used in HomeHub's development seed data. All seed UUIDs follow the deterministic pattern `00000000-0000-0000-XXXX-NNNNNNNNNNNN` so they can be referenced reliably across tables and test fixtures.

---

## Property Overview

| Field | Value |
|---|---|
| Address | 114 Marsh Cove Lane, Hampstead, NC 28443 |
| Neighborhood | Tidewater at Hampstead |
| County | Pender County |
| Year Built | 2017 |
| Size | 2,650 sq ft (18,295 sq ft lot) |
| Bedrooms / Baths | 4 bed / 3 bath |
| Style | Single-family, coastal lowcountry |
| Purchase Price | $489,000 (2021) |
| Current Value | $541,000 (estimated) |
| Flood Zone | AE — flood insurance required |
| Property UUID | `00000000-0000-0000-0003-000000000001` |

**Why Hampstead, NC?** The scenario is set in coastal southeastern North Carolina to exercise hurricane-prep workflows, HOA relationships, pool/lawn seasonal services, and NC-specific licensing conventions — all of which stress HomeHub's most differentiated features.

---

## Profiles

| UUID suffix | Name | Email | Role | Notes |
|---|---|---|---|---|
| `0001-000000000001` | Michael Johnson | michael@example.homehub | homeowner | Primary account holder |
| `0001-000000000002` | Jennifer Johnson | jennifer@example.homehub | homeowner | Spouse, co-owner |
| `0001-000000000003` | Ray Watkins | ray@example.homehub | caretaker | Off-site property manager |
| `0001-000000000004` | Sarah Mitchell | sarah@coastalcarolina.example | agent | Selling agent (org member) |
| `0001-000000000005` | David Chen | david@capefearins.example | vendor | Insurance agent (org member) |
| `0001-000000000006` | Alex Rivera | alex@homehub.example | admin | HomeHub platform admin |

---

## Household

| Field | Value |
|---|---|
| Name | Johnson Household |
| UUID | `00000000-0000-0000-0002-000000000001` |
| Members | Michael (owner), Jennifer (owner), Ray (caretaker) |

---

## Organizations

| UUID suffix | Name | Type | Role in Scenario |
|---|---|---|---|
| `0004-000000000001` | Coastal Carolina Realty | brokerage | Selling agency; Sarah Mitchell is member |
| `0004-000000000002` | Cape Fear Insurance Group | insurance | Policy provider; David Chen is member |
| `0004-000000000003` | First Bank | lender | Mortgage lender |
| `0004-000000000004` | Pender County Title | title | Title company at closing |
| `0004-000000000005` | Tidewater at Hampstead HOA | hoa | Neighborhood HOA |

---

## Vendors (NC-Local)

| UUID suffix | Business Name | Specialty | License / Note |
|---|---|---|---|
| `0005-000000000001` | Coastal Pool & Spa | Pool service | NC Contractor Lic #59214 |
| `0005-000000000002` | Tidewater Lawn Care | Lawn & landscaping | — |
| `0005-000000000003` | Cape Fear Heating & Air | HVAC | NC HVAC Lic #H1-3984 |
| `0005-000000000004` | Pender Electric | Electrical | NC Electrical Lic #29843 |
| `0005-000000000005` | Coastal Pest Solutions | Pest control | NC Pest Control Lic #PC-8821 |
| `0005-000000000006` | Topsail Handyman | General handyman | — |
| `0005-000000000007` | Sound Plumbing | Plumbing | NC Plumbing Lic #P-11432 |
| `0005-000000000008` | Cape Lookout Roofing | Roofing | NC Roofing Lic #R-7751 |

---

## Rooms

| UUID suffix | Room Name | Floor |
|---|---|---|
| `0006-000000000001` | Master Bedroom | 1 |
| `0006-000000000002` | Guest Bedroom 1 | 1 |
| `0006-000000000003` | Guest Bedroom 2 | 2 |
| `0006-000000000004` | Bonus Room | 2 |
| `0006-000000000005` | Kitchen | 1 |
| `0006-000000000006` | Living Room | 1 |
| `0006-000000000007` | Master Bath | 1 |
| `0006-000000000008` | Laundry Room | 1 |
| `0006-000000000009` | Garage | 1 |

---

## Home Systems

| UUID suffix | System | Type | Installed | Notes |
|---|---|---|---|---|
| `0007-000000000001` | Carrier Heat Pump | hvac | 2017 | Coastal-appropriate; no gas furnace |
| `0007-000000000002` | Rheem 50-Gal Water Heater | water_heater | 2017 | Electric |
| `0007-000000000003` | Square D 200A Panel | electrical | 2017 | Main panel |
| `0007-000000000004` | Main Water Shutoff | plumbing | 2017 | Crawl space |
| `0007-000000000005` | GAF Timberline Shingle Roof | roofing | 2017 | 30-year warranty active |
| `0007-000000000006` | Municipal Sewer Connection | sewer | 2017 | Not septic — Pender County |
| `0007-000000000007` | Pentair Variable-Speed Pool | pool | 2019 | In-ground, salt water |
| `0007-000000000008` | Treated Pine Fence | fence | 2019 | 6-ft privacy perimeter |

---

## Home Services (Recurring)

| UUID suffix | Service | Vendor | Frequency |
|---|---|---|---|
| `0008-000000000001` | Lawn Maintenance | Tidewater Lawn Care | Weekly |
| `0008-000000000002` | Pest Control | Coastal Pest Solutions | Quarterly |
| `0008-000000000003` | Pool Service | Coastal Pool & Spa | Weekly |
| `0008-000000000004` | HVAC Maintenance | Cape Fear Heating & Air | Bi-annual |

---

## Maintenance Tasks

| UUID suffix | Task | System | Frequency | Due |
|---|---|---|---|---|
| `0009-000000000001` | Replace HVAC filter | Heat Pump | 60 days | 2026-08-01 |
| `0009-000000000002` | Clean gutters | Roof | Annual | 2026-11-01 |
| `0009-000000000003` | Flush water heater | Water Heater | Annual | 2026-09-15 |
| `0009-000000000004` | Test smoke/CO detectors | Electrical | Annual | 2026-10-01 |
| `0009-000000000005` | Check pool salt/chemicals | Pool | Monthly | 2026-07-15 |
| `0009-000000000006` | Annual roof inspection | Roof | Annual | 2026-10-01 |
| `0009-000000000007` | Electrical panel inspection | Electrical | 3 years | 2027-05-01 |
| `0009-000000000008` | Sewer camera inspection | Sewer | 5 years | 2029-06-01 |

---

## Projects

| UUID suffix | Name | Status | Vendor | Notes |
|---|---|---|---|---|
| `0010-000000000001` | Pool Opening 2026 | complete | Coastal Pool & Spa | Spring open, filter swap, salt balance |
| `0010-000000000002` | Roof Inspection 2025 | complete | Cape Lookout Roofing | No damage found; warranty validated |
| `0010-000000000003` | HVAC Tune-Up Spring 2026 | complete | Cape Fear Heating & Air | Pre-summer check; coils cleaned |
| `0010-000000000004` | Fence Repair | in_progress | Topsail Handyman | Storm damage to rear section |
| `0010-000000000005` | Whole-Home Generator Install | planned | Pender Electric | Hurricane prep; permit required |

---

## Professional Contacts

| UUID suffix | Name | Type | License |
|---|---|---|---|
| `0011-000000000001` | Sarah Mitchell | real_estate_agent | NC Lic #298341 |
| `0011-000000000002` | James Whitfield | attorney | NC Bar #48821 |
| `0011-000000000003` | Karen Torres | home_inspector | NC HI Lic #3928 |
| `0011-000000000004` | David Chen | insurance_agent | NC Ins Lic #IC-5582 |
| `0011-000000000005` | Marcus Lee | mortgage_broker | NC MB Lic #77234 |

---

## Documents

| UUID suffix | Name | Category | Notes |
|---|---|---|---|
| `0013-000000000001` | Cape Fear Insurance Declaration | insurance | Current homeowner's policy |
| `0013-000000000002` | Property Survey | legal | Lot lines + easements |
| `0013-000000000003` | GAF Roof Warranty | warranty | 30-year shingle warranty |
| `0013-000000000004` | HVAC Service Invoice 2026 | invoice | Cape Fear H&A spring tune-up |
| `0013-000000000005` | Pool Opening Receipt | receipt | Coastal Pool & Spa |
| `0013-000000000006` | Sewer Lateral Record | permit | Municipal connection record |

---

## Media

| UUID suffix | Description | Type |
|---|---|---|
| `0014-000000000001` | Front elevation photo | photo |
| `0014-000000000002` | HVAC unit (exterior) | photo |
| `0014-000000000003` | Electrical panel label photo | photo |
| `0014-000000000004` | Water heater serial label | photo |
| `0014-000000000005` | Pool equipment pad | photo |

---

## Tags in Use

| Tag | Applied To |
|---|---|
| `hurricane-prep` | Generator project, HVAC system, fence project |
| `warranty-active` | Roof system, GAF warranty document |
| `seasonal` | Pool opening project, HVAC tune-up project |
| `needs-quote` | Generator install project |

---

## Notes

| UUID suffix | Entity | Content |
|---|---|---|
| `0015-000000000001` | Main Water Shutoff | "Shutoff is in crawl space, left side of access hatch. Label says 'Main'. Last operated 2023." (pinned) |
| `0015-000000000002` | Pool System | "Salt cell cleaned April 2026. Next clean due Oct 2026. Target salinity 3200 ppm." |
| `0015-000000000003` | Generator Project | "Permit submitted to Pender County 2026-05-01. Inspection required before final hookup." |

---

## Access Grants

| UUID suffix | Grantee | Type | Expires |
|---|---|---|---|
| `0016-000000000001` | Ray Watkins | qr_code | 2027-01-01 |

Ray's QR code gives caretaker access — used for letting in vendors when Michael and Jennifer are away.

---

## Subscription & Insurance

| Field | Value |
|---|---|
| Plan | `pro` |
| Subscription UUID | `00000000-0000-0000-0017-000000000001` |
| Insurer | Cape Fear Insurance Group |
| Policy Type | Homeowners + Flood (AE zone) |
| Coverage | $480,000 |
| Annual Premium | $2,640 |
| Deductible | $5,000 |
| Renewal | 2027-03-15 |
| Insurance UUID | `00000000-0000-0000-0018-000000000001` |

---

## Notifications (Seed State)

| UUID suffix | Type | Title | Status |
|---|---|---|---|
| `0019-000000000001` | maintenance_due | HVAC filter due in 3 weeks | unread |
| `0019-000000000002` | document_expiry | Insurance policy renews in 30 days | unread |
| `0019-000000000003` | project_update | Fence repair: materials ordered | unread |
| `0019-000000000004` | maintenance_due | Pool chemical check due | read |
| `0019-000000000005` | system_alert | Generator permit approved | unread |

---

## Audit Log Highlights

| Event | Actor | Date |
|---|---|---|
| Property record created (home purchase) | michael@example.homehub | 2021-06-15 |
| Insurance declaration uploaded | michael@example.homehub | 2021-06-20 |
| HVAC tune-up project marked complete | michael@example.homehub | 2026-05-10 |
| Pool opening project marked complete | michael@example.homehub | 2026-04-15 |
| Roof inspection project marked complete | michael@example.homehub | 2025-10-20 |
| Insurance document shared with David Chen | michael@example.homehub | 2026-03-01 |

---

## Design Notes

- **No real personal data.** All emails, phone numbers, license numbers, and policy numbers are fictional placeholders.
- **Coastal NC focus.** Scenario deliberately exercises: hurricane prep, pool systems, heat pump (not gas), HOA relationships, flood zone awareness, and Pender County municipal sewer.
- **UUID convention.** All seed UUIDs use `00000000-0000-0000-TTTT-NNNNNNNNNNNN` where `TTTT` is a table namespace and `NNNN` is a sequential record number. This makes cross-table joins easy to read in tests.
- **RLS not yet implemented.** Seed data is designed to be valid once RLS policies are added, but no policies exist in this foundation step.
- **Auth not yet wired.** `profiles.auth_user_id` fields are left null; they will be populated once Supabase Auth is integrated.
