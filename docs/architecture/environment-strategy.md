# Foundation Environment Strategy

> **Status:** Supporting Foundation v1 document

## Current development environment

HomeHub Foundation is validated locally on Windows with Docker Desktop and the Supabase CLI invoked through `npx`. `supabase/config.toml` defines an unlinked local project named `homehub`. Local reset, seed, test, and schema-diff operations target Docker containers on the developer machine.

The Git repository is the source of truth for migrations, seed data, tests, code, and documentation. Work is developed on feature branches and reviewed before deliberate integration. GitHub is the source-of-truth remote for repository history; a local commit or migration does not update GitHub until pushed.

## Local and remote separation

- `supabase start`, `supabase db reset --local`, `supabase test db --local`, and `supabase db diff --local` operate on the local stack.
- A local database reset destroys and rebuilds only the local development database. It is not deployment.
- Supabase Cloud is not automatically updated by local migration work or Git commits.
- Do not use `--linked`, `supabase db push`, or remote credentials during Foundation validation.
- Any staging or production deployment is a separate, explicit, reviewed gate after Foundation freeze.

## Secrets and credentials

No production secret belongs in the repository. Checked-in `.env.example` files contain names and placeholders only. Local Supabase URLs and default local keys are development credentials for the local stack; they are not production credentials and must not be promoted as such.

Browser-exposed variables must use only public values. Service-role keys, database credentials, payment-provider secrets, and future provider credentials must remain server-side and outside Git. Use the eventual hosting platform’s secret store for non-local environments.

## Current integration boundary

Foundation defines a local Supabase schema, private storage bucket metadata, pure backend storage validation/path helpers, and deterministic seed/test data. It does not implement:

- Remote Supabase deployment.
- Auth workflows or RLS.
- Live Supabase Storage I/O or policies.
- Stripe or another payment provider.
- AWS/S3 integration.
- Production deployment, backup, monitoring, or incident architecture.

Those capabilities require their own explicit implementation and deployment reviews.
