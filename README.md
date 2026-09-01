# mssql-automated-maintenance-toolkit
Database Administration (DBA), handling 60–80GB log file bloat, index defragmentation, and recovering 180GB+ disk space under heavy ingestion. 

# MS SQL Automated Maintenance Toolkit

An automated Database Administration (DBA) engine built to safely recover disk space, mitigate massive transaction log bloat (60–80GB+), and perform smart index defragmentation under high-ingestion workloads.

## Key Capabilities

* **Transaction Log Recovery:** Safely shrink bloated `.ldf` files down to operational limits without database downtime or breaking log chains.
* **Smart Index Maintenance:** Evaluates fragmentation levels dynamically—using low-impact `REORGANIZE` for 10–30% fragmentation and targeted `REBUILD` for >30%.
* **Disk Space Reclamation:** Designed to recover 180GB+ of storage on tight infrastructure footprint constraints.
* **Automation Ready:** Native PowerShell automation wrapping `Invoke-Sqlcmd` with execution logging and Scheduled Task registration.

---

## Directory Structure

```text
mssql-automated-maintenance-toolkit/
├── sql/
│   ├── 01_check_log_space.sql     # Storage diagnostics
│   ├── 02_truncate_and_shrink.sql # Safe log reclamation
│   └── 03_index_maintenance.sql   # Index defragmentation
├── scripts/
│   ├── Execute-Maintenance.ps1    # Main PowerShell runner
│   └── Install-DbaTask.ps1        # Scheduled Task setup
├── .gitignore
└── README.md

```

---

## Execution Instructions

### 1. Manual PowerShell Execution

Run the maintenance suite directly against a targeted database:

```powershell
.\scripts\Execute-Maintenance.ps1 -ServerInstance "localhost" -DatabaseName "AQDB"

```

### 2. Scheduled Task Deployment

To deploy this routine as an automated off-peak task (e.g., weekly on Sunday at 2:00 AM):

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\scripts\Install-DbaTask.ps1 -ServerInstance "localhost" -DatabaseName "AQDB"

```

---

## License

MIT License. Free for internal DBA and operational use.

```

```
