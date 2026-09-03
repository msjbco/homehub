-- ============================================================
-- Migration 0013: Cross-Property Integrity
-- HomeHub — prevent property-scoped references crossing tenants
-- ============================================================

-- Abort before changing constraints if legacy rows violate the stronger model.
do $$
begin
  if exists (
    select 1 from public.maintenance_tasks c
    join public.home_systems p on p.id = c.home_system_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'maintenance_tasks.home_system_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.projects c join public.rooms p on p.id = c.room_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'projects.room_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.projects c join public.home_systems p on p.id = c.home_system_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'projects.home_system_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.documents c join public.projects p on p.id = c.project_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'documents.project_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.documents c join public.home_systems p on p.id = c.home_system_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'documents.home_system_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.media c join public.rooms p on p.id = c.room_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'media.room_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.media c join public.projects p on p.id = c.project_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'media.project_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.media c join public.home_systems p on p.id = c.home_system_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'media.home_system_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.insurance_policies c join public.documents p on p.id = c.document_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'insurance_policies.document_id crosses property boundaries'; end if;

  if exists (
    select 1 from public.property_ownership_periods c join public.documents p on p.id = c.evidence_document_id
    where c.property_id is distinct from p.property_id
  ) then raise exception 'property_ownership_periods.evidence_document_id crosses property boundaries'; end if;
end
$$;

-- Composite foreign keys require matching candidate keys. The existing global
-- primary keys remain authoritative; these pairs also encode property scope.
alter table public.rooms
  add constraint rooms_property_id_id_key unique (property_id, id);
alter table public.home_systems
  add constraint home_systems_property_id_id_key unique (property_id, id);
alter table public.projects
  add constraint projects_property_id_id_key unique (property_id, id);
alter table public.documents
  add constraint documents_property_id_id_key unique (property_id, id);

alter table public.maintenance_tasks
  drop constraint maintenance_tasks_home_system_id_fkey,
  add constraint maintenance_tasks_property_home_system_fkey
    foreign key (property_id, home_system_id)
    references public.home_systems (property_id, id)
    on delete set null (home_system_id);

alter table public.projects
  drop constraint projects_room_id_fkey,
  drop constraint projects_home_system_id_fkey,
  add constraint projects_property_room_fkey
    foreign key (property_id, room_id)
    references public.rooms (property_id, id)
    on delete set null (room_id),
  add constraint projects_property_home_system_fkey
    foreign key (property_id, home_system_id)
    references public.home_systems (property_id, id)
    on delete set null (home_system_id);

alter table public.documents
  drop constraint documents_project_id_fkey,
  drop constraint documents_home_system_id_fkey,
  add constraint documents_property_project_fkey
    foreign key (property_id, project_id)
    references public.projects (property_id, id)
    on delete set null (project_id),
  add constraint documents_property_home_system_fkey
    foreign key (property_id, home_system_id)
    references public.home_systems (property_id, id)
    on delete set null (home_system_id);

alter table public.media
  drop constraint media_room_id_fkey,
  drop constraint media_project_id_fkey,
  drop constraint media_home_system_id_fkey,
  add constraint media_property_room_fkey
    foreign key (property_id, room_id)
    references public.rooms (property_id, id)
    on delete set null (room_id),
  add constraint media_property_project_fkey
    foreign key (property_id, project_id)
    references public.projects (property_id, id)
    on delete set null (project_id),
  add constraint media_property_home_system_fkey
    foreign key (property_id, home_system_id)
    references public.home_systems (property_id, id)
    on delete set null (home_system_id);

alter table public.insurance_policies
  drop constraint insurance_policies_document_id_fkey,
  add constraint insurance_policies_property_document_fkey
    foreign key (property_id, document_id)
    references public.documents (property_id, id)
    on delete set null (document_id);

alter table public.property_ownership_periods
  add constraint property_ownership_periods_property_evidence_document_fkey
    foreign key (property_id, evidence_document_id)
    references public.documents (property_id, id)
    on delete restrict;

comment on constraint property_ownership_periods_property_evidence_document_fkey
  on public.property_ownership_periods is
  'Ownership evidence is historical provenance. Delete the ownership record or detach its evidence explicitly before deleting the document.';
