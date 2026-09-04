# Foundation Schema and Invariants

> **Status:** Authoritative Foundation v1 implementation reference
>
> **Migration range:** `202606260001`–`202606260018`

This document describes the database and storage metadata model implemented by HomeHub Foundation v1. It is not an aspirational Auth, RLS, billing-provider, or storage-service design.

## Identity

`public.profiles` is the application identity table. Its optional, unique `auth_user_id` links to Supabase `auth.users`; profiles may therefore be invited or pre-created before an authentication identity exists. Deleting an `auth.users` row sets `profiles.auth_user_id` to null and preserves the profile and its history. `profiles.email` is contact data and is not the authoritative authentication identity key.

The current `public.user_role` values are `homeowner`, `contractor`, `inspector`, `insurance_agent`, and `real_estate_agent`. These are customer/business personas, not platform privileges. A non-null `deactivated_at` requires `is_active = false` and cannot precede `created_at`.

## Households and organizations

`household_members` records membership periods. Its roles are `member`, `caretaker`, and `manager`. At most one current row exists for a household/profile pair, and at most one current primary member exists per household. Invitation, acceptance, start, end, actor, reason, creation, and update timestamps are lifecycle constrained.

`organization_members` records organization-local membership periods. Its roles are `owner`, `admin`, `member`, and `agent`. At most one current row exists for an organization/profile pair. Organization `admin` never implies HomeHub platform privilege. `organizations.org_type` is a nonblank classification string; values such as `insurance_agency` and `real_estate_agency` classify businesses, not users.

Membership parents use `ON DELETE RESTRICT` so history cannot disappear through parent deletion. Nullable lifecycle actors use `SET NULL` where preserving the event matters more than retaining an actor link.

## Properties, access relationships, and ownership history

`properties.household_id` identifies the current organizing or administrative household. It is not proof of ownership and is not sufficient by itself to authorize a user.

`property_memberships` provides durable profile-to-property access or relationship periods. Roles are `owner`, `household_member`, `caretaker`, `property_manager`, and `viewer`. At most one current membership exists for each property/profile pair.

`property_ownership_periods` records ownership or association information known to HomeHub. Exactly one of `owner_profile_id`, `owner_household_id`, or `owner_organization_id` is populated. Current uniqueness is enforced separately for each property/subject type. These rows are historical context, not an authoritative legal-title registry.

Property-scoped composite foreign keys prevent rooms, systems, projects, documents, media, insurance documents, and ownership evidence from crossing property boundaries.

Property status values are `active`, `sold`, `pending_transfer`, and `archived`. `status = 'archived'` if and only if `archived_at` is populated. Status and timestamp may be changed atomically to archive or restore a property.

## Platform staff

`platform_staff_roles` contains `support`, `admin`, and `super_admin`. Assignments have grant and revocation history, and only one active assignment per profile/role is allowed. A platform role alone grants no household, property, document, or other customer-data access.

## Governed access grants

An `access_grants` row targets exactly one profile, vendor, or organization, or explicitly targets an anonymous recipient. Target types are `profile`, `vendor`, `organization`, and `anonymous`; purposes are `guest`, `vendor`, `professional`, and `support`; capabilities are `read`, `upload`, and `log_work`.

Grants are property scoped and may additionally scope to either one same-property document or one document category. They enforce start, expiration, revocation, and usage-limit chronology. Persisted credentials are unique, 64-character lowercase SHA-256 hashes; raw tokens are never stored.

Support grant creation requires an active platform staff assignment, a profile target, an expiration, a nonblank business reason, and read-only capabilities. Effective support authorization must later require both an active support-purpose grant and a current active platform staff assignment at the moment of use. Foundation does not implement that runtime authorization or RLS re-check.

`access_grant_log` retains use history. Its parent grant uses `ON DELETE RESTRICT`; nullable actor references use `SET NULL` so deleting an actor cannot erase the log.

## Billing, gifts, and promotions

`subscriptions` stores household subscription periods. A partial unique index permits at most one current (`ends_at is null`) subscription per household, and `is_active` must agree with that current state. Provider billing-period fields are distinct from the HomeHub lifecycle.

A gifted subscription requires an initiating profile and gift timestamp and may name a sponsoring organization. `subscription_gift_claims` stores only hashed claim credentials and preserves claim/revocation history. A composite foreign key to `(subscriptions.id, subscriptions.is_gifted)` prevents a claim from belonging to a non-gifted subscription. At most one open claim exists per subscription.

Promo codes require nonblank codes, valid percentage discounts, nonnegative redemption counts, positive optional limits, counts within limits, and valid expiration chronology. Stripe customer, subscription, webhook, or payment behavior is not implemented.

## Insurance

`insurance_policies` belongs to a property and may reference a supporting document from that same property. Optional structured links identify an insurer organization and agent profile; `SET NULL` preserves policy history if either referenced entity is removed. Snapshot insurer and agent fields remain meaningful historical/business data. Structured links do not prove carrier status, appointment, or licensure. Dates and monetary values are constrained to valid chronology and nonnegative values.

## Storage metadata

Migration 0009 defines private `documents`, `media`, and `avatars` buckets. Database metadata is the authoritative index. Generated paths are:

```text
properties/{propertyId}/documents/{documentId}/{safeFilename}
properties/{propertyId}/media/{mediaId}/{safeFilename}
profiles/{profileId}/avatars/avatar.{ext}
```

Documents are limited to 25 MiB, media to 15 MiB, and avatars to 5 MiB, with exact bucket-specific MIME allowlists documented in `storage-foundation-implementation.md`. Paths are relative, traversal-safe, and unique within each metadata table. The backend currently provides pure validation and path helpers plus an unimplemented signed-URL stub; it performs no live storage I/O.

`documents.deleted_at` and `media.deleted_at` implement logical deletion of metadata. Soft deletion does not delete an object from Supabase Storage. Future authorized queries must filter deleted rows, and later service code must define object-cleanup behavior.

## History and delete behavior

Historical and core ownership relationships generally use `RESTRICT`, including properties-to-households, membership parents, property memberships and ownership periods, core property children, subscriptions, grants with logs, and ownership evidence. Actor and notification references use `SET NULL` where the record should survive loss of the referenced actor or subject.

Configuration-like children intentionally retain cascade behavior where the child has no independent historical meaning, including property rooms, systems, services, contacts, phonebook entries, tags, and their direct configuration associations. Archive or logical-delete fields should be preferred for normal property, document, and media retirement.

## Generic references

`notes`, `entity_tags`, `status_history`, and `audit_log` intentionally use polymorphic `entity_type`/`entity_id` references. Foundation enforces nonblank discriminators and supporting indexes but does not provide trigger-based or full database foreign-key enforcement for every possible target.

## Foundation boundary

Foundation v1 does **not** implement:

- Authentication signup, invitation, session, recovery, or profile-provisioning workflows.
- Database RLS or application authorization policies.
- Runtime support-access authorization.
- Live upload, download, delete, bucket mutation, or signed-URL generation.
- Supabase Storage policies.
- Stripe or other payment-provider behavior.
- Production deployment, monitoring, alerting, backup, or observability beyond documented local validation boundaries.

The next Auth/RLS phase must build on `auth.users`, `auth.identities`, `public.profiles`, the membership tables, platform staff roles, and access grants. Foundation does not implement `public.users`, `public.user_identities`, `public.household_memberships`, or `public.organization_memberships`.
