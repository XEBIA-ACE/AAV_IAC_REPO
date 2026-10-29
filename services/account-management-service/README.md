# Account Management Service (scaffold)

Scaffold for the Account Management Service, implemented for story **SCAFFOLD-SVC-001**
(acceptance criterion **AC-1**, tasks **T001–T005**). Stack: Node.js 22 + TypeScript, Express,
PostgreSQL (`pg` connection pool), `pino` logging, `zod` env validation, ESLint + Prettier, Vitest.

This is a scaffold only: no authentication, OAuth 2.0, JWT, registration or other business
endpoints are implemented.

## Configuration (T002)

All configuration is read from environment variables (`src/config/index.ts`). Nothing secret
or environment-specific is hardcoded; startup fails fast and lists only the _names_ of invalid
or missing variables (never their values). See `.env.example`.

| Variable                   | Required | Default       | Notes                                            |
| -------------------------- | -------- | ------------- | ------------------------------------------------ |
| `PORT`                     | yes      | –             | HTTP listen port                                 |
| `NODE_ENV`                 | no       | `development` | `development` \| `test` \| `production`          |
| `LOG_LEVEL`                | no       | `info`        | pino level                                       |
| `DB_HOST`                  | yes      | –             | PostgreSQL host                                  |
| `DB_PORT`                  | no       | `5432`        |                                                  |
| `DB_NAME`                  | yes      | –             |                                                  |
| `DB_USER`                  | yes      | –             |                                                  |
| `DB_PASSWORD`              | yes      | –             | Redacted from logs                               |
| `DB_SSL`                   | no       | `false`       | `true` enables TLS with certificate verification |
| `DB_POOL_MAX`              | no       | `10`          |                                                  |
| `DB_CONNECTION_TIMEOUT_MS` | no       | `5000`        |                                                  |

## Running

```bash
npm ci
npm run build
PORT=3000 DB_HOST=... DB_NAME=... DB_USER=... DB_PASSWORD=... npm start
# or, for development
PORT=3000 DB_HOST=... DB_NAME=... DB_USER=... DB_PASSWORD=... npm run dev
```

Container:

```bash
docker build -t account-management-service .
docker run --rm -p 3000:3000 -e PORT=3000 -e DB_HOST=... -e DB_NAME=... \
  -e DB_USER=... -e DB_PASSWORD=... account-management-service
```

## Health checks (T003)

- `GET /health` – liveness; always `200 {"status":"ok","service":"account-management-service"}`.
- `GET /health/ready` – readiness; runs `SELECT 1` against PostgreSQL and returns
  `200 {"status":"ok","checks":{"database":"up"}}` or `503 {"status":"unavailable","checks":{"database":"down"}}`.

Neither response includes configuration, hostnames, versions or error details.

## Database helper (T004)

`src/db/index.ts` exposes `createPool(dbConfig, logger?)` (pooled `pg.Pool` built from env-derived
config), `toPoolConfig(dbConfig)` and `checkDatabase(pool)`. Pool errors are logged by
message/code only, never with connection settings.

## Quality commands (T001)

```bash
npm run lint          # ESLint (typescript-eslint, prettier-compatible)
npm run format:check  # Prettier
npm run typecheck     # tsc --noEmit
npm test              # Vitest
```

`test/db.test.ts` and `test/ac-1.startup.test.ts` additionally exercise a real PostgreSQL when
`TEST_DB_HOST`, `TEST_DB_PORT`, `TEST_DB_NAME`, `TEST_DB_USER`, `TEST_DB_PASSWORD` are set;
otherwise those cases use an unreachable database and assert the `503` readiness path.

## Traceability

| ID   | Implementation / evidence                                                               |
| ---- | --------------------------------------------------------------------------------------- |
| T001 | `package.json`, `src/index.ts`, `Dockerfile`, `eslint.config.mjs`, `.prettierrc.json`   |
| T002 | `src/config/index.ts`, `.env.example`; tests: `test/config.test.ts`                     |
| T003 | `src/routes/health.ts`, `src/app.ts`; tests: `test/health.test.ts`                      |
| T004 | `src/db/index.ts`; tests: `test/db.test.ts`                                             |
| T005 | `test/ac-1.startup.test.ts` – starts the service with env vars only and calls `/health` |
| AC-1 | Covered at scaffold level by T001–T005 (see gaps below)                                 |

## Unresolved gaps and spec notes (SCAFFOLD-SVC-001)

1. **Architecture artifacts not available.** AC-1 asks to ground the scaffold in the service's
   C3/C4 diagrams and API spec "on file in Architecture". These are not present in this repository
   or in the spec export, so module boundaries, API paths and data model are not derived from them.
2. **AC-1 responsibilities not implemented.** AC-1 lists user authentication/authorization, account
   registration/management, OAuth 2.0 flow management and token generation/validation. The
   implementing instructions explicitly exclude these from the scaffold, so no auth libraries
   (JWT, Argon2/bcrypt), SMTP client or business endpoints were added.
3. **AC-1 is not directly testable as written.** Its text is a spec-generation directive rather than
   an observable criterion, and the implementation plan reports AC-1 as "not addressed by any step".
   Verification here is limited to the quality obligation: the service starts with env-only
   configuration and the health check responds.
4. **Migration tooling not wired.** The stack mentions TypeORM/Prisma/Flyway/Liquibase; per the
   instructions only connection setup is implemented. Choosing a migration tool is deferred.
5. **Readiness endpoint.** In addition to `/health`, a `/health/ready` endpoint reports database
   reachability (no sensitive data). It is part of the health-check scope but is called out because
   no endpoint contract was supplied.
6. **Repository context.** This repository otherwise contains Terraform IaC; the service lives under
   `services/account-management-service/`. No CI pipeline or Terraform deployment wiring was added.
