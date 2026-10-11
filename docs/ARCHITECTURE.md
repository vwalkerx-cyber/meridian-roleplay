# Meridian Roleplay — Architecture & Conventions Specification

## 1. Domain Separation & Directory Layout

Resources in Meridian Roleplay adhere strictly to single-domain ownership:

| Resource Name | Scope / Responsibility | Exports Provided |
| :--- | :--- | :--- |
| **`meridian-core`** | Shared logging, permission validation, database transaction abstraction, bilingual localization, formatting. | `LogAudit`, `LogSecurity`, `LogError`, `HasPermission`, `IsDuty`, `GetPlayerCitizenId`, `ExecuteTransaction`, `GetLocale`, `FormatCurrency`. |
| **`meridian-banking`** | Personal, business, and municipal accounts, invoices, and transaction ledgers. | `CreateInvoice`, `PayInvoice`, `GetAccountBalance`, `TransferFunds`. |
| **`meridian-businesses`** | Player-owned enterprises, job grades, employee permissions, payroll schedules, supplier contracts. | `GetBusiness`, `IsBusinessOwner`, `ProcessPayroll`. |
| **`meridian-civilian`** | Baseline launch careers: freight delivery, tow service, retail clerks. | N/A (Gameplay events & callbacks). |
| **`meridian-emergency`** | Law enforcement (LSPD, BCSO, MSP), SAFD/EMS, dispatch coordination. | `CreateDispatchCall`, `UpdateUnitStatus`. |
| **`meridian-justice`** | Incident reports, evidence chain-of-custody, case files, warrants. | `RegisterEvidence`, `CreateIncidentReport`. |
| **`meridian-organizations`**| Criminal syndicates, crews, territory influence metrics, covert activity state. | `GetOrgInfluence`, `CanInitiateActivity`. |
| **`meridian-ui`** | Shared design system, theme variables, NUI event adapters. | NUI components. |

---

## 2. Server-Authoritative Security Contract

1. **No Client Trust:**
   - Clients never send `amount`, `itemReward`, `grade`, or `isCompleted` without strict server-side state validation.
   - Payouts and item creations are calculated exclusively in server-side callbacks.
2. **Rate Limiting:**
   - Every sensitive event or callback must enforce server cooldowns (minimum 500ms to 1000ms for monetary actions).
3. **Structured Audit Logs:**
   - Any transaction > $5,000, permission change, rank modification, evidence registration, or admin action must call `exports['meridian-core']:LogAudit()`.
   - Any anomalous request (e.g., negative amount, out-of-range job grade) must call `exports['meridian-core']:LogSecurity()`.

---

## 3. Database & Migration Rules

- All table changes must be placed in `database/migrations/` as numbered SQL files (e.g., `001_core_logging.sql`, `002_banking_ledgers.sql`).
- All queries must be parameterized (`?` placeholders via `oxmysql`).
- Multi-table financial or inventory updates must execute via `exports['meridian-core']:ExecuteTransaction()`.
