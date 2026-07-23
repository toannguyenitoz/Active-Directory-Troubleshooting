<p align="center"><img src="../../assets/images/ad-troubleshooting-header.svg" alt="Active Directory Troubleshooting Handbook" width="100%"></p>
<p align="center"><img src="https://img.shields.io/badge/Scenarios-AD--004%20to%20AD--008-0078D4?style=for-the-badge" alt="AD-004 to AD-008"> <img src="https://img.shields.io/badge/Focus-DNS%20%7C%20GPO%20%7C%20FSMO%20%7C%20DFSR%20%7C%20Trust-5B9BD5?style=for-the-badge" alt="Focus"> <img src="https://img.shields.io/badge/Level-L2%2FL3-7F5AF0?style=for-the-badge" alt="L2/L3"> <img src="https://img.shields.io/badge/Status-Complete-16A34A?style=for-the-badge" alt="Complete"></p>

# 🧰 AD-004 to AD-008 — Core Active Directory Services

> [!IMPORTANT]
> DNS, SYSVOL, replication, authentication, and FSMO operations are interdependent. Diagnose the earliest dependency failure before applying downstream fixes.

<p align="center"><img src="../../assets/images/troubleshooting-workflow.svg" alt="Structured troubleshooting workflow" width="100%"></p>

## 🌐 AD-004 — Missing DNS SRV Records
### 🚨 Symptoms
Clients cannot locate a domain controller, domain joins fail, or `_ldap._tcp.dc._msdcs.<domain>` returns no records.
### 🔎 Diagnose
```powershell
Resolve-DnsName _ldap._tcp.dc._msdcs.contoso.com -Type SRV
Get-DnsServerResourceRecord -ZoneName contoso.com -RRType SRV
```
```cmd
ipconfig /all
nltest /dsregdns
dcdiag /test:dns /v
```
Verify the DC uses internal AD DNS, AD-integrated zones exist, dynamic updates are enabled, and Netlogon is running.
### 🛠️ Resolve
```cmd
ipconfig /registerdns
net stop netlogon
net start netlogon
```
Remove stale records only after confirming valid registrations. Check delegation for child domains and `_msdcs`.
### ✅ Verify
Run `dcdiag /test:dns`, query LDAP/Kerberos SRV records, and test `nltest /dsgetdc:contoso.com` from a client.

---
## 📜 AD-005 — Group Policy Not Applying
### 🚨 Symptoms
Settings are missing, `gpupdate /force` reports errors, or the client receives an unexpected GPO.
### 🔎 Diagnose
```cmd
gpresult /h C:\Temp\gpresult.html
gpresult /r
gpupdate /force
```
Check OU placement, link order, inheritance, Enforced, Block Inheritance, security filtering, WMI filters, loopback mode, SYSVOL access, and the GroupPolicy Operational log.
### 🛠️ Resolve
Correct scope or permissions. Ensure the target can read the GPO and has **Apply Group Policy**. Repair SYSVOL/DFSR before editing GPO content.
### ✅ Verify
Review Resultant Set of Policy and GroupPolicy/Operational events after a reboot or sign-in.

---
## 👑 AD-006 — FSMO Role Holder Unreachable
### 🚨 Symptoms
Password changes, RID allocation, time, schema updates, or domain changes fail depending on the unavailable role.
### 🔎 Diagnose
```cmd
netdom query fsmo
repadmin /replsummary
dcdiag /test:knowsofroleholders /v
```
Determine whether the server is temporarily unavailable or permanently lost.
### 🛠️ Resolve
Transfer roles when possible:
```powershell
Move-ADDirectoryServerOperationMasterRole -Identity DC02 -OperationMasterRole PDCEmulator,RIDMaster,InfrastructureMaster
```
> [!CAUTION]
> Seize a role only when the former holder will never return. Rebuild the former holder before reconnecting it.
### ✅ Verify
Run `netdom query fsmo`, then test replication, time, RID issuance, and role-specific operations.

---
## 📁 AD-007 — SYSVOL Not Replicating with DFSR
### 🚨 Symptoms
GPO folders differ, DFSR events 2213/4012/4614 appear, or SYSVOL/NETLOGON shares are missing.
### 🔎 Diagnose
```cmd
dfsrmig /getglobalstate
dfsrmig /getmigrationstate
repadmin /replsummary
dcdiag /test:sysvolcheck /test:advertising
```
Review DFS Replication logs, free space, and AD replication. Compare `C:\Windows\SYSVOL\domain` between DCs.
### 🛠️ Resolve
Fix AD replication and storage first. Use a documented authoritative/non-authoritative DFSR SYSVOL recovery procedure; do not improvise in production.
### ✅ Verify
Confirm SYSVOL and NETLOGON shares, matching GPO folders, and clean `dcdiag` results.

---
## 🤝 AD-008 — Secure Channel or Trust Relationship Failure
### 🚨 Symptoms
“The trust relationship between this workstation and the primary domain failed,” or `Test-ComputerSecureChannel` returns false.
### 🔎 Diagnose
```powershell
Test-ComputerSecureChannel -Verbose
```
```cmd
nltest /sc_verify:contoso.com
nltest /dsgetdc:contoso.com
```
Check DNS, time, duplicate computer objects, snapshot rollback, and DC connectivity.
### 🛠️ Resolve
```powershell
Test-ComputerSecureChannel -Repair -Credential CONTOSO\Administrator
```
Alternatively use `Reset-ComputerMachinePassword`. Rejoin the domain only when repair is not possible.
### ✅ Verify
Restart, confirm domain logon, run `nltest /sc_verify`, and access SYSVOL.

---
<p align="center"><a href="../SCENARIO-INDEX.md"><b>📚 Scenario Index</b></a> · <a href="../../README.md"><b>🏠 Repository Home</b></a> · <a href="#top"><b>⬆️ Back to Top</b></a></p>
<p align="center"><b>Author: Xuan Toan Nguyen</b><br>Systems Administration &amp; IT Support • Adelaide, South Australia<br><a href="https://github.com/toannguyenitoz">GitHub</a> · <a href="https://www.linkedin.com/in/toan-nguyen-it-oz">LinkedIn</a></p>
<p align="center"><sub>⭐ Star the repository if these guides help your troubleshooting. • #ToanNguyenITOz</sub></p>