-- ============================================================
-- Migration 0001: Extensions and Enums
-- HomeHub — foundational PostgreSQL extensions and domain enums
-- ============================================================

-- ── Extensions ───────────────────────────────────────────────
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";
create extension if not exists "citext";

-- ── User / Identity Role ──────────────────────────────────────
create type public.user_role as enum (
  'homeowner',
  'contractor',
  'inspector',
  'insurance_agent',
  'insurance_agency',
  'real_estate_agent',
  'real_estate_agency',
  'np_admin',
  'homehub_admin',
  'homehub_superadmin'
);

-- ── Property Status ───────────────────────────────────────────
create type public.property_status as enum (
  'active',
  'sold',
  'pending_transfer',
  'archived'
);

-- ── Property Type ─────────────────────────────────────────────
create type public.property_type as enum (
  'single_family',
  'condo',
  'townhouse',
  'multi_family',
  'mobile_home',
  'land',
  'commercial',
  'other'
);

-- ── Project Status ────────────────────────────────────────────
create type public.project_status as enum (
  'planned',
  'in_progress',
  'on_hold',
  'completed',
  'cancelled'
);

-- ── Project Type ──────────────────────────────────────────────
create type public.project_type as enum (
  'renovation',
  'repair',
  'maintenance',
  'inspection',
  'installation',
  'landscaping',
  'cleaning',
  'pest_control',
  'other'
);

-- ── Document Category ─────────────────────────────────────────
create type public.document_category as enum (
  'permit',
  'warranty',
  'contract',
  'invoice',
  'insurance',
  'inspection',
  'mitigation',
  'deed',
  'survey',
  'photo',
  'other'
);

-- ── Media Type ────────────────────────────────────────────────
create type public.media_type as enum (
  'image',
  'video',
  'pdf',
  'document',
  'other'
);

-- ── Notification Type ─────────────────────────────────────────
create type public.notification_type as enum (
  'maintenance_reminder',
  'weather_alert',
  'document_expiry',
  'project_update',
  'contractor_message',
  'compliance_reminder',
  'system_alert',
  'community_update'
);

-- ── Notification Status ───────────────────────────────────────
create type public.notification_status as enum (
  'unread',
  'read',
  'dismissed',
  'actioned'
);

-- ── Contractor Status ─────────────────────────────────────────
create type public.contractor_status as enum (
  'active',
  'inactive',
  'pending_review',
  'suspended'
);

-- ── Access Grant Type ─────────────────────────────────────────
create type public.access_grant_type as enum (
  'qr_code',
  'invite_link',
  'manual'
);

-- ── Billing Plan ──────────────────────────────────────────────
create type public.billing_plan as enum (
  'free',
  'basic',
  'pro',
  'gifted',
  'enterprise'
);

-- ── Insurance Policy Status ───────────────────────────────────
create type public.insurance_policy_status as enum (
  'active',
  'expired',
  'cancelled',
  'pending_renewal'
);

-- ── Audit Action ─────────────────────────────────────────────
create type public.audit_action as enum (
  'insert',
  'update',
  'delete',
  'login',
  'logout',
  'access_granted',
  'access_revoked',
  'document_uploaded',
  'document_deleted'
);
