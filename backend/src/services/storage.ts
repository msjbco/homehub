/**
 * storage.ts — HomeHub Backend Storage Service (Foundation Scaffold)
 *
 * Defines typed helpers for all Supabase Storage operations that
 * HomeHub's backend API will perform: path generation, MIME validation,
 * file-size validation, upload preparation, and signed-URL preparation.
 *
 * ─── IMPORTANT ───────────────────────────────────────────────────────────────
 * This file is a SCAFFOLD. No live Supabase client is instantiated here.
 * The actual Supabase client will be wired once @supabase/supabase-js is added
 * as a dependency and SUPABASE_SERVICE_ROLE_KEY is available in the environment.
 *
 * All storage operations MUST use the service-role client (server-side only).
 * The service-role key bypasses RLS — it must never be exposed to the frontend
 * or included in any NEXT_PUBLIC_* environment variable.
 *
 * Storage RLS policies are intentionally deferred until authentication and
 * database RLS are fully wired (see docs/architecture/authentication-and-storage-plan.md).
 * ─────────────────────────────────────────────────────────────────────────────
 */

// ── Bucket names ─────────────────────────────────────────────────────────────

/**
 * Canonical bucket identifiers. Values must match the `id` column in
 * storage.buckets (created by migration 0009_storage_foundation.sql).
 *
 * Populated from environment variables so the same TypeScript source
 * works across local, staging, and production without code changes.
 */
export const STORAGE_BUCKETS = {
  documents: process.env.STORAGE_BUCKET_DOCUMENTS ?? 'documents',
  media:     process.env.STORAGE_BUCKET_MEDIA     ?? 'media',
  avatars:   process.env.STORAGE_BUCKET_AVATARS   ?? 'avatars',
} as const;

export type StorageBucket = keyof typeof STORAGE_BUCKETS;

// ── File-size limits (bytes) ─────────────────────────────────────────────────

/** Maximum allowed file sizes per bucket. Must mirror migration 0009 values. */
export const MAX_FILE_SIZE_BYTES: Record<StorageBucket, number> = {
  documents: 26_214_400,   // 25 MiB
  media:     15_728_640,   // 15 MiB
  avatars:    5_242_880,   //  5 MiB
};

// ── Allowed MIME types ────────────────────────────────────────────────────────

/** Allowed MIME types per bucket. Must mirror migration 0009 values. */
export const ALLOWED_MIME_TYPES: Record<StorageBucket, readonly string[]> = {
  documents: [
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
    'image/heif',
  ],
  media: [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif',
    'video/mp4',
  ],
  avatars: [
    'image/jpeg',
    'image/png',
    'image/webp',
  ],
};

// ── Signed URL TTLs (seconds) ─────────────────────────────────────────────────

/**
 * Signed URL expiry per bucket (in seconds).
 * Shorter for documents (sensitive), longer for media (inline display),
 * longest for avatars (fetched frequently, low sensitivity).
 */
export const SIGNED_URL_TTL_SECONDS: Record<StorageBucket, number> = {
  documents:   300,    //  5 minutes
  media:      3600,    //  1 hour
  avatars:   86400,    // 24 hours
};

// ── Entity types (used in media paths) ───────────────────────────────────────

export type MediaEntityType = 'property' | 'room' | 'project' | 'home_system';

// ── Path helpers ─────────────────────────────────────────────────────────────

/**
 * Sanitise a user-supplied filename: strip directory traversal, replace
 * spaces and special characters with hyphens, lowercase the result.
 *
 * This must be applied to all filenames before including them in storage paths.
 */
export function sanitiseFilename(raw: string): string {
  return raw
    .replace(/[/\\]/g, '')           // strip path separators (traversal guard)
    .replace(/[^a-zA-Z0-9._-]/g, '-') // replace unsafe chars
    .replace(/-{2,}/g, '-')           // collapse multiple hyphens
    .toLowerCase()
    .slice(0, 200);                   // cap length
}

/**
 * Build the storage object path for a document.
 *
 * Pattern: {property_id}/{document_id}/{sanitised_filename}
 *
 * @param propertyId   UUID of the owning property
 * @param documentId   UUID of the document row in public.documents
 * @param filename     Original filename (will be sanitised)
 */
export function documentPath(
  propertyId: string,
  documentId: string,
  filename: string,
): string {
  return `${propertyId}/${documentId}/${sanitiseFilename(filename)}`;
}

/**
 * Build the storage object path for a media item.
 *
 * Pattern: {property_id}/{entity_type}/{entity_id}/{sanitised_filename}
 *
 * @param propertyId   UUID of the owning property
 * @param entityType   Entity this media is attached to
 * @param entityId     UUID of the entity (room, project, etc.)
 * @param filename     Original filename (will be sanitised)
 */
export function mediaPath(
  propertyId: string,
  entityType: MediaEntityType,
  entityId: string,
  filename: string,
): string {
  return `${propertyId}/${entityType}/${entityId}/${sanitiseFilename(filename)}`;
}

/**
 * Build the storage object path for a profile avatar.
 *
 * Pattern: {profile_id}/avatar.{ext}
 *
 * Only one avatar is kept per profile — uploading always overwrites.
 *
 * @param profileId  UUID of the profile
 * @param mimeType   MIME type of the uploaded image (used to derive extension)
 */
export function avatarPath(profileId: string, mimeType: string): string {
  const ext = mimeType.split('/')[1] ?? 'jpg';
  return `${profileId}/avatar.${ext}`;
}

// ── Validation helpers ────────────────────────────────────────────────────────

/** Result type returned by all validation helpers. */
export type ValidationResult =
  | { valid: true }
  | { valid: false; reason: string };

/**
 * Validate a file's MIME type against the allowed list for a given bucket.
 *
 * @param bucket    Target bucket
 * @param mimeType  MIME type reported by the client or detected server-side
 */
export function validateMimeType(
  bucket: StorageBucket,
  mimeType: string,
): ValidationResult {
  const allowed = ALLOWED_MIME_TYPES[bucket];
  if (allowed.includes(mimeType)) {
    return { valid: true };
  }
  return {
    valid: false,
    reason: `MIME type "${mimeType}" is not permitted for the "${bucket}" bucket. `
          + `Allowed: ${allowed.join(', ')}.`,
  };
}

/**
 * Validate a file's size against the maximum for a given bucket.
 *
 * @param bucket         Target bucket
 * @param fileSizeBytes  File size in bytes
 */
export function validateFileSize(
  bucket: StorageBucket,
  fileSizeBytes: number,
): ValidationResult {
  const max = MAX_FILE_SIZE_BYTES[bucket];
  if (fileSizeBytes <= max) {
    return { valid: true };
  }
  const maxMiB = (max / 1_048_576).toFixed(0);
  const actualMiB = (fileSizeBytes / 1_048_576).toFixed(2);
  return {
    valid: false,
    reason: `File size ${actualMiB} MiB exceeds the ${maxMiB} MiB limit for the "${bucket}" bucket.`,
  };
}

/**
 * Run both MIME type and file-size validation in sequence.
 * Returns the first failure encountered, or { valid: true } if both pass.
 *
 * @param bucket         Target bucket
 * @param mimeType       MIME type of the file
 * @param fileSizeBytes  Size of the file in bytes
 */
export function validateUpload(
  bucket: StorageBucket,
  mimeType: string,
  fileSizeBytes: number,
): ValidationResult {
  const mimeResult = validateMimeType(bucket, mimeType);
  if (!mimeResult.valid) return mimeResult;
  return validateFileSize(bucket, fileSizeBytes);
}

// ── Upload / signed-URL preparation types ────────────────────────────────────
//
// These interfaces describe the inputs and outputs that the upload and
// signed-URL API endpoints will work with. They are defined here (not in
// route files) so the storage service remains the single source of truth for
// all storage-related contracts.
//
// The actual Supabase client calls will be implemented when
// @supabase/supabase-js is installed and SUPABASE_SERVICE_ROLE_KEY is
// available. Method stubs are included below to make the intended surface
// area explicit and to give callers a typed target to import against.

/**
 * Parameters for preparing a document upload.
 * The backend validates these before calling Supabase Storage.
 */
export interface PrepareDocumentUploadParams {
  propertyId:    string;
  documentId:    string;   // pre-generated UUID that will be the DB row id
  filename:      string;
  mimeType:      string;
  fileSizeBytes: number;
}

/**
 * Parameters for preparing a media upload.
 */
export interface PrepareMediaUploadParams {
  propertyId:    string;
  entityType:    MediaEntityType;
  entityId:      string;
  mediaId:       string;   // pre-generated UUID that will be the DB row id
  filename:      string;
  mimeType:      string;
  fileSizeBytes: number;
}

/**
 * Parameters for preparing an avatar upload.
 */
export interface PrepareAvatarUploadParams {
  profileId:     string;
  mimeType:      string;
  fileSizeBytes: number;
}

/**
 * Resolved upload target — returned to the route handler after validation.
 * The route handler is responsible for streaming the file buffer to Supabase.
 */
export interface UploadTarget {
  bucket:      StorageBucket;
  storagePath: string;
}

/**
 * Prepare a validated document upload target.
 *
 * Validates MIME type and file size, then returns the resolved storage path.
 * Throws a descriptive Error if validation fails.
 *
 * NOTE: This function does NOT call Supabase — it is pure validation +
 * path resolution. The caller is responsible for the actual storage write
 * using the service-role client once this function returns successfully.
 *
 * TODO: Wire service-role Supabase client and execute the storage upload
 *       once @supabase/supabase-js is installed.
 */
export function prepareDocumentUpload(
  params: PrepareDocumentUploadParams,
): UploadTarget {
  const result = validateUpload('documents', params.mimeType, params.fileSizeBytes);
  if (!result.valid) throw new Error(result.reason);
  return {
    bucket: 'documents',
    storagePath: documentPath(params.propertyId, params.documentId, params.filename),
  };
}

/**
 * Prepare a validated media upload target.
 *
 * TODO: Wire service-role Supabase client once @supabase/supabase-js is installed.
 */
export function prepareMediaUpload(
  params: PrepareMediaUploadParams,
): UploadTarget {
  const result = validateUpload('media', params.mimeType, params.fileSizeBytes);
  if (!result.valid) throw new Error(result.reason);
  return {
    bucket: 'media',
    storagePath: mediaPath(
      params.propertyId,
      params.entityType,
      params.entityId,
      params.filename,
    ),
  };
}

/**
 * Prepare a validated avatar upload target.
 *
 * TODO: Wire service-role Supabase client once @supabase/supabase-js is installed.
 */
export function prepareAvatarUpload(
  params: PrepareAvatarUploadParams,
): UploadTarget {
  const result = validateUpload('avatars', params.mimeType, params.fileSizeBytes);
  if (!result.valid) throw new Error(result.reason);
  return {
    bucket: 'avatars',
    storagePath: avatarPath(params.profileId, params.mimeType),
  };
}

/**
 * Parameters for generating a signed download URL.
 */
export interface PrepareSignedUrlParams {
  bucket:      StorageBucket;
  storagePath: string;
  ttlSeconds?: number;   // defaults to SIGNED_URL_TTL_SECONDS[bucket]
}

/**
 * Resolve the TTL that should be used for a signed URL request.
 * Callers may override the default per-bucket TTL when needed
 * (e.g., a short-lived share link for a sensitive legal document).
 */
export function resolveSignedUrlTtl(
  bucket: StorageBucket,
  overrideTtlSeconds?: number,
): number {
  return overrideTtlSeconds ?? SIGNED_URL_TTL_SECONDS[bucket];
}

/**
 * Placeholder for the signed-URL generation call.
 *
 * When implemented, this function will call:
 *   supabaseServiceClient.storage
 *     .from(STORAGE_BUCKETS[params.bucket])
 *     .createSignedUrl(params.storagePath, ttl)
 *
 * and return the resulting signed URL string.
 *
 * TODO: Implement once @supabase/supabase-js is installed and the
 *       service-role client is available.
 *
 * @throws Error if called before implementation is wired
 */
export function createSignedDownloadUrl(
  params: PrepareSignedUrlParams,
): never {
  const ttl = resolveSignedUrlTtl(params.bucket, params.ttlSeconds);
  void ttl; // referenced to satisfy 'no-unused-vars' until implementation
  throw new Error(
    'createSignedDownloadUrl is not yet implemented. '
    + 'Wire the Supabase service-role client and implement this function '
    + 'once @supabase/supabase-js is installed.',
  );
}
