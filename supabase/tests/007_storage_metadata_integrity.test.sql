begin;

select plan(26);

insert into public.households (id, name)
values ('70000000-0000-0000-0002-000000000001', 'Phase 7 Household');

insert into public.properties (id, household_id, address_line1, city, state, zip)
values ('70000000-0000-0000-0004-000000000001', '70000000-0000-0000-0002-000000000001', '7 Storage Way', 'Hampstead', 'NC', '28443');

select is((select count(*)::bigint from pg_constraint where conrelid='public.documents'::regclass and conname like 'documents_%_check'), 6::bigint, 'document metadata checks exist');
select is((select count(*)::bigint from pg_constraint where conrelid='public.media'::regclass and conname like 'media_%_check'), 9::bigint, 'media metadata checks exist');
select is((select count(*)::bigint from pg_constraint where conrelid='public.profiles'::regclass and conname='profiles_avatar_url_content_check'), 1::bigint, 'avatar metadata content check exists');
select is((select count(*)::bigint from pg_constraint where conrelid='public.documents'::regclass and conname='documents_storage_path_key' and contype='u'), 1::bigint, 'document storage path unique constraint exists');
select is((select count(*)::bigint from pg_constraint where conrelid='public.media'::regclass and conname='media_storage_path_key' and contype='u'), 1::bigint, 'media storage path unique constraint exists');

select lives_ok($$insert into public.documents (id,property_id,title,storage_path,file_name,file_size_bytes,mime_type) values ('70000000-0000-0000-0012-000000000001','70000000-0000-0000-0004-000000000001','Valid','properties/70000000-0000-0000-0004-000000000001/documents/70000000-0000-0000-0012-000000000001/report.pdf','report.pdf',0,'application/pdf')$$, 'valid document metadata is accepted');
select throws_ok($$insert into public.documents (property_id,title,storage_path,file_name,file_size_bytes) values ('70000000-0000-0000-0004-000000000001','Negative','negative/document.pdf','document.pdf',-1)$$, '23514', null, 'negative document size is rejected');
select throws_ok($$insert into public.documents (property_id,title,storage_path,file_name) values ('70000000-0000-0000-0004-000000000001','Blank path','   ','document.pdf')$$, '23514', null, 'blank document storage path is rejected');
select throws_ok($$insert into public.documents (property_id,title,storage_path,file_name) values ('70000000-0000-0000-0004-000000000001','Blank name','valid/path.pdf','   ')$$, '23514', null, 'blank document filename is rejected');
select throws_ok($$insert into public.documents (property_id,title,storage_path,file_name) values ('70000000-0000-0000-0004-000000000001','Traversal','../escape.pdf','escape.pdf')$$, '23514', null, 'document traversal path is rejected');
select throws_ok($$insert into public.documents (property_id,title,storage_path,file_name) values ('70000000-0000-0000-0004-000000000001','Backslash',E'folder\\escape.pdf','escape.pdf')$$, '23514', null, 'document backslash path is rejected');
select throws_ok($$insert into public.documents (property_id,title,storage_path,file_name) values ('70000000-0000-0000-0004-000000000001','Duplicate','properties/70000000-0000-0000-0004-000000000001/documents/70000000-0000-0000-0012-000000000001/report.pdf','other.pdf')$$, '23505', null, 'duplicate document path is rejected within its bucket table');
select throws_ok($$insert into public.documents (property_id,title,storage_path,file_name,mime_type) values ('70000000-0000-0000-0004-000000000001','Bad MIME','valid/bad.txt','bad.txt','text/plain')$$, '23514', null, 'disallowed document MIME is rejected');

select lives_ok($$insert into public.media (id,property_id,storage_path,file_name,file_size_bytes,mime_type,width_px,height_px,duration_secs) values ('70000000-0000-0000-0016-000000000001','70000000-0000-0000-0004-000000000001','properties/70000000-0000-0000-0004-000000000001/media/70000000-0000-0000-0016-000000000001/photo.jpg','photo.jpg',0,'image/jpeg',0,0,0)$$, 'valid media metadata is accepted');
select throws_ok($$insert into public.media (property_id,storage_path,file_name,file_size_bytes) values ('70000000-0000-0000-0004-000000000001','negative/media.jpg','media.jpg',-1)$$, '23514', null, 'negative media size is rejected');
select throws_ok($$insert into public.media (property_id,storage_path,file_name,width_px) values ('70000000-0000-0000-0004-000000000001','negative/width.jpg','width.jpg',-1)$$, '23514', null, 'negative media width is rejected');
select throws_ok($$insert into public.media (property_id,storage_path,file_name,height_px) values ('70000000-0000-0000-0004-000000000001','negative/height.jpg','height.jpg',-1)$$, '23514', null, 'negative media height is rejected');
select throws_ok($$insert into public.media (property_id,storage_path,file_name,duration_secs) values ('70000000-0000-0000-0004-000000000001','negative/duration.mp4','duration.mp4',-1)$$, '23514', null, 'negative media duration is rejected');
select throws_ok($$insert into public.media (property_id,storage_path,file_name) values ('70000000-0000-0000-0004-000000000001','   ','media.jpg')$$, '23514', null, 'blank media path is rejected');
select throws_ok($$insert into public.media (property_id,storage_path,file_name) values ('70000000-0000-0000-0004-000000000001','valid/media.jpg','   ')$$, '23514', null, 'blank media filename is rejected');
select throws_ok($$insert into public.media (property_id,storage_path,file_name) values ('70000000-0000-0000-0004-000000000001','properties/70000000-0000-0000-0004-000000000001/media/70000000-0000-0000-0016-000000000001/photo.jpg','other.jpg')$$, '23505', null, 'duplicate media path is rejected within its bucket table');
select throws_ok($$insert into public.media (property_id,storage_path,file_name,mime_type) values ('70000000-0000-0000-0004-000000000001','valid/media.gif','media.gif','image/gif')$$, '23514', null, 'disallowed media MIME is rejected');
select lives_ok($$insert into public.documents (id,property_id,title,storage_path,file_name) values ('70000000-0000-0000-0012-000000000002','70000000-0000-0000-0004-000000000001','Optional metadata','properties/70000000-0000-0000-0004-000000000001/documents/70000000-0000-0000-0012-000000000002/same.pdf','same.pdf')$$, 'nullable optional document metadata remains accepted');
select lives_ok($$insert into public.media (id,property_id,storage_path,file_name) values ('70000000-0000-0000-0016-000000000002','70000000-0000-0000-0004-000000000001','properties/70000000-0000-0000-0004-000000000001/media/70000000-0000-0000-0016-000000000002/same.pdf','same.pdf')$$, 'same filename under a distinct UUID-scoped path is accepted');
select throws_ok($$insert into public.profiles (role,first_name,last_name,email,avatar_url) values ('homeowner','Blank','Avatar','phase7-avatar@example.homehub','   ')$$, '23514', null, 'blank avatar metadata is rejected');
select lives_ok($$insert into public.profiles (role,first_name,last_name,email,avatar_url) values ('homeowner','Null','Avatar','phase7-null-avatar@example.homehub',null)$$, 'nullable avatar metadata remains accepted');

select * from finish();
rollback;
