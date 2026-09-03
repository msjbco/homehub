-- ============================================================
-- Migration 0016: Storage metadata integrity
-- ============================================================

do $$
begin
  if exists (
    select 1 from public.documents
    where file_size_bytes < 0
       or btrim(storage_path) = ''
       or btrim(file_name) = ''
       or (mime_type is not null and btrim(mime_type) = '')
       or storage_path ~ E'(^/|\\\\|(^|/)\.\.(/|$)|//)'
  ) then
    raise exception 'Existing document metadata violates Foundation storage integrity';
  end if;

  if exists (
    select 1 from public.media
    where file_size_bytes < 0
       or width_px < 0
       or height_px < 0
       or duration_secs < 0
       or btrim(storage_path) = ''
       or btrim(file_name) = ''
       or (mime_type is not null and btrim(mime_type) = '')
       or storage_path ~ E'(^/|\\\\|(^|/)\.\.(/|$)|//)'
  ) then
    raise exception 'Existing media metadata violates Foundation storage integrity';
  end if;

  if exists (select storage_path from public.documents group by storage_path having count(*) > 1) then
    raise exception 'Duplicate document storage paths prevent uniqueness enforcement';
  end if;

  if exists (select storage_path from public.media group by storage_path having count(*) > 1) then
    raise exception 'Duplicate media storage paths prevent uniqueness enforcement';
  end if;
end
$$;

alter table public.documents
  add constraint documents_file_size_nonnegative_check
    check (file_size_bytes is null or file_size_bytes >= 0),
  add constraint documents_storage_path_content_check
    check (btrim(storage_path) <> ''),
  add constraint documents_storage_path_scope_check
    check (storage_path !~ E'(^/|\\\\|(^|/)\.\.(/|$)|//)'),
  add constraint documents_file_name_content_check
    check (btrim(file_name) <> ''),
  add constraint documents_mime_type_content_check
    check (mime_type is null or btrim(mime_type) <> ''),
  add constraint documents_mime_type_allowed_check
    check (mime_type is null or mime_type = any (array[
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'image/jpeg', 'image/png', 'image/webp', 'image/tiff', 'image/heic', 'image/heif'
    ]::text[])),
  add constraint documents_storage_path_key unique (storage_path);

alter table public.media
  add constraint media_file_size_nonnegative_check
    check (file_size_bytes is null or file_size_bytes >= 0),
  add constraint media_width_nonnegative_check
    check (width_px is null or width_px >= 0),
  add constraint media_height_nonnegative_check
    check (height_px is null or height_px >= 0),
  add constraint media_duration_nonnegative_check
    check (duration_secs is null or duration_secs >= 0),
  add constraint media_storage_path_content_check
    check (btrim(storage_path) <> ''),
  add constraint media_storage_path_scope_check
    check (storage_path !~ E'(^/|\\\\|(^|/)\.\.(/|$)|//)'),
  add constraint media_file_name_content_check
    check (btrim(file_name) <> ''),
  add constraint media_mime_type_content_check
    check (mime_type is null or btrim(mime_type) <> ''),
  add constraint media_mime_type_allowed_check
    check (mime_type is null or mime_type = any (array[
      'image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif', 'video/mp4'
    ]::text[])),
  add constraint media_storage_path_key unique (storage_path);

alter table public.profiles
  add constraint profiles_avatar_url_content_check
    check (avatar_url is null or btrim(avatar_url) <> '');

comment on constraint documents_storage_path_key on public.documents is
  'Object paths are unique within the fixed documents bucket.';
comment on constraint media_storage_path_key on public.media is
  'Object paths are unique within the fixed media bucket.';
