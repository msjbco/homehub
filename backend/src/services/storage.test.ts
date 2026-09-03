import assert from 'node:assert/strict';
import test from 'node:test';

import {
  ALLOWED_MIME_TYPES,
  MAX_FILE_SIZE_BYTES,
  MAX_SIGNED_URL_TTL_SECONDS,
  avatarPath,
  documentPath,
  mediaPath,
  prepareMediaUpload,
  resolveSignedUrlTtl,
  sanitiseFilename,
  validateFileSize,
  validateMimeType,
} from './storage.js';

const propertyId = '00000000-0000-0000-0004-000000000001';
const documentId = '00000000-0000-0000-0012-000000000001';
const mediaId = '00000000-0000-0000-0016-000000000001';
const profileId = '00000000-0000-0000-0000-000000000001';

test('UUID-scoped paths use canonical prefixes and mediaId', () => {
  assert.equal(documentPath(propertyId, documentId, 'Report.PDF'),
    `properties/${propertyId}/documents/${documentId}/report.pdf`);
  assert.equal(mediaPath(propertyId, mediaId, 'Photo.JPG'),
    `properties/${propertyId}/media/${mediaId}/photo.jpg`);
  assert.match(prepareMediaUpload({
    propertyId, entityType: 'property', entityId: propertyId, mediaId,
    filename: 'photo.jpg', mimeType: 'image/jpeg', fileSizeBytes: 1,
  }).storagePath, new RegExp(`/media/${mediaId}/`));
});

test('path builders reject invalid UUIDs', () => {
  assert.throws(() => documentPath('bad', documentId, 'x.pdf'), /propertyId/);
  assert.throws(() => documentPath(propertyId, 'bad', 'x.pdf'), /documentId/);
  assert.throws(() => mediaPath(propertyId, 'bad', 'x.jpg'), /mediaId/);
  assert.throws(() => avatarPath('bad', 'image/jpeg'), /profileId/);
});

test('filename normalisation is safe, bounded, and extension-preserving', () => {
  assert.equal(sanitiseFilename('  My Report.PDF  '), 'my-report.pdf');
  assert.equal(sanitiseFilename('folder/name\\scan.jpg'), 'folder-name-scan.jpg');
  assert.equal(sanitiseFilename('foo\\bar.jpg'), 'foo-bar.jpg');
  assert.equal(sanitiseFilename('a..b.pdf'), 'a..b.pdf');
  assert.equal(sanitiseFilename('report..final.pdf'), 'report..final.pdf');
  assert.equal(sanitiseFilename('control\u0000name.png'), 'control-name.png');
  assert.throws(() => sanitiseFilename('..'), /traversal/);
  assert.throws(() => sanitiseFilename('../secret.pdf'), /traversal/);
  assert.throws(() => sanitiseFilename('../../secret.pdf'), /traversal/);
  assert.throws(() => sanitiseFilename('foo/../../bar.jpg'), /traversal/);
  assert.throws(() => sanitiseFilename('foo\\..\\bar.jpg'), /traversal/);
  assert.throws(() => sanitiseFilename('..\\secret.pdf'), /traversal/);
  assert.throws(() => sanitiseFilename('   '), /letter or number/);
  const longName = sanitiseFilename(`${'a'.repeat(250)}.pdf`);
  assert.equal(longName.length, 200);
  assert.ok(longName.endsWith('.pdf'));
});

test('MIME allowlists accept every configured value and reject crossover', () => {
  for (const bucket of ['documents', 'media', 'avatars'] as const) {
    for (const mime of ALLOWED_MIME_TYPES[bucket]) {
      assert.deepEqual(validateMimeType(bucket, mime), { valid: true });
    }
  }
  assert.equal(validateMimeType('avatars', 'application/pdf').valid, false);
  assert.equal(validateMimeType('media', 'application/pdf').valid, false);
  assert.equal(validateMimeType('documents', 'text/plain').valid, false);
});

test('file sizes enforce integer, nonnegative, and exact bucket boundaries', () => {
  for (const bucket of ['documents', 'media', 'avatars'] as const) {
    assert.equal(validateFileSize(bucket, 0).valid, true);
    assert.equal(validateFileSize(bucket, MAX_FILE_SIZE_BYTES[bucket]).valid, true);
    assert.equal(validateFileSize(bucket, MAX_FILE_SIZE_BYTES[bucket] + 1).valid, false);
    assert.equal(validateFileSize(bucket, -1).valid, false);
    assert.equal(validateFileSize(bucket, 1.5).valid, false);
  }
});

test('avatar extensions are MIME-driven', () => {
  assert.ok(avatarPath(profileId, 'image/jpeg').endsWith('/avatar.jpg'));
  assert.ok(avatarPath(profileId, 'image/png').endsWith('/avatar.png'));
  assert.ok(avatarPath(profileId, 'image/webp').endsWith('/avatar.webp'));
  assert.throws(() => avatarPath(profileId, 'image/gif'), /Unsupported/);
});

test('signed URL TTLs are bounded positive integers', () => {
  assert.equal(resolveSignedUrlTtl('documents'), 300);
  assert.equal(resolveSignedUrlTtl('media', 60), 60);
  for (const invalid of [0, -1, 1.5, MAX_SIGNED_URL_TTL_SECONDS + 1]) {
    assert.throws(() => resolveSignedUrlTtl('media', invalid), /TTL/);
  }
});
