# legalhelpdb

PostgreSQL schema for the Legal Problem Resolution & Documentation Consulting platform. Folder layout follows the high-level data model in the product specification (section 42).

## Layout

```text
db/
  00_init/                 Extensions, schemas, DB roles, shared helpers
  01_types/                Enums (priority, payment, consultation, channels, ...)
  02_tables/
    01_identity/           USER, USER_ROLE, CLIENT_PROFILE, ORGANIZATION
    02_catalog/            SERVICE, PACKAGE, PRICING, languages
    03_authorities/        AUTHORITY directory
    04_cases/              CASE, CASE_STATUS, CASE_PARTY, EVENT, TASK, NOTE, TIMELINE
    05_documents/          DOCUMENT, VERSION, TAG, ACCESS_LOG
    06_consultations/      CONSULTATION, APPOINTMENT, NOTE, SUMMARY
    07_drafts/             DRAFT, DRAFT_VERSION, CLIENT_COMMENT, APPROVAL
    08_billing/            PAYMENT, INVOICE, TRANSACTION, REFUND
    09_communications/     NOTIFICATION, MESSAGE
    10_followups/          FOLLOW_UP
    11_research/           LEGAL_REFERENCE
    12_content/            Legal awareness articles
    13_audit/              AUDIT_LOG
  03_indexes/
  04_functions/
  05_triggers/
  06_views/
  07_policies/             Row Level Security
  08_grants/
  09_seeds/lookup/         Roles, statuses, categories, packages
  09_seeds/demo/           Optional sample data (not applied on boot)
  10_rollback/             Down scripts only; never auto-applied
scripts/                   apply / reset / Docker first-boot
```

SQL files are numbered so `find | sort` applies them in dependency order.

## Schemas

| Schema | Spec entities |
| --- | --- |
| `identity` | USER, USER_ROLE, CLIENT_PROFILE, ORGANIZATION |
| `catalog` | SERVICE, PACKAGE, PRICING |
| `authorities` | AUTHORITY |
| `cases` | CASE and case-file tables |
| `documents` | DOCUMENT family |
| `consultations` | CONSULTATION family |
| `drafts` | DRAFT family |
| `billing` | PAYMENT, INVOICE, TRANSACTION, REFUND |
| `comms` | NOTIFICATION, MESSAGE |
| `followups` | FOLLOW_UP |
| `research` | LEGAL_REFERENCE |
| `content` | Awareness / CMS |
| `audit` | AUDIT_LOG |

## Run locally

Copy env, then apply the schema. Docker is optional; on Windows the script uses local `psql` (including `C:\Program Files\PostgreSQL\...\bin`) when Docker Desktop is not running.

```powershell
copy .env.example .env
.\scripts\apply.ps1
```

First-time Docker boot also loads every `db/**/*.sql` file except `09_seeds/demo` and `10_rollback`:

```powershell
docker compose up -d
```

Rebuild:

```powershell
.\scripts\apply.ps1 -Force    # local PostgreSQL
.\scripts\reset.ps1           # Docker volume
```

## Roles

| Role | Use |
| --- | --- |
| `legalhelp` | Docker superuser |
| `legalhelp_migrate` | DDL |
| `legalhelp_app` | DML for the API |
| `legalhelp_readonly` | Reporting |

App connections should `SET app.user_id` and `SET app.is_staff` so the RLS policies in `db/07_policies` can scope client access.
