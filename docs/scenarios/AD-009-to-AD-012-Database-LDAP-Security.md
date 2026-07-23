<p align="center"><img src="../../assets/images/ad-troubleshooting-header.svg" alt="Active Directory Troubleshooting Handbook" width="100%"></p>
<p align="center"><img src="https://img.shields.io/badge/Scenarios-AD--009%20to%20AD--012-0078D4?style=for-the-badge" alt="AD-009 to AD-012"> <img src="https://img.shields.io/badge/Focus-NTDS%20%7C%20LDAP%20%7C%20Lockout%20%7C%20Delegation-5B9BD5?style=for-the-badge" alt="Focus"> <img src="https://img.shields.io/badge/Level-L2%2FL3-7F5AF0?style=for-the-badge" alt="L2/L3"> <img src="https://img.shields.io/badge/Status-Complete-16A34A?style=for-the-badge" alt="Complete"></p>

# 🗄️ AD-009 to AD-012 — Database, LDAP, Lockout, and Delegation

> [!IMPORTANT]
> Database maintenance, LDAP diagnostics, account-lockout investigation, and ACL changes require evidence collection and a tested rollback plan.

<p align="center"><img src="../../assets/images/troubleshooting-workflow.svg" alt="Structured troubleshooting workflow" width="100%"></p>

## 💾 AD-009 — NTDS.dit Database Growing Too Large
### 🚨 Symptoms
The database consumes unusual disk space, backup windows increase, or the DC approaches low disk capacity.
### 🔎 Diagnose
```powershell
Get-Item C:\Windows\NTDS\ntds.dit
Get-Volume
```
Review object churn, bulk imports or deletions, lingering objects, excessive attribute use, and Directory Service events. Online defragmentation reuses internal free pages but does not shrink the file.
### 🛠️ Resolve
Prefer capacity expansion or rebuilding a healthy replica when risk is high. Offline compaction requires DSRM, a verified System State backup, temporary space, and rollback planning.
> [!CAUTION]
> Use `ntdsutil files compact to <path>` only during an approved maintenance window and only after validating backup and recovery procedures.
### ✅ Verify
Confirm database integrity, free space, replication, service health, and a successful System State backup.

---
## 🔍 AD-010 — LDAP Queries Timing Out
### 🚨 Symptoms
Applications authenticate slowly, searches time out, or DC CPU rises during application activity.
### 🔎 Diagnose
```powershell
Test-NetConnection dc01 -Port 389
Test-NetConnection dc01 -Port 636
```
Use `ldp.exe`, application logs, Performance Monitor, and Event 1644 diagnostic logging with care. Review search base, filter, returned attributes, paging, indexes, referrals, GC usage, signing, channel binding, and certificates.
### 🛠️ Resolve
Optimize filters, request only required attributes, enable paging, query the correct naming context or Global Catalog, and add sensible retry and timeout behaviour. Correct LDAPS or signing incompatibilities rather than disabling security globally.
### ✅ Verify
Measure response time, DC CPU, Event 1644 volume, and application success under normal load.

---
## 🔒 AD-011 — Repeated Account Lockouts
### 🚨 Symptoms
A user locks again shortly after an unlock or password reset.
### 🔎 Diagnose
Review Security Event 4740 on the PDC Emulator and record **Caller Computer Name**. Also inspect Events 4771 and 4776.
```powershell
Search-ADAccount -LockedOut
Get-ADUser username -Properties LockedOut,BadPwdCount,LastBadPasswordAttempt
```
Check scheduled tasks, services, mapped drives, saved RDP credentials, mobile devices, VPN clients, Credential Manager, scripts, and disconnected sessions.
### 🛠️ Resolve
Update or remove the stale credential at its source. Unlock the account only after correcting the source. Treat unknown or distributed attempts as a possible security incident.
### ✅ Verify
Monitor new 4740 events and bad-password counts for an agreed observation period.

---
## 🏢 AD-012 — Organizational Unit Permission Issues
### 🚨 Symptoms
Delegated administrators receive **Access Denied**, cannot perform expected tasks, or can modify more objects than intended.
### 🔎 Diagnose
Enable Advanced Features in ADUC and review Security, Effective Access, inheritance, protected objects, deny ACEs, nested groups, and AdminSDHolder.
```cmd
dsacls "OU=Users,DC=contoso,DC=com"
```
Use a dedicated test account to reproduce the exact operation.
### 🛠️ Resolve
Delegate the minimum required tasks to role-based groups at the correct OU. Avoid broad Full Control and direct user ACEs. Understand `adminCount` and AdminSDHolder before changing protected accounts.
### ✅ Verify
Test expected allowed and denied operations, then confirm ACL replication.

---
<p align="center"><a href="../SCENARIO-INDEX.md"><b>📚 Scenario Index</b></a> · <a href="../../README.md"><b>🏠 Repository Home</b></a> · <a href="#top"><b>⬆️ Back to Top</b></a></p>
<p align="center"><b>Author: Xuan Toan Nguyen</b><br>Systems Administration &amp; IT Support • Adelaide, South Australia<br><a href="https://github.com/toannguyenitoz">GitHub</a> · <a href="https://www.linkedin.com/in/toan-nguyen-it-oz">LinkedIn</a></p>
<p align="center"><sub>⭐ Star the repository if these guides help your troubleshooting. • #ToanNguyenITOz</sub></p>