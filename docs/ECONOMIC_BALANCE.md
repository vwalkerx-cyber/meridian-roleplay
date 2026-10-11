# Meridian Roleplay — Economic Balance Sheet & Provisional Parameters

> **Principle:** The economy is player-driven with sustainable baseline NPC employment. Money movement and item creation must be auditable and backed by time or risk.

---

## 1. Civilian Careers (Legal Baseline)

| Career / Activity | Base Rate | Distance / Time Multiplier | Route Bonus | Hourly Target Range | Risk Level |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Logistics Freight Courier** | \$175 / drop | +\$80 / km traveled | \$350 / route completion | \$3,500 – \$4,800 / hr | Very Low |
| **Mechanic / Tow Service** | \$150 / vehicle | \$50 / repair material consumed | N/A | \$4,000 – \$6,000 / hr | Low |
| **City Transit / Taxi** | \$120 / fare | +\$60 / mile | Customer Tip | \$3,000 – \$4,200 / hr | Low |
| **Retail & Diner Staff** | \$250 / 15-min shift | N/A | Player customer sales split | \$3,000 – \$4,500 / hr | None |

*Rationale:* A new citizen working 1 to 2 hours of legal baseline employment should comfortably afford daily consumables (food, water, fuel, smartphone, repair kits) and save toward vehicle deposits.

---

## 2. Living Costs & Money Sinks

| Item / Service | Baseline Cost | Sink Mechanism |
| :--- | :--- | :--- |
| **Food & Refreshment (24/7 or Diner)** | \$15 – \$45 | Money removed from economy / split with player business. |
| **Fuel (Full Tank Mule/Sedan)** | \$50 – \$110 | Direct money sink. |
| **Vehicle Repair Kit** | \$250 | Item consumed. |
| **Sales Tax** | 5.0% | Deposited into State Treasury account (`meridian_state_account`). |
| **Traffic / Misdemeanor Fines** | \$150 – \$1,200 | Deposited into Law Enforcement Agency Account (`meridian_lspd_account`). |

---

## 3. High-Risk / Criminal Activities (Provisional)

| Activity | Expected Crew Size | Payout Range (Total) | Evidence Left Behind | Law Enforcement Counterplay |
| :--- | :--- | :--- | :--- | :--- |
| **Convenience Store Register** | 1–2 players | \$800 – \$1,800 | Spent casings, surveillance report | 911 Silent Alarm, 45s response window |
| **Freight Cargo Hijack** | 2–3 players | \$3,500 – \$6,500 | Tire tracks, stolen serial markings | GPS tracker activation |
| **Local Bank Vault** | 3–4 players | \$15,000 – \$35,000 | Drill fragments, DNA, thermite burns | Dispatch notification, active standoff |

---

## 4. Audit & Anti-Inflation Rules

1. **Transaction Logging:** Any single transfer exceeding \$5,000 triggers an automated audit log entry.
2. **Negative Balance Guard:** Banking operations reject overdrafts unless a specific business credit agreement is authorized.
3. **No Phantom Money:** Corporate payroll and payouts are drawn strictly from active business treasury balances.
