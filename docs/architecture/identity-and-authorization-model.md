# Identity and Authorization Model

> **Status:** Authoritative Foundation v1 boundary and next-phase input model

Foundation establishes identity and relationship data that future Auth/RLS and service authorization can evaluate. It does not yet perform authentication or authorize application requests.

## Authentication identity and application profiles

Supabase owns authentication credentials and provider identities in `auth.users` and `auth.identities`. Multiple providers for one Supabase user belong in `auth.identities`; HomeHub does not duplicate them in a `public.user_identities` table.

`public.profiles` is the HomeHub application profile. `profiles.auth_user_id` is optional and unique, allowing an invited or pre-created profile to exist before signup. When linked, it references `auth.users(id)` with `ON DELETE SET NULL`, so removing an authentication identity does not erase the profile or its history. Contact email is not an authentication key.

No trigger currently creates a profile from a new auth user. Signup, account linking, duplicate resolution, invitation acceptance, and deactivation enforcement are next-phase workflows.

## Relationship models

- `household_members` describes membership in a household and its lifecycle.
- `property_memberships` describes durable access or relationship to one property and its lifecycle.
- `organization_members` describes membership and roles inside a business or organization.
- `platform_staff_roles` describes HomeHub staff affiliation and privilege classification.
- `access_grants` describes temporary, scoped access for a profile, vendor, organization, or anonymous recipient.
- `property_ownership_periods` records historical/contextual ownership associations known to HomeHub.

These models are deliberately separate. Household membership does not automatically prove access to every property; `properties.household_id` alone is not sufficient authorization. Organization `admin` is unrelated to platform `admin`. Ownership history is not an authorization source unless a future policy explicitly and safely makes it one.

## Authorization inputs

Future RLS and service authorization may evaluate:

- The authenticated `auth.uid()` and its active linked `public.profiles` row.
- Current `household_members` rows where household-level authority is appropriate.
- Current `property_memberships` for property-scoped operations.
- Current `organization_members` for organization-scoped operations.
- Current `platform_staff_roles` for platform-only operations.
- Active, unexpired, unrevoked, unexhausted `access_grants`, their target, scope, purpose, and capabilities.
- Subscription state where a feature is plan-gated rather than security-sensitive.

Support access is conjunctive: an authorization decision must find both a currently effective support-purpose grant for the profile and a currently active platform staff assignment. The database validates staff eligibility when a support grant is created or retargeted, but revoking staff does not delete the historical grant. Runtime policy must re-check both rows on every use.

## Historical or context-only inputs

The following must not independently authorize access:

- Ended household, property, or organization memberships.
- `property_ownership_periods`, including current periods, unless a later reviewed policy explicitly adopts them.
- `properties.household_id` by itself.
- Profile persona values such as `homeowner` or `contractor`.
- Organization roles when deciding platform privilege.
- Platform staff roles when deciding access to specific customer data.
- Revoked, expired, not-yet-started, or exhausted grants.
- Access logs, status history, audit history, and snapshot insurance fields.

## Archived and logically deleted records

Future queries and policies must deliberately govern archived properties. Normal active-property views should exclude `properties.archived_at is not null` unless historical access is intended.

Likewise, normal document and media discovery should exclude rows with `deleted_at is not null`. Logical deletion does not remove the corresponding storage object; future service authorization and cleanup must treat metadata state as authoritative.

## Next-phase requirements

The Auth/RLS phase should define and test:

1. Profile provisioning and safe linking to `auth.users`.
2. Active-profile checks using `is_active` and `deactivated_at`.
3. Current membership predicates for household, property, and organization operations.
4. Capability- and scope-aware access-grant evaluation.
5. The two-part support authorization rule.
6. Archived-property and soft-deleted-file visibility.
7. Service-role boundaries and audit behavior.
8. RLS regression tests for allowed and denied cross-property access.

No RLS SQL or application authorization implementation is part of Foundation v1.
