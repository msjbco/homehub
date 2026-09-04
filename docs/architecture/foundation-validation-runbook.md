# Foundation Validation Runbook

> **Status:** Authoritative Foundation v1 validation checklist
>
> **Protected migration range:** `202606260001`–`202606260018`

Run these commands from a clean local checkout on Windows PowerShell. Foundation validation is local-only.

## 1. Prerequisites and baseline

Docker Desktop must be running. Node.js 20 or newer and npm must be available. Confirm the repository baseline:

```powershell
git branch --show-current
git rev-parse HEAD
git status --short
docker version
```

Install exactly the locked application dependencies when setup is required:

```powershell
Set-Location backend
npm ci
Set-Location ../frontend
npm ci
Set-Location ..
```

`npm ci` must not change either lockfile. Existing validated installations may skip this step.

## 2. Local Supabase and database

From the repository root:

```powershell
npx --yes supabase@latest start --agent no
npx --yes supabase@latest db reset --local --agent no
npx --yes supabase@latest test db --local --agent no
npx --yes supabase@latest db diff --local --agent no
```

The freeze candidate contains 10 database test files and 365 pgTAP assertions. Reset must apply migrations 0001–0018 and load `supabase/seed.sql`. Every test must pass with no plan-count mismatch.

The only accepted local schema diff is exactly:

```sql
drop extension if exists "pg_net";
```

Any additional statement or difference fails validation. `pg_net` is a known Supabase local-stack artifact; do not create a HomeHub migration solely to suppress it.

## 3. Backend

```powershell
Set-Location backend
npm run typecheck
npm run lint
npm test
npm run build
Set-Location ..
```

The current backend test command runs the storage helper suite in `src/services/storage.test.ts`.

## 4. Frontend

```powershell
Set-Location frontend
npm run lint
npm run build
Set-Location ..
```

The Next.js build fetches configured Geist fonts from Google Fonts. The build environment therefore needs outbound access to `fonts.googleapis.com`; inability to reach it is an environment failure, not a successful build.

## 5. Repository integrity

```powershell
git diff --check
git status --short
git diff --exit-code f274f24f114fbcc4627b3d38c9c7adfa1ce84088 -- supabase/migrations
git diff --name-only f274f24f114fbcc4627b3d38c9c7adfa1ce84088 -- backend/package.json backend/package-lock.json frontend/package.json frontend/package-lock.json
```

The migration comparison must be empty. During documentation consolidation, the package/lockfile comparison must also be empty.

Search current executable code, seed, tests, and architecture documentation for obsolete identifiers:

```powershell
rg -n -i "public\.users|user_identities|household_memberships|organization_memberships|homehub_admin|homehub_superadmin|np_admin|insurance_agency|real_estate_agency" backend frontend supabase/seed.sql supabase/tests docs/architecture
```

Classify every result. `insurance_agency` and `real_estate_agency` are legitimate `organizations.org_type` values. Tests may deliberately prove obsolete roles absent. Historical migrations and the explicitly superseded authentication/storage plan may retain historical references; current authoritative documents and executable role logic must not present them as implemented identity tables or roles.

Run a focused credential scan of tracked files:

```powershell
git grep -n -I -E "(sk_live_[A-Za-z0-9]+|whsec_[A-Za-z0-9]{16,}|SUPABASE_SERVICE_ROLE_KEY=eyJ|AWS_SECRET_ACCESS_KEY=[^r])"
```

Any apparent credential must be investigated. Placeholder variable names, `.env.example` placeholders, deterministic SHA-256 test hashes, and local development defaults are not production credentials.

## 6. Remote safety

Do not use `--linked`, `supabase link`, `supabase db push`, or any remote project credential during this runbook. Do not infer remote deployment from local reset or migration success. Remote deployment begins only through a later explicit deployment gate.

## 7. Freeze record

Before tagging, record:

- Date and branch.
- Exact commit hash.
- Migration range 0001–0018.
- Authoritative document set.
- Canonical seed status.
- Database test file and assertion counts.
- Backend typecheck, lint, test, and build results.
- Frontend lint and build results.
- Exact schema-diff result and the accepted `pg_net` exception.
- Migration and package/lockfile integrity results.
- Secret-scan result.
- Clean Git status.
- Confirmation that no remote database operation occurred.

Do not create a tag until the freeze record is reviewed and the documentation commit is approved.
