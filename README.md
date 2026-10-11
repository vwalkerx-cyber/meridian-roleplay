# Meridian Roleplay

> **Tagline:** Every Choice Shapes the State.  
> **Jurisdiction:** The State of Meridian (Capital: Los Santos)  
> **Roleplay Style:** Semi-serious | Bilingual (English & Indonesian)  
> **Framework:** QBCore + ox_inventory + oxmysql + ox_lib  
> **GitHub Repository:** [vwalkerx-cyber/meridian-roleplay](https://github.com/vwalkerx-cyber/meridian-roleplay)

---

## 1. Quick Start / Local Development Guide

### Prerequisites
1. **Windows 10/11 64-bit**
2. **Git for Windows** (Verified: `v2.56+`)
3. **Node.js & npm** (Verified: `v24.16+`)
4. **MariaDB or MySQL 8.0+** (Available via local XAMPP at `C:\xampp`)
5. **FiveM Server Artifacts** (Latest recommended Windows FXServer build)

---

### Step 1: Start MySQL Database
1. Open **XAMPP Control Panel** (`C:\xampp\xampp-control.exe`) or run MySQL service.
2. Start the **MySQL** module (default port: `3306`).
3. Open your database management tool (HeidiSQL, phpMyAdmin, or MySQL CLI) and create the server database:
   ```sql
   CREATE DATABASE IF NOT EXISTS `meridian_rp` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

---

### Step 2: Download FXServer Windows Artifacts
1. Download the latest recommended server build from the official FiveM runtime repository:
   [FiveM Windows Server Artifacts](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/)
2. Extract the archive into a dedicated folder (e.g., `fxserver/` or `C:\FXServer\server`).
3. Point your start command to this directory's `server.cfg`.

---

### Step 3: Populate Server Keys
Open [server.cfg](file:///c:/Users/kikil/OneDrive/Documents/FiveM%20Server/Meridian%20Roleplay/server.cfg) and fill in:
- `sv_licenseKey`: Your FiveM server license key from [Cfx.re Keymaster](https://keymaster.fivem.net/).
- `set steam_webApiKey`: Your Steam API Key from [Steam Community Dev](https://steamcommunity.com/dev/apikey).

---

### Step 4: Resource Architecture
All custom Meridian features are located in `resources/[meridian]/`:
- `meridian-core`: Shared foundations, security, audit logging, permissions, and database helpers.
- `meridian-banking`: Personal, corporate, and municipal banking accounts and ledgers.
- `meridian-businesses`: Player-owned companies, employee contracts, invoices, and payroll.
- `meridian-civilian`: Core civilian career loops (logistics, towing, transport, retail).
- `meridian-emergency`: Public safety agencies (LSPD, BCSO, MSP, EMS) and coordinated dispatch.
- `meridian-justice`: Case files, evidence logs, chain of custody, and warrants.
- `meridian-organizations`: Criminal groups, applications, influence ratings, and activities.
- `meridian-ui`: Meridian Roleplay design system, shared NUI components, and themes.

For full architectural details, see [docs/MILESTONE_1_ASSESSMENT.md](file:///c:/Users/kikil/OneDrive/Documents/FiveM%20Server/Meridian%20Roleplay/docs/MILESTONE_1_ASSESSMENT.md).
