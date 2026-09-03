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
 * These names are fixed because the database metadata tables do not carry
 * bucket names; each table maps to exactly one bucket.
 */
export const STORAGE_BUCKETS = {
  documents: 'documents',
  media:     'media',
  avatars:   'avatars',
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

/** No signed URL may outlive one day, including per-request overrides. */
export const MAX_SIGNED_URL_TTL_SECONDS = 86_400;

// ── Entity types (used in media paths) ───────────────────────────────────────

export type MediaEntityType = 'property' | 'room' | 'project' | 'home_system';

// ── Path helpers ─────────────────────────────────────────────────────────────

/**
 * Normalise a user-supplied filename without allowing it to affect path scope.
 *
 * This must be applied to all filenames before including them in storage paths.
 */
export function sanitiseFilename(raw: string): string {
  const trimmed = raw.trim();
  if (trimmed.split(/[/\\]/).some((segment) => segment === '..')) {
    throw new Error('Filename must not contain directory traversal semantics ("..").');
  }

  const withoutControls = Array.from(trimmed, (character) => {
    const codePoint = character.codePointAt(0) ?? 0;
    return codePoint <= 31 || (codePoint >= 127 && codePoint <= 159) ? '-' : character;
  }).join('');

  const normalised = withoutControls
    .replace(/[/\\]/g, '-')
    .replace(/[^a-zA-Z0-9._-]/g, '-')
    .replace(/-{2,}/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase();

  if (!normalised || /^[.-]+$/.test(normalised)) {
    throw new Error('Filename must contain at least one letter or number.');
  }

  const lastDot = normalised.lastIndexOf('.');
  const hasExtension = lastDot > 0 && lastDot < normalised.length - 1;
  if (!hasExtension || normalised.length <= 200) return normalised.slice(0, 200);

  const extension = normalised.slice(lastDot, lastDot + 33);
  const basenameLength = 200 - extension.length;
  return `${normalised.slice(0, basenameLength)}${extension}`;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Reject identifiers that cannot be UUID-backed database entity IDs. */
export function assertUuid(value: string, fieldName: string): void {
  if (!UUID_PATTERN.test(value)) {
    throw new Error(`${fieldName} must be a valid UUID.`);
  }
}

/**
 * Build the storage object path for a document.
 *
 * Pattern: properties/{property_id}/documents/{document_id}/{sanitised_filename}
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
  assertUuid(propertyId, 'propertyId');
  assertUuid(documentId, 'documentId');
  return `properties/${propertyId}/documents/${documentId}/${sanitiseFilename(filename)}`;
}

/**
 * Build the storage object path for a media item.
 *
 * Pattern: properties/{property_id}/media/{media_id}/{sanitised_filename}
 *
 * @param propertyId   UUID of the owning property
 * @param mediaId      UUID of the media row in public.media
 * @param filename     Original filename (will be sanitised)
 */
export function mediaPath(
  propertyId: string,
  mediaId: string,
  filename: string,
): string {
  assertUuid(propertyId, 'propertyId');
  assertUuid(mediaId, 'mediaId');
  return `properties/${propertyId}/media/${mediaId}/${sanitiseFilename(filename)}`;
}

/**
 * Build the storage object path for a profile avatar.
 *
 * Pattern: profiles/{profile_id}/avatars/avatar.{ext}
 *
 * Only one avatar is kept per profile — uploading always overwrites.
 *
 * @param profileId  UUID of the profile
 * @param mimeType   MIME type of the uploaded image (used to derive extension)
 */
export function avatarPath(profileId: string, mimeType: string): string {
  assertUuid(profileId, 'profileId');
  const extensions: Readonly<Record<string, string>> = {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
  };
  const extension = extensions[mimeType];
  if (!extension) throw new Error(`Unsupported avatar MIME type "${mimeType}".`);
  return `profiles/${profileId}/avatars/avatar.${extension}`;
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
  if (Number.isInteger(fileSizeBytes) && fileSizeBytes >= 0 && fileSizeBytes <= max) {
    return { valid: true };
  }
  const maxMiB = (max / 1_048_576).toFixed(0);
  const actualMiB = Number.isFinite(fileSizeBytes)
    ? (fileSizeBytes / 1_048_576).toFixed(2)
    : String(fileSizeBytes);
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
  assertUuid(params.entityId, 'entityId');
  return {
    bucket: 'media',
    storagePath: mediaPath(params.propertyId, params.mediaId, params.filename),
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
  const ttl = overrideTtlSeconds ?? SIGNED_URL_TTL_SECONDS[bucket];
  if (!Number.isInteger(ttl) || ttl <= 0 || ttl > MAX_SIGNED_URL_TTL_SECONDS) {
    throw new Error(
      `Signed URL TTL must be an integer from 1 to ${MAX_SIGNED_URL_TTL_SECONDS} seconds.`,
    );
  }
  return ttl;
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
