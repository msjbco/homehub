-- ============================================================
-- Migration 0009: Storage Foundation
-- HomeHub — Supabase Storage bucket definitions
-- ============================================================
--
-- This migration creates the three core storage buckets used by
-- HomeHub. All buckets are private. No storage access policies are
-- defined here.
--
-- ACCESS POLICIES ARE INTENTIONALLY OMITTED FROM THIS MIGRATION.
-- Permissive or restrictive storage policies require authenticated
-- user identities (auth.uid()) and Row Level Security on the
-- public.profiles / public.household_members tables to be meaningful.
-- Storage policies will be added in a dedicated migration once:
--   1. Supabase Auth is wired and the auth.users → profiles trigger
--      (migration 0010_auth_trigger.sql) is in place.
--   2. Database RLS is enabled and policies are validated.
-- Until then, all storage I/O is mediated exclusively by the backend
-- using the SUPABASE_SERVICE_ROLE_KEY (server-side only).
-- ============================================================

-- ── documents bucket ──────────────────────────────────────────
-- Stores homeowner documents: insurance declarations, warranties,
-- permits, inspection reports, purchase contracts, invoices, etc.
--
-- File-size limit : 25 MB  (26,214,400 bytes)
-- Allowed MIME types:
--   application/pdf
--   application/msword                              (.doc)
--   application/vnd.openxmlformats-officedocument.wordprocessingml.document  (.docx)
--   application/vnd.ms-excel                        (.xls)
--   application/vnd.openxmlformats-officedocument.spreadsheetml.sheet        (.xlsx)
--   image/jpeg  image/png  image/webp  image/tiff  image/heic  image/heif
--
-- Path convention (enforced by backend, not by this migration):
--   {property_id}/{document_id}/{sanitised_filename}
--
-- Privacy: private — no public URLs. Access via signed URLs only
-- (backend calls storage.createSignedUrl with service-role key).
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'documents',
  'documents',
  false,                     -- private: no public URLs
  26214400,                  -- 25 MiB
  array[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/tiff',
    'image/heic',
    'image/heif'
  ]
)
on conflict (id) do update set
  public             = excluded.public,
  file_size_limit    = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- ── media bucket ──────────────────────────────────────────────
-- Stores property photos and videos: room photos, project before/after
-- images, home system reference photos, and short progress videos.
--
-- File-size limit : 15 MB  (15,728,640 bytes)
-- Allowed MIME types:
--   image/jpeg  image/png  image/webp  image/heic  image/heif
--   video/mp4
--
-- Path convention (enforced by backend):
--   {property_id}/{entity_type}/{entity_id}/{sanitised_filename}
--   entity_type ∈ { property, room, project, home_system }
--
-- Privacy: private — no public URLs. Access via signed URLs.
-- Signed URL TTL for media (images displayed inline): 3600 s (1 hour).
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'media',
  'media',
  false,                     -- private: no public URLs
  15728640,                  -- 15 MiB
  array[
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif',
    'video/mp4'
  ]
)
on conflict (id) do update set
  public             = excluded.public,
  file_size_limit    = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- ── avatars bucket ────────────────────────────────────────────
-- Stores profile photos for homeowners, contractors, caretakers,
-- and admin users.
--
-- File-size limit : 5 MB  (5,242,880 bytes)
-- Allowed MIME types:
--   image/jpeg  image/png  image/webp
--
-- Path convention (enforced by backend):
--   {profile_id}/avatar.{ext}
--   Only one avatar per profile is retained (overwrite on re-upload).
--
-- Privacy: private.
-- Signed URL TTL for avatars (fetched frequently, low sensitivity):
--   86400 s (24 hours).
--
-- NOTE: Even though avatars are relatively low-risk, the bucket is
-- kept private to prevent user enumeration via predictable paths.
-- When storage RLS is added, avatars will be readable by any
-- authenticated user but writable only by the owning profile.
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'avatars',
  'avatars',
  false,                     -- private: no public URLs
  5242880,                   -- 5 MiB
  array[
    'image/jpeg',
    'image/png',
    'image/webp'
  ]
)
on conflict (id) do update set
  public             = excluded.public,
  file_size_limit    = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- ── storage access policies — DEFERRED ────────────────────────
--
-- Storage RLS policies are NOT defined in this migration.
--
-- They will be added in migration 0011_storage_rls.sql after:
--   • Auth trigger (migration 0010) establishes auth.uid() → profile linkage
--   • Database RLS (migration 0012) is enabled on public.household_members
--     so storage policies can JOIN against it safely
--
-- Intended policies (for reference — do not uncomment here):
--
--   documents / media:
--     INSERT: auth.uid() maps to a profile that is a household_member
--             of the property_id encoded in the object path
--     SELECT: same membership check, OR a valid non-expired access_grant
--             token exists for the property
--     DELETE: same as INSERT (owner-only)
--
--   avatars:
--     INSERT: object path starts with auth.uid()::text
--     SELECT: any authenticated user (avatars are non-sensitive)
--     DELETE: object path starts with auth.uid()::text
--
-- Until policies exist, ALL storage operations must use the
-- SUPABASE_SERVICE_ROLE_KEY server-side. Anon-key storage access
-- will be rejected by the absence of permissive policies.
-- ============================================================
