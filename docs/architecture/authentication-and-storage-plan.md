# Authentication and Storage Plan — HomeHub

> **Superseded historical design — do not use as current implementation guidance.**
>
> This pre-Foundation plan contains obsolete roles, columns, paths, migration numbers, and proposed flows. Current implemented truth is documented in [`foundation-schema-and-invariants.md`](./foundation-schema-and-invariants.md), [`identity-and-authorization-model.md`](./identity-and-authorization-model.md), and [`storage-foundation-implementation.md`](./storage-foundation-implementation.md). It is retained only to preserve design history.

> **Status:** Draft — foundation step (not yet implemented)  
> **Last updated:** 2026-06-26  
> **Scope:** Supabase Auth + Supabase Storage integration design

This document defines how HomeHub will implement authentication and file storage using Supabase. Neither system is wired in the current foundation step — migrations 0001–0008 create the schema skeleton only. This plan describes what will be built in the next phase and the decisions already locked in.

---

## Part 1 — Authentication

### 1.1 Provider Strategy

HomeHub uses **Supabase Auth with email/password only** at MVP. OAuth providers (Google, Apple) are deferred to a later phase.

| Provider | MVP | Later |
|---|---|---|
| Email + Password | ✅ | ✅ |
| Magic Link (email) | ✅ | ✅ |
| Google OAuth | ❌ | ✅ |
| Apple OAuth | ❌ | ✅ |
| Phone / SMS | ❌ | ✅ |

**Rationale:** Homeowners skew older and less likely to rely on social login. Email/password + magic link covers the full demographic without adding OAuth surface area.

---

### 1.2 Profile Linkage

Supabase Auth lives in the `auth` schema (managed by Supabase). HomeHub extends this with a `public.profiles` row created automatically via a trigger on `auth.users`.

```sql
-- To be added in a future migration (e.g., 0009_auth_trigger.sql)
create or replace function public.handle_new_auth_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (auth_user_id, email, display_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    'homeowner'   -- default role; admins promote manually
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();
```

`profiles.auth_user_id` is a nullable `uuid` in the current schema, allowing seed data to exist without real auth users. Once auth is wired, all new profiles will have this set.

---

### 1.3 Flow: Standard Sign-Up (Homeowner Self-Registration)

```
User submits email + password
  → Supabase sends verification email
  → User clicks link → email_confirmed_at set
  → trigger fires → public.profiles row created (role = homeowner)
  → Frontend redirects to onboarding (property setup wizard)
```

**Verification requirement:** Email must be confirmed before the user can access any authenticated route. Unverified users see a "check your inbox" gate screen.

---

### 1.4 Flow: Password Reset

```
User submits email on /forgot-password
  → Supabase sends reset link (PKCE-secured, expires 1 hour)
  → User clicks link → lands on /reset-password with token in URL
  → User sets new password
  → Supabase updates auth.users
  → Session issued; user redirected to dashboard
```

No custom backend code needed — this uses Supabase Auth's built-in `resetPasswordForEmail()` client method. The frontend must handle the `type=recovery` URL param on the callback route.

---

### 1.5 Flow: Gifted Account Claim

Organizations (real estate brokerages, insurance agencies) can gift HomeHub Pro access to homeowner clients. The gifted flow works as follows:

```
Org admin creates gifted subscription via HomeHub Admin panel
  → system generates a claim token (stored in subscriptions.gifted_by + gifted_at)
  → system sends invite email to homeowner with claim link
  → homeowner clicks link → lands on /claim?token=XXX
  → if no account: shown sign-up form (email pre-filled, password required)
  → if existing account: shown sign-in prompt
  → on auth: claim token validated, subscription.household_id linked
  → homeowner lands on dashboard with Pro features active
```

**Token strategy:** Use a short-lived signed token (JWT or Supabase one-time link) rather than storing raw tokens. The `subscriptions` table has `gifted_by`, `gifted_at`, and `gifted_expires_at` already.

**Edge cases:**
- Token expired → show "this invite has expired, contact your agent" screen
- Email already has an account → sign in and link (do not create duplicate profile)
- Token already claimed → show "already active" confirmation

---

### 1.6 Flow: Contractor/Vendor Invitation

Contractors are invited by homeowners to view property data. This uses the `access_grants` table (already in schema) rather than Supabase Auth invitations.

```
Homeowner taps "Share Access" → selects vendor from phonebook
  → system generates access_grants row (token = gen_random_bytes(16))
  → system renders QR code containing /access?token=XXXX
  → contractor scans QR → lands on /access?token=XXXX
  → system validates token (not expired, not revoked)
  → contractor sees read-only property view for granted scope
  → no Supabase account required for contractor QR access
```

**Contractor full accounts** (for contractors who want persistent HomeHub profiles) use a separate sign-up flow with `role = 'contractor'` set in profile creation. Full contractor accounts require email verification.

---

### 1.7 Session Handling

| Setting | Value | Reason |
|---|---|---|
| JWT expiry | 3600s (1 hour) | Supabase default |
| Refresh token rotation | Enabled | Security best practice |
| Session persistence | `localStorage` (web), `SecureStore` (mobile) | Platform-appropriate |
| Auto-refresh | Enabled | Supabase client handles silently |
| Sign-out behavior | Invalidate refresh token + clear local storage | Full logout on all devices |

**Multi-device:** Supabase does not natively support per-device session revocation at MVP. Full multi-device management is deferred.

---

### 1.8 Role Elevation

Roles in `public.profiles.role` are managed server-side only. Clients cannot self-promote.

| Transition | How |
|---|---|
| homeowner → admin | Manual: HomeHub internal team updates profile via admin panel or direct DB |
| homeowner → caretaker | Invitation flow (future) |
| vendor → verified_vendor | Admin approval via vendor portal |

---

### 1.9 Auth Implementation Checklist

- [ ] Configure Supabase Auth email templates (verification, reset, invite) with HomeHub branding
- [ ] Add `handle_new_auth_user()` trigger (migration 0009)
- [ ] Implement `/sign-up`, `/sign-in`, `/forgot-password`, `/reset-password` pages in Next.js
- [ ] Implement `/auth/callback` route to handle Supabase redirects
- [ ] Implement `/claim` route for gifted account flow
- [ ] Implement `/access` route for QR contractor access
- [ ] Add auth guard middleware (Next.js middleware.ts) for all `/app/*` routes
- [ ] Update `public.profiles` trigger to populate `display_name` from `raw_user_meta_data`
- [ ] Write integration tests for each auth flow

---

## Part 2 — Storage

### 2.1 Bucket Strategy

HomeHub uses three Supabase Storage buckets. All are **private by default** — no public URLs. Files are served via signed URLs generated by the backend.

| Bucket | Purpose | Max File Size | Allowed MIME Types |
|---|---|---|---|
| `documents` | PDFs, contracts, warranties, permits, invoices | 25 MB | `application/pdf`, `image/*` |
| `media` | Property photos, room photos, project progress photos | 15 MB | `image/jpeg`, `image/png`, `image/webp`, `video/mp4` |
| `avatars` | Profile photos for all user types | 5 MB | `image/jpeg`, `image/png`, `image/webp` |

**Why private?** Property documents and photos are sensitive. A leaked bucket policy or guessable path should never expose homeowner data. All access goes through the backend, which validates permissions before issuing signed URLs.

---

### 2.2 File Path Conventions

Paths encode the owning entity to make bucket-level policies and auditing straightforward.

```
documents/
  {property_id}/{document_id}/{filename}

media/
  {property_id}/{entity_type}/{entity_id}/{filename}
  # entity_type = 'property' | 'room' | 'project' | 'home_system'

avatars/
  {profile_id}/avatar.{ext}
```

**Examples:**
```
documents/00000000-0000-0000-0003-000000000001/00000000-0000-0000-0013-000000000001/insurance-declaration.pdf

media/00000000-0000-0000-0003-000000000001/project/00000000-0000-0000-0010-000000000005/before.jpg

avatars/00000000-0000-0000-0001-000000000001/avatar.jpg
```

---

### 2.3 Upload Flow

All uploads go through the backend API, never directly from the client to Supabase Storage. This ensures:
- Auth token is validated server-side before any storage operation
- File metadata row is created atomically with the upload
- File size and MIME type are validated before storage write

```
Client → POST /api/upload (multipart/form-data)
  → Backend validates JWT + household membership
  → Backend validates file size + MIME type
  → Backend calls supabase.storage.from(bucket).upload(path, buffer)
  → On success: backend inserts row into public.documents or public.media
  → Backend returns { id, storage_path, signed_url (short-lived) }
  → Client renders file using signed URL
```

**Why not direct client uploads?** Supabase Storage RLS policies for storage are more complex than DB RLS, and bypassing the backend removes the ability to enforce business rules (e.g., plan limits on storage quota). Backend-mediated uploads are simpler and more auditable at MVP.

---

### 2.4 Download / Signed URL Flow

```
Client → GET /api/files/{document_id}/url
  → Backend validates JWT + permission to access document
  → Backend calls supabase.storage.from(bucket).createSignedUrl(path, 300)
  → Returns { signed_url } with 5-minute expiry
  → Client opens/downloads via signed URL
```

**URL expiry:** 5 minutes for documents, 1 hour for media (images displayed inline). Avatars use longer-lived signed URLs (24 hours) since they're low-sensitivity and fetched frequently.

---

### 2.5 Metadata in Database

Storage is never queried directly by the frontend. All file discovery goes through the database tables:

- `public.documents` — stores `storage_path`, `file_size`, `mime_type`, `original_filename`, `category`, links to `property_id`, `project_id`, etc.
- `public.media` — stores `storage_path`, `file_size`, `mime_type`, `caption`, `taken_at`, links to `property_id`, `room_id`, `project_id`

This pattern means:
- Deleting a file requires: delete DB row, then delete from Storage (in that order — DB is authoritative)
- Moving/renaming a file: update `storage_path` in DB, move object in Storage
- File listing: always `SELECT FROM documents WHERE property_id = $1` — never list bucket objects directly

---

### 2.6 Storage Audit Requirements

Every upload and download should be logged in `public.audit_log`:

| Event | `action` | `entity_type` | Notes |
|---|---|---|---|
| File uploaded | `upload` | `document` or `media` | Log `file_size`, `mime_type` |
| File downloaded | `view` | `document` or `media` | Log `signed_url` expiry |
| File deleted | `delete` | `document` or `media` | Soft-delete if plan requires |
| File shared | `share` | `document` | Log recipient profile_id |

---

### 2.7 Storage Quotas (By Plan)

| Plan | Documents Storage | Media Storage | Notes |
|---|---|---|---|
| `free` | 500 MB | 1 GB | Enforced by backend |
| `pro` | 5 GB | 10 GB | Enforced by backend |
| `enterprise` | Unlimited | Unlimited | Subject to fair use |

Quota enforcement: backend checks current usage (sum of `file_size` in documents + media tables) before accepting each upload. Quota is calculated at upload time, not enforced via Storage bucket policies.

---

### 2.8 Storage Policy Considerations (RLS)

Storage bucket RLS policies are deferred to the same milestone as database RLS. Until then, all storage access is mediated entirely by the backend (service role key). This is acceptable for MVP and development.

When RLS is implemented for storage, the intended policies are:

**`documents` bucket:**
- Authenticated users may upload to `{property_id}/*` if they are a household member for that property
- Authenticated users may read `{property_id}/*` if they are a household member or have a valid access grant
- Service role may read/write all paths (for backend operations)

**`media` bucket:** Same as documents.

**`avatars` bucket:**
- Authenticated users may upload to `{profile_id}/*` if `auth.uid() = profile_id`
- All authenticated users may read any avatar path (avatars are not sensitive)

---

### 2.9 Storage Implementation Checklist

- [ ] Create three buckets in Supabase dashboard: `documents`, `media`, `avatars` (all private)
- [ ] Set bucket-level size limits matching table above
- [ ] Implement `POST /api/upload` endpoint with validation + DB write
- [ ] Implement `GET /api/files/{id}/url` endpoint for signed URL generation
- [ ] Implement `DELETE /api/files/{id}` endpoint (DB row + storage object)
- [ ] Add `storage_path` validation on upload to enforce path convention
- [ ] Implement quota check middleware for upload endpoint
- [ ] Wire `audit_log` entries for upload, download, delete, share events
- [ ] Add storage bucket RLS policies (deferred — same milestone as DB RLS)
- [ ] Write integration tests for upload + signed URL flows

---

## Part 3 — Implementation Order

The following order is recommended to avoid circular dependencies:

1. **Auth trigger migration** (migration 0009) — adds `handle_new_auth_user()` and profile auto-creation
2. **Auth frontend routes** — sign-up, sign-in, forgot/reset, callback
3. **Auth guard middleware** — protects all `/app/*` routes
4. **Storage bucket creation** — documents, media, avatars (no RLS yet)
5. **Upload/download API endpoints** — backend-mediated, service role key
6. **Gifted account claim flow** — depends on auth being wired
7. **QR contractor access flow** — uses existing access_grants table, no auth required for viewer
8. **DB + Storage RLS** — final hardening step before any real-user beta

---

## Appendix — Supabase Client Initialization

```typescript
// lib/supabase/client.ts (frontend)
import { createBrowserClient } from '@supabase/ssr'

export const createClient = () =>
  createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
```

```typescript
// lib/supabase/server.ts (backend / Next.js server components)
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export const createClient = () =>
  createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => cookies().getAll() } }
  )
```

```typescript
// lib/supabase/service.ts (backend only — never expose to client)
import { createClient } from '@supabase/supabase-js'

export const supabaseService = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!   // backend .env only
)
```

> **Warning:** `SUPABASE_SERVICE_ROLE_KEY` bypasses all RLS. It must never appear in frontend code or `NEXT_PUBLIC_` variables.
