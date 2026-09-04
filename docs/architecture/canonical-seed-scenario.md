# Canonical Seed Scenario

The Foundation seed is deterministic demonstration data for local development and invariant testing. It contains no real credentials, payment identifiers, or stored object contents.

## Actors, households, and properties

The Johnson household organizes the primary Hampstead property. Michael and Jennifer are household members and recorded co-owners known to HomeHub; Ray is a caretaker. The Carter household and Olivia Carter organize a separate Surf City property. This second household/property pair exists to test household and property isolation.

Samuel Reed is retained as the former owner of the Surf City property through an ended property membership and ended ownership period. Olivia has the current property membership and current ownership period. Ownership periods record information known to HomeHub and are not authoritative legal-title records.

## Organizations and vendors

The scenario includes real-estate, insurance, lending, title, community, and service organizations represented with placeholder data. Organization memberships cover `owner`, `admin`, `member`, and `agent`. These roles are organization-local; an organization administrator is not HomeHub platform staff. No platform staff or active `super_admin` is seeded.

## Governed access examples

The seed includes profile-, vendor-, organization-, and anonymous-targeted grants. It retains a revoked and exhausted one-time grant plus its access log. Grant credentials are deterministic lowercase SHA-256 fixtures only; raw credentials are never stored. No support grant is included because no platform staff role is seeded.

## Subscription, gift, and promotion

The Johnson household has a normal current subscription. The Carter household has a sponsored gifted subscription initiated by Michael, sponsored by the community organization, and claimed by Olivia. Its claim credential is stored only as a deterministic hash. `COASTAL10` is the minimal canonical promo-code example.

## Insurance and storage metadata

The primary-property insurance policy links the Cape Fear insurer organization, Carol Beasley as the agent, snapshot contact fields, valid coverage dates and nonnegative financial values, and a property-consistent supporting document.

The second property has one metadata-only PDF record and a related notification. Its object path follows the canonical property/document UUID prefix. The seed does not create storage objects or imply that placeholder metadata represents uploaded content.

## Fixture philosophy

Stable UUIDs, dates, timestamps, and hashes make the scenario reproducible and directly testable. Placeholder contact information uses reserved example domains and synthetic phone numbers. Deterministic hashes are not usable access or claim credentials.
