# Storage Foundation Implementation — HomeHub

> **Status:** Implemented (foundation step)  
> **Branch:** feature/storage-foundation  
> **Migrations:** `supabase/migrations/202606260009_storage_foundation.sql`, `supabase/migrations/202606260016_storage_metadata_integrity.sql`
> **Backend scaffold:** `backend/src/services/storage.ts`  
> **Last updated:** 2026-06-26

This document describes the Supabase Storage foundation as implemented in this branch. It covers buckets, the privacy model, path conventions, MIME and size limits, the metadata relationship to database tables, the planned upload/download strategy, audit expectations, and what remains blocked until authentication and RLS are wired.

For the current identity and future-authorization boundary, see [`identity-and-authorization-model.md`](./identity-and-authorization-model.md). The older combined authentication/storage plan is superseded historical material.

---

## 1. Buckets

Three private Supabase Storage buckets are created by migration 0009. All bucket definitions use `on conflict (id) do update` so the migration is idempotent on `supabase db reset`.

| Bucket | `id` / `name` | Public | Max Size | Purpose |
|---|---|---|---|---|
| Documents | `documents` | No | 25 MiB | PDFs, warranties, contracts, permits, invoices, inspection reports |
| Media | `media` | No | 15 MiB | Property and room photos, project before/after images, short progress videos |
| Avatars | `avatars` | No | 5 MiB | Profile photos |

---

## 2. Privacy Model

**All three buckets are private.** `public = false` is set on every bucket. This means:

- Supabase will never serve objects via a public CDN URL, regardless of the object path.
- Foundation creates no public bucket access. Actual authorized object access and signed-URL generation are deferred.
- There are no permissive storage policies defined in this foundation step (see section 7).

**Why private?** Property documents (insurance declarations, legal contracts, purchase deeds) and photos are sensitive homeowner data. A guessable or leaked object path should never expose real data. Backend-mediated signed URLs allow the server to enforce authorization on every access event.

---

## 3. Path Conventions

The backend generates deterministic UUID-scoped paths. The database rejects blank, absolute, backslash-containing, repeated-separator, and traversal paths; uniqueness is enforced independently within `documents` and `media`, matching their separate fixed buckets.

### 3.1 documents bucket

```
properties/{property_id}/documents/{document_id}/{sanitised_filename}
```

Example:
```
properties/00000000-0000-0000-0003-000000000001/documents/00000000-0000-0000-0013-000000000001/insurance-declaration.pdf
```

- `property_id` is the first path segment so a future storage policy can restrict access by property membership using a simple `(storage.foldername(name))[1] = property_id` predicate.
- `document_id` matches the UUID primary key in `public.documents` — one object per document row.

### 3.2 media bucket

```
properties/{property_id}/media/{media_id}/{sanitised_filename}
```

Example:
```
properties/00000000-0000-0000-0003-000000000001/media/00000000-0000-0000-0016-000000000001/before.jpg
```

Including the media row UUID prevents collisions even when multiple related entities upload the same filename. The entity relationship remains authoritative in the row's foreign keys, not in the object path.

### 3.3 avatars bucket

```
profiles/{profile_id}/avatars/avatar.{ext}
```

Example:
```
profiles/00000000-0000-0000-0001-000000000001/avatars/avatar.jpg
```

The generated path is stable per profile and MIME-derived extension. Overwrite and cleanup behavior is deferred to the live storage implementation.

### 3.4 Filename sanitisation

All IDs passed to path builders must be syntactically valid UUID strings. The `sanitiseFilename()` helper applies the following rules:
- Reject `..` when it is a complete `/`- or `\\`-delimited path segment; harmless repeated periods inside a filename are preserved
- Replace `/`, `\`, control characters, whitespace, and other characters outside `[a-zA-Z0-9._-]` with hyphens
- Collapse consecutive hyphens
- Lowercase the result
- Reject empty results and names containing no letter or number
- Cap at 200 characters while preserving a sensible final extension (up to 32 characters)

---

## 4. MIME Type Limits

Allowed MIME types per bucket — defined in both the migration (bucket metadata) and `storage.ts` (`ALLOWED_MIME_TYPES`).

### documents
`application/pdf`, `application/msword`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`, `application/vnd.ms-excel`, `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`, `image/jpeg`, `image/png`, `image/webp`, `image/tiff`, `image/heic`, `image/heif`

### media
`image/jpeg`, `image/png`, `image/webp`, `image/heic`, `image/heif`, `video/mp4`

### avatars
`image/jpeg`, `image/png`, `image/webp`

MIME type validation is performed server-side in the backend before any storage write. Client-reported MIME types are treated as untrusted; the backend should independently detect MIME type from file magic bytes where feasible.

---

## 5. File-Size Limits

| Bucket | Limit | Rationale |
|---|---|---|
| `documents` | 25 MiB | PDFs with embedded images can be large; 25 MiB covers typical homeowner documents generously |
| `media` | 15 MiB | High-res phone photos are typically 3–8 MiB; short MP4 clips may reach 10–12 MiB |
| `avatars` | 5 MiB | Profile photos are display-sized; no reason to accept large raw images |

Limits are set both in the bucket definition (`file_size_limit` column in `storage.buckets`) and mirrored in `MAX_FILE_SIZE_BYTES` in `storage.ts`. The backend validates size before initiating a storage write; the bucket limit serves as a hard server-side backstop.

Sizes must be nonnegative integer bytes. Zero-byte objects and the exact maximum are allowed; maximum plus one byte is rejected.

---

## 6. Metadata Relationship to Database Tables

Storage objects are never queried directly by the frontend. The database is the authoritative index for all file discovery and display.

### public.documents

Every object in the `documents` bucket corresponds to exactly one row in `public.documents`. The row stores:

| Column | Value |
|---|---|
| `storage_path` | Unique object path within the fixed bucket (e.g., `properties/{property_id}/documents/{document_id}/{filename}`) |
| `file_name` | Sanitised filename |
| `file_size_bytes` | Integer byte count |
| `mime_type` | Detected MIME type |
| `category` | Enum value (insurance, warranty, permit, invoice, etc.) |
| `property_id` | FK to owning property |
| `project_id` | Optional FK to related project |
| `home_system_id` | Optional FK to related home system |
| `vendor_id` | Optional FK to related vendor |

### public.media

Every object in the `media` bucket corresponds to one row in `public.media`. Additional columns:

| Column | Value |
|---|---|
| `storage_path` | Full object path within the bucket |
| `room_id` / `project_id` / `home_system_id` | Optional FKs depending on attachment point |
| `taken_at` | Timestamp of when the photo/video was captured |
| `is_before_photo` / `is_after_photo` | Boolean flags for project progress tracking |
| `width_px` / `height_px` / `duration_secs` | Dimensions/duration populated server-side after upload |

Migration 0016 enforces nonnegative optional numeric metadata, nonblank required paths and filenames, nonblank optional MIME values, exact bucket MIME allowlists when MIME is supplied, safe relative path syntax, and per-table path uniqueness. No page-count or storage-bucket column exists in the current schema, so this phase does not invent either. `profiles.avatar_url`, when supplied, must be nonblank.

### Deletion contract

Foundation uses `documents.deleted_at` and `media.deleted_at` for logical deletion while retaining metadata and references. This does not delete any storage object. Future authorized queries must filter logically deleted rows, and future service code must define retryable object cleanup without assuming that metadata deletion alone makes an object inaccessible.

---

## 7. Signed Upload / Download Strategy

### Upload flow (planned — requires auth wiring)

```
Client → POST /api/upload  (multipart/form-data)
  ↓ backend validates JWT + household membership
  ↓ backend validates MIME type (server-side detection)
  ↓ backend validates file size
  ↓ backend pre-generates document/media UUID
  ↓ backend resolves storage path via documentPath() / mediaPath()
  ↓ supabaseServiceClient.storage.from(bucket).upload(path, buffer)
  ↓ on success: INSERT into public.documents or public.media
  ↓ backend returns { id, storage_path, signed_url }
  ↓ client renders/opens file immediately via signed URL
```

### Download / signed-URL flow (planned — requires auth wiring)

```
Client → GET /api/files/{document_id}/url
  ↓ backend validates JWT + household membership (or access_grant)
  ↓ backend fetches storage_path from public.documents
  ↓ supabaseServiceClient.storage.from(bucket).createSignedUrl(path, ttl)
  ↓ backend returns { signed_url, expires_at }
  ↓ client opens/downloads file
```

### Signed URL TTLs

| Bucket | TTL | Rationale |
|---|---|---|
| `documents` | 5 minutes | Sensitive; short window limits exposure if URL is leaked |
| `media` | 1 hour | Displayed inline; longer TTL avoids frequent re-requests |
| `avatars` | 24 hours | Low sensitivity; frequently fetched across the UI |

TTLs are defined in `SIGNED_URL_TTL_SECONDS` in `storage.ts` and can be overridden per-request via `resolveSignedUrlTtl()`. Defaults remain 300, 3,600, and 86,400 seconds. Every effective TTL must be an integer from 1 through 86,400 seconds.

---

## 8. Backend Service Scaffolding

`backend/src/services/storage.ts` provides the following exports (all pure TypeScript — no live Supabase calls yet):

| Export | Kind | Purpose |
|---|---|---|
| `STORAGE_BUCKETS` | const | Fixed bucket name map matching migration 0009 |
| `MAX_FILE_SIZE_BYTES` | const | Per-bucket size limits |
| `ALLOWED_MIME_TYPES` | const | Per-bucket MIME allowlists |
| `SIGNED_URL_TTL_SECONDS` | const | Per-bucket default signed URL TTLs |
| `sanitiseFilename()` | function | Strip unsafe characters from user filenames |
| `documentPath()` | function | Build storage path for a document |
| `mediaPath()` | function | Build storage path for a media item |
| `avatarPath()` | function | Build storage path for an avatar |
| `validateMimeType()` | function | Validate MIME type against bucket allowlist |
| `validateFileSize()` | function | Validate file size against bucket limit |
| `validateUpload()` | function | Combined MIME + size validation |
| `prepareDocumentUpload()` | function | Validate + resolve path (stub; throws when called) |
| `prepareMediaUpload()` | function | Validate + resolve path (stub; throws when called) |
| `prepareAvatarUpload()` | function | Validate + resolve path (stub; throws when called) |
| `resolveSignedUrlTtl()` | function | Resolve effective TTL for a signed URL request |
| `createSignedDownloadUrl()` | function | Signed URL stub (throws — not yet implemented) |

The file compiles without `@supabase/supabase-js` installed. It contains pure validation/path helpers and an explicit signed-URL stub only: no client is instantiated and no upload, download, delete, signing, or bucket mutation can occur. Later Auth/RLS and storage-policy work must authorize access before any provider integration is added.

---

## 9. Environment Variables

The following placeholders are reserved for the future live storage service. The current pure helper module does not read them or instantiate a Supabase client.

| Variable | File | Purpose |
|---|---|---|
| `SUPABASE_URL` | `backend/.env.example` | Supabase project URL (already present) |
| `SUPABASE_SERVICE_ROLE_KEY` | `backend/.env.example` | Service-role key for all storage operations (already present) |

`NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in `frontend/.env.example` are unchanged — the frontend never calls storage directly.

**Critical:** `SUPABASE_SERVICE_ROLE_KEY` must never appear in any `NEXT_PUBLIC_*` variable or in frontend code. It bypasses all RLS.

---

## 10. Audit Expectations

Every storage operation that reaches the backend API should write an entry to `public.audit_log`. The following events are expected (not yet implemented — depends on upload/download API endpoints):

| Trigger | `action` | `entity_type` | `entity_id` | `metadata` |
|---|---|---|---|---|
| File uploaded | `upload` | `document` or `media` | Row UUID | `{ file_size, mime_type, bucket, storage_path }` |
| Signed URL requested | `view` | `document` or `media` | Row UUID | `{ ttl_seconds, expires_at }` |
| File deleted | `delete` | `document` or `media` | Row UUID | `{ storage_path, bucket }` |
| Document shared | `share` | `document` | Row UUID | `{ recipient_profile_id }` |

Audit log writes are the responsibility of the route handler, not the storage service. The storage service exports types and helpers only.

---

## 11. Storage Quotas

The following quotas are historical planning targets only; Foundation does not enforce plan-level aggregate quotas:

| Plan | Documents | Media | Enforcement |
|---|---|---|---|
| `free` | 500 MiB | 1 GiB | Not implemented |
| `pro` | 5 GiB | 10 GiB | Not implemented |
| `enterprise` | Unlimited | Unlimited | Not implemented |

Quota enforcement middleware is not yet implemented — it will be added as part of the upload API endpoint.

---

## 12. What Remains Blocked Until Auth / RLS

The following items cannot be implemented without authentication and RLS:

| Item | Blocked by | Migration / Step |
|---|---|---|
| Storage access policies (upload/download RLS) | Auth workflow + DB RLS | Future migration after Foundation 0018 |
| Upload API endpoint (`POST /api/upload`) | JWT validation middleware | Auth wiring |
| Signed URL endpoint (`GET /api/files/{id}/url`) | JWT validation + membership check | Auth wiring |
| Delete endpoint (`DELETE /api/files/{id}`) | JWT validation + ownership check | Auth wiring |
| Storage quota enforcement | Upload endpoint + subscription lookup | Upload endpoint |
| Audit log entries for storage events | Upload/download endpoints | Upload endpoint |
| Avatar upload in profile settings | Auth + upload endpoint | After auth wiring |

**Current state:** Buckets exist and are configured. Path helpers, validators, and type definitions are ready. No live storage I/O can be performed without completing authentication wiring first.

---

## 13. Recommended Next Steps

In priority order:

1. **Auth/RLS design and migration:** define reviewed profile-provisioning and authorization behavior in a new forward migration after Foundation 0018.
2. **Install `@supabase/supabase-js`** in the backend (`npm install @supabase/supabase-js`) and replace the service stubs in `storage.ts`.
3. **Upload API endpoint** (`POST /api/upload`) — MIME detection, validation, service-role storage write, DB insert, audit log entry.
4. **Signed URL API endpoint** (`GET /api/files/:id/url`) — JWT check, membership check, `createSignedUrl`, audit log entry.
5. **Future storage RLS migration** — add reviewed storage policies only after auth identities and database RLS are established.
