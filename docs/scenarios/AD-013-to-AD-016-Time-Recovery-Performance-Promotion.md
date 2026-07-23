<p align="center"><img src="../../assets/images/ad-troubleshooting-header.svg" alt="Active Directory Troubleshooting Handbook" width="100%"></p>
<p align="center"><img src="https://img.shields.io/badge/Scenarios-AD--013%20to%20AD--016-0078D4?style=for-the-badge" alt="AD-013 to AD-016"> <img src="https://img.shields.io/badge/Focus-Time%20%7C%20Recovery%20%7C%20Performance%20%7C%20Promotion-5B9BD5?style=for-the-badge" alt="Focus"> <img src="https://img.shields.io/badge/Level-L2%2FL3-7F5AF0?style=for-the-badge" alt="L2/L3"> <img src="https://img.shields.io/badge/Status-Complete-16A34A?style=for-the-badge" alt="Complete"></p>

# ⏱️ AD-013 to AD-016 — Time, Recovery, Performance, and DC Promotion

> [!IMPORTANT]
> Time, recovery, and promotion issues can create broad authentication and replication failures. Validate dependencies before changing configuration.

<p align="center"><img src="../../assets/images/troubleshooting-workflow.svg" alt="Structured troubleshooting workflow" width="100%"></p>

## 🕒 AD-013 — Kerberos Errors Caused by Clock Skew
### 🚨 Symptoms
Kerberos authentication fails, tickets are invalid, or event messages report a time difference.
### 🔎 Diagnose
```cmd
w32tm /query /status
w32tm /query /source
w32tm /query /configuration
w32tm /monitor
```
Confirm domain members use the domain hierarchy and the forest-root PDC Emulator uses an approved reliable external source. Check hypervisor time integration and third-party time agents.
### 🛠️ Resolve
```cmd
w32tm /config /syncfromflags:domhier /update
w32tm /resync /rediscover
```
Configure external peers only on the designated PDC Emulator according to organizational standards.
### ✅ Verify
Compare offsets, confirm the expected source, purge stale Kerberos tickets if needed, and retest authentication.

---
## ♻️ AD-014 — AD Recycle Bin Restore Failure
### 🚨 Symptoms
Deleted objects cannot be found, restore fails, or a restored object lacks links or memberships.
### 🔎 Diagnose
```powershell
Get-ADOptionalFeature 'Recycle Bin Feature'
Get-ADObject -Filter 'isDeleted -eq $true' -IncludeDeletedObjects -Properties *
```
Confirm Recycle Bin was enabled before deletion. Check deleted-object lifetime, tombstone lifetime, parent OU existence, permissions, and garbage collection.
### 🛠️ Resolve
Restore deleted parent containers first when necessary:
```powershell
Restore-ADObject -Identity '<object-guid>'
```
If the object is no longer recoverable, use an approved authoritative System State restore or recreate it from documented configuration.
### ✅ Verify
Confirm attributes, group memberships, ACLs, application mappings, replication, and logon.

---
## 📈 AD-015 — High LSASS CPU Usage
### 🚨 Symptoms
A DC becomes slow, authentication latency rises, or `lsass.exe` consumes sustained CPU.
### 🔎 Diagnose
Collect Performance Monitor counters for Processor, NTDS, LDAP, Kerberos, memory, and network. Review expensive LDAP queries, authentication storms, retry loops, endpoint-security integrations, replication problems, and recent changes.
> [!CAUTION]
> Never terminate LSASS. Capture evidence using an approved support procedure before rebooting.
### 🛠️ Resolve
Optimize abusive LDAP clients, stop retry storms, patch supported defects, update security software with vendor guidance, and distribute load across healthy DCs.
### ✅ Verify
Compare CPU, LDAP latency, authentication rate, queues, and user impact before and after remediation.

---
## 🏗️ AD-016 — New Domain Controller Promotion Failure
### 🚨 Symptoms
Server Manager or `Install-ADDSDomainController` fails during prerequisite checks, replication, DNS setup, or reboot.
### 🔎 Diagnose
```cmd
dcdiag /e /v
repadmin /replsummary
nltest /dsgetdc:contoso.com
```
Review `C:\Windows\debug\DCPROMO.LOG`, `DCPROMOUI.LOG`, event logs, static IP, DNS, time, credentials, sites/subnets, functional levels, disk space, and required ports.
### 🛠️ Resolve
Correct the earliest prerequisite or connectivity failure. Remove incomplete metadata only when the failed promotion created partial DC objects.
### ✅ Verify
Confirm advertising, SYSVOL/NETLOGON, DNS records, Global Catalog status if required, inbound/outbound replication, and backup completion.

---
<p align="center"><a href="../SCENARIO-INDEX.md"><b>📚 Scenario Index</b></a> · <a href="../../README.md"><b>🏠 Repository Home</b></a> · <a href="#top"><b>⬆️ Back to Top</b></a></p>
<p align="center"><b>Author: Xuan Toan Nguyen</b><br>Systems Administration &amp; IT Support • Adelaide, South Australia<br><a href="https://github.com/toannguyenitoz">GitHub</a> · <a href="https://www.linkedin.com/in/toan-nguyen-it-oz">LinkedIn</a></p>
<p align="center"><sub>⭐ Star the repository if these guides help your troubleshooting. • #ToanNguyenITOz</sub></p>