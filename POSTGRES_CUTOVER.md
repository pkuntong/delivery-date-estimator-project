# Postgres Cutover Runbook

This project currently runs Prisma on SQLite. For durable production on serverless, migrate to managed Postgres.

## Prerequisites

- Managed Postgres connection string (`DATABASE_URL`)
- Vercel project access
- Shopify app already deployed from this repo

## 1) Set production database URL

In Vercel Production env:

- `DATABASE_URL=postgresql://...`

## 2) Run automated cutover

From repo root:

```bash
DATABASE_URL='postgresql://...' ./scripts/cutover-postgres.sh
```

What this does:

- Switches Prisma datasource provider to `postgresql`
- Switches Prisma URL to `env("DATABASE_URL")`
- Rebuilds migrations from empty schema (Postgres SQL)
- Runs `prisma migrate deploy`

Backups are written with timestamps:

- `delivery-date-estimator/prisma/schema.prisma.bak.<timestamp>`
- `delivery-date-estimator/prisma/migrations.bak.<timestamp>`

## 3) Verify

```bash
npm run build
vercel --prod
curl -I https://delivery-date-estimator-project.vercel.app
```

Expected:

- Build succeeds
- Deploy status `Ready`
- Site returns `HTTP/2 200`

## 4) Commit migration changes

```bash
git add delivery-date-estimator/prisma delivery-date-estimator/prisma/schema.prisma
git commit -m "Migrate Prisma datasource to PostgreSQL"
git push origin main
```
