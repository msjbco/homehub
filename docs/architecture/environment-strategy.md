# HomeHub Environment & Configuration Strategy

## Purpose

This document defines HomeHub's environment and configuration foundation for local development, staging, and production. It documents required variables and handling rules without implementing Supabase, Stripe, AWS, database access, authentication, or business logic.

## Scope

This foundation creates:

- `frontend/.env.example`
- `backend/.env.example`
- environment documentation for local, staging, and production

This foundation does not implement:

- Supabase integration
- Stripe integration
- AWS integration
- authentication
- database access
- document storage
- business features
- prototype HTML migration

## Environment Principles

1. Never commit real secrets.
2. Keep local, staging, and production values separate.
3. Use Supabase staging and production projects separately.
4. Use Stripe test keys for local and staging.
5. Use Stripe live keys only in production.
6. Use separate AWS S3 buckets for staging and production.
7. Keep frontend variables limited to public/browser-safe values.
8. Keep service role keys, Stripe secrets, AWS secrets, and database URLs server-only.
9. Prefer platform secret stores over checked-in configuration.
10. Document every new environment variable when introduced.

## Files

### `frontend/.env.example`

Frontend variables use the `NEXT_PUBLIC_` prefix only when they are intended to be exposed to the browser.

Required frontend placeholders:

```
NEXT_PUBLIC_APP_ENV=local
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=replace-with-supabase-anon-key
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_replace_me
NEXT_PUBLIC_LOG_LEVEL=info
```

### `backend/.env.example`

Backend variables include private server-side secrets and must never be exposed to browser code.

Required backend placeholders:

```
APP_ENV=local
NODE_ENV=development
HOST=0.0.0.0
PORT=4000
APP_URL=http://localhost:3000
API_URL=http://localhost:4000
CORS_ALLOWED_ORIGINS=http://localhost:3000
LOG_LEVEL=info
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=replace-with-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=replace-with-supabase-service-role-key
SUPABASE_JWT_SECRET=replace-with-supabase-jwt-secret
DATABASE_URL=postgresql://postgres:password@localhost:5432/postgres
AWS_REGION=us-east-1
S3_DOCUMENT_BUCKET=homehub-documents-local
AWS_ACCESS_KEY_ID=replace-with-aws-access-key-id
AWS_SECRET_ACCESS_KEY=replace-with-aws-secret-access-key
STRIPE_PUBLISHABLE_KEY=pk_test_replace_me
STRIPE_SECRET_KEY=sk_test_replace_me
STRIPE_WEBHOOK_SECRET=whsec_replace_me
```

## Local Environment

### Purpose

The local environment is for developer machines and agent-driven implementation tasks.

### Expected URLs

```
Frontend: http://localhost:3000
Backend:  http://localhost:4000
```

### Local Rules

- Copy `frontend/.env.example` to `frontend/.env.local`.
- Copy `backend/.env.example` to `backend/.env`.
- Use Stripe test keys only.
- Use a Supabase local stack or a dedicated Supabase development project.
- Use a development or sandbox S3 bucket only after AWS integration is intentionally implemented.
- Do not connect local development to production Supabase, production Stripe, or production S3.

### Local Variable Guidance

| Variable | Local guidance |
|---|---|
| NEXT_PUBLIC_APP_ENV | local |
| NEXT_PUBLIC_APP_URL | http://localhost:3000 |
| NEXT_PUBLIC_API_URL | http://localhost:4000 |
| APP_ENV | local |
| NODE_ENV | development |
| LOG_LEVEL | debug or info |
| STRIPE_SECRET_KEY | sk_test_* only |
| STRIPE_PUBLISHABLE_KEY | pk_test_* only |
| S3_DOCUMENT_BUCKET | local/dev bucket placeholder |

## Staging Environment

### Purpose

The staging environment validates integrated work before promotion to production.

### Staging Rules

- Use the staging branch as the integration source.
- Use a dedicated Supabase staging project.
- Use Stripe test mode.
- Use a dedicated AWS S3 staging bucket.
- Use staging Vercel environment variables for frontend values.
- Store backend secrets in the backend hosting platform or GitHub environment secrets.
- Run smoke tests before promoting changes to main.

### Recommended Staging Values

```
NEXT_PUBLIC_APP_ENV=staging
NEXT_PUBLIC_APP_URL=https://staging.homehub.example
NEXT_PUBLIC_API_URL=https://api-staging.homehub.example
APP_ENV=staging
NODE_ENV=production
LOG_LEVEL=info
AWS_REGION=us-east-1
S3_DOCUMENT_BUCKET=homehub-documents-staging
```

### Staging Verification Checklist

- [ ] Frontend can read public environment variables.
- [ ] Backend can read server-only environment variables.
- [ ] CORS allows the staging frontend origin.
- [ ] Supabase staging credentials are not production credentials.
- [ ] Stripe keys are test-mode keys.
- [ ] S3 bucket is private and staging-only.
- [ ] Logs do not print secrets.

## Production Environment

### Purpose

The production environment serves live HomeHub users and must use production-grade secrets, isolation, backups, and monitoring.

### Production Rules

- Use the `main` branch for stable/live deployment.
- Use a dedicated Supabase production project.
- Use Stripe live mode only after launch approval.
- Use a dedicated private AWS S3 production bucket.
- Enable production database backups.
- Restrict access to production service role keys and AWS credentials.
- Do not log secret values.
- Rotate secrets if exposure is suspected.

### Recommended Production Values

```
NEXT_PUBLIC_APP_ENV=production
NEXT_PUBLIC_APP_URL=https://app.homehub.example
NEXT_PUBLIC_API_URL=https://api.homehub.example
APP_ENV=production
NODE_ENV=production
LOG_LEVEL=info
AWS_REGION=us-east-1
S3_DOCUMENT_BUCKET=homehub-documents-production
```

### Production Verification Checklist

- [ ] Frontend uses production public Supabase URL and anon key.
- [ ] Backend uses production Supabase server-side secrets.
- [ ] Stripe uses live keys only after production launch approval.
- [ ] S3 production bucket blocks public access.
- [ ] CORS allows only approved production origins.
- [ ] Logs and error reports redact secrets.
- [ ] Database backups are enabled.
- [ ] Secrets are stored outside the repository.

## Variable Classification

| Variable | Frontend public? | Backend only? | Secret? |
|---|---|---|---|
| NEXT_PUBLIC_APP_ENV | Yes | No | No |
| NEXT_PUBLIC_APP_URL | Yes | No | No |
| NEXT_PUBLIC_API_URL | Yes | No | No |
| NEXT_PUBLIC_SUPABASE_URL | Yes | No | No |
| NEXT_PUBLIC_SUPABASE_ANON_KEY | Yes | No | No, but must be paired with correct backend/RLS controls |
| NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY | Yes | No | No |
| APP_ENV | No | Yes | No |
| NODE_ENV | No | Yes | No |
| APP_URL | No | Yes | No |
| API_URL | No | Yes | No |
| CORS_ALLOWED_ORIGINS | No | Yes | No |
| LOG_LEVEL | No | Yes | No |
| SUPABASE_URL | No | Yes | No |
| SUPABASE_ANON_KEY | No | Yes | No, but server-side only by convention here |
| SUPABASE_SERVICE_ROLE_KEY | No | Yes | Yes |
| SUPABASE_JWT_SECRET | No | Yes | Yes |
| DATABASE_URL | No | Yes | Yes |
| AWS_REGION | No | Yes | No |
| S3_DOCUMENT_BUCKET | No | Yes | No |
| AWS_ACCESS_KEY_ID | No | Yes | Yes |
| AWS_SECRET_ACCESS_KEY | No | Yes | Yes |
| STRIPE_PUBLISHABLE_KEY | No | Yes | No |
| STRIPE_SECRET_KEY | No | Yes | Yes |
| STRIPE_WEBHOOK_SECRET | No | Yes | Yes |

## Implementation Guardrails

- Do not implement Supabase in this environment foundation step.
- Do not implement Stripe in this environment foundation step.
- Do not implement AWS in this environment foundation step.
- Do not introduce database access in this environment foundation step.
- Do not modify root-level prototype HTML files.
- Do not add business logic.
- Do not commit `.env`, `.env.local`, or real secrets.
