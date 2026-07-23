<p align="center"><img src="../../assets/images/ad-troubleshooting-header.svg" alt="Active Directory Troubleshooting Handbook" width="100%"></p>

<p align="center">
  <img src="https://img.shields.io/badge/Scenario-AD--001-0078D4?style=for-the-badge" alt="AD-001">
  <img src="https://img.shields.io/badge/Category-Domain%20Controller-5B9BD5?style=for-the-badge" alt="Domain Controller">
  <img src="https://img.shields.io/badge/Severity-Critical-D13438?style=for-the-badge" alt="Critical">
  <img src="https://img.shields.io/badge/Level-L2%2FL3-7F5AF0?style=for-the-badge" alt="L2/L3">
  <img src="https://img.shields.io/badge/Status-Complete-16A34A?style=for-the-badge" alt="Complete">
</p>

# 🖥️ AD-001 — Domain Controller Won't Boot

> [!CAUTION]
> A failed Domain Controller can affect authentication, DNS, Group Policy, replication, certificates, file access, and business applications. Preserve evidence and confirm another healthy writable DC is available before making destructive changes.

## 🧭 Quick navigation

[Overview](#-overview) · [Impact](#-business-impact) · [Symptoms](#-symptoms) · [Diagnosis](#-diagnostic-workflow) · [Resolution](#-resolution-options) · [Verification](#-verification) · [Prevention](#-prevention)

<p align="center"><img src="../../assets/images/troubleshooting-workflow.svg" alt="Structured troubleshooting workflow" width="100%"></p>

## 📖 Overview

A Domain Controller that cannot complete the Windows boot process is a priority incident. The failure may originate from Windows, storage, drivers, the AD DS database, SYSVOL, registry configuration, or a failed update. The first objective is to determine whether the server is experiencing an operating-system boot problem or an Active Directory service-start problem.

## 💼 Business impact

| Area | Possible impact |
|---|---|
| Authentication | Users may be unable to sign in or access Kerberos services |
| DNS | Clients may fail to locate domain services |
| Group Policy | New or updated GPOs may not apply |
| Replication | Directory changes may become inconsistent across DCs |
| Applications | LDAP, integrated authentication, and service accounts may fail |
| Recovery | A single-DC domain may face major outage or data-loss risk |

## 🚨 Symptoms

- Boot loop, black screen, or Blue Screen of Death.
- Windows starts but **Active Directory Domain Services** does not.
- Event Viewer reports NTDS, ESENT, disk, DFSR, or service-control errors.
- `SYSVOL` and `NETLOGON` shares are missing.
- The DC starts only in Directory Services Restore Mode.
- Clients report **No logon servers available**.

## 🧩 Likely causes

- Storage failure, file-system corruption, or insufficient free space.
- Corrupted `ntds.dit`, transaction logs, registry hives, or Windows files.
- Failed Windows Update, driver, firmware, or security-agent change.
- Incorrect boot configuration or BitLocker recovery issue.
- Unsupported virtual-machine rollback or snapshot operation.
- AD DS dependencies, DNS, DFSR, or Netlogon service failures.

## 🛡️ Prerequisites and safety checks

- Confirm whether another healthy writable DC and DNS server exist.
- Record recent changes, outage start time, error codes, and screenshots.
- Verify a recent **System State backup** and recovery media.
- Do not copy `ntds.dit` between DCs or restore a VM using an unsupported method.
- Avoid offline database repair until supported recovery options are assessed.

## 🔎 Diagnostic workflow

### 1️⃣ Identify the failure layer

Try **Safe Mode**, **Last Known Good/Startup Repair**, and **Directory Services Restore Mode (DSRM)** as appropriate. Record the exact point where startup fails.

### 2️⃣ Check storage and Windows integrity

```cmd
chkdsk C: /scan
sfc /scannow
DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /RestoreHealth
```

> [!NOTE]
> From WinRE or an offline environment, drive letters may differ. Confirm the Windows volume before running repair commands.

### 3️⃣ Check critical services

```powershell
Get-Service NTDS,DNS,DFSR,Netlogon,KDC,W32Time | Format-Table Name,Status,StartType
```

### 4️⃣ Review health and event logs

```cmd
dcdiag /v /c /d /e > C:\Temp\dcdiag.txt
repadmin /replsummary
repadmin /showrepl
```

Review these logs:

- **Directory Service**
- **DFS Replication**
- **DNS Server**
- **System**
- **Application / ESENT**

### 5️⃣ Verify AD DS files and shares

```powershell
Test-Path C:\Windows\NTDS\ntds.dit
Test-Path C:\Windows\SYSVOL\domain
Get-SmbShare -Name SYSVOL,NETLOGON -ErrorAction SilentlyContinue
```

## 🛠️ Resolution options

### ✅ Option A — Repair Windows or storage

Use this when the AD database is healthy but Windows, drivers, or storage are damaged. Correct the underlying disk/controller issue before returning the DC to service.

### ✅ Option B — Roll back a failed change

Remove a problematic update, driver, endpoint-security component, or configuration change using a documented maintenance procedure.

### ✅ Option C — Restore System State

Use a supported System State restore when the DC contains required directory data and a tested backup exists. Follow authoritative or non-authoritative recovery procedures based on the incident.

### ✅ Option D — Demote or rebuild the DC

In a multi-DC environment, rebuilding is often safer than repairing a severely damaged replica. Confirm replication health, FSMO roles, DNS dependencies, and Global Catalog availability first.

### ⚠️ Option E — Metadata cleanup

Perform metadata cleanup only when the failed DC is permanently removed and cannot be cleanly demoted.

## ✅ Verification

```cmd
dcdiag /v
repadmin /replsummary
repadmin /showrepl
net share
nltest /dsgetdc:contoso.com
```

Confirm that:

- AD DS, DNS, KDC, Netlogon, DFSR, and W32Time are running.
- `SYSVOL` and `NETLOGON` are shared.
- DNS SRV records are registered.
- Replication succeeds in both directions.
- A test user can authenticate and receive Group Policy.
- A new System State backup completes successfully.

## 🛡️ Prevention

- Maintain tested System State backups and documented bare-metal recovery procedures.
- Monitor disk latency, free space, NTDS/DFSR events, replication, and service health.
- Test updates and security agents before deployment to Domain Controllers.
- Use at least two writable DCs and DNS servers for production domains.
- Never treat hypervisor snapshots as an AD backup strategy.

## 🔗 Related scenarios

- [AD-003 — Active Directory Replication Failures](AD-003-AD-Replication-Failures.md)
- [AD-007 — SYSVOL Not Replicating](AD-004-to-AD-008-Core-Services.md#ad-007--sysvol-not-replicating-with-dfsr)
- [AD-016 — Domain Controller Promotion Failure](AD-013-to-AD-016-Time-Recovery-Performance-Promotion.md#ad-016--new-domain-controller-promotion-failure)

---

<p align="center">
  <a href="../SCENARIO-INDEX.md"><b>📚 Scenario Index</b></a> ·
  <a href="../../README.md"><b>🏠 Repository Home</b></a> ·
  <a href="#top"><b>⬆️ Back to Top</b></a>
</p>

<p align="center"><b>Author: Xuan Toan Nguyen</b><br>Systems Administration &amp; IT Support • Adelaide, South Australia<br><a href="https://github.com/toannguyenitoz">GitHub</a> · <a href="https://www.linkedin.com/in/toan-nguyen-it-oz">LinkedIn</a></p>

<p align="center"><sub>⭐ Found this guide useful? Star the repository and share it with another IT professional. • #ToanNguyenITOz</sub></p>