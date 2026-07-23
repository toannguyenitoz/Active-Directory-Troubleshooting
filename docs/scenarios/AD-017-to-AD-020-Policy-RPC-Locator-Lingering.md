<p align="center"><img src="../../assets/images/ad-troubleshooting-header.svg" alt="Active Directory Troubleshooting Handbook" width="100%"></p>
<p align="center"><img src="https://img.shields.io/badge/Scenarios-AD--017%20to%20AD--020-0078D4?style=for-the-badge" alt="AD-017 to AD-020"> <img src="https://img.shields.io/badge/Focus-Password%20Policy%20%7C%20RPC%20%7C%20DC%20Locator%20%7C%20Lingering%20Objects-5B9BD5?style=for-the-badge" alt="Focus"> <img src="https://img.shields.io/badge/Level-L2%2FL3-7F5AF0?style=for-the-badge" alt="L2/L3"> <img src="https://img.shields.io/badge/Status-Complete-16A34A?style=for-the-badge" alt="Complete"></p>

# 🧭 AD-017 to AD-020 — Policy, RPC, DC Locator, and Lingering Objects

> [!IMPORTANT]
> Validate DNS, time, replication direction, and the authoritative data source before applying fixes. Lingering-object remediation is a high-risk operation.

<p align="center"><img src="../../assets/images/troubleshooting-workflow.svg" alt="Structured troubleshooting workflow" width="100%"></p>

## 🔑 AD-017 — Fine-Grained Password Policy Ignored
### 🚨 Symptoms
A user receives the default domain password policy rather than the expected Password Settings Object (PSO).
### 🔎 Diagnose
```powershell
Get-ADUserResultantPasswordPolicy username
Get-ADFineGrainedPasswordPolicy -Filter *
Get-ADFineGrainedPasswordPolicySubject -Identity 'PSO-Helpdesk'
```
PSOs apply directly to users or global security groups, not OUs. If several apply, the lowest precedence value wins; a directly assigned PSO has priority over group-derived PSOs.
### 🛠️ Resolve
Assign the PSO to the correct user or global group, correct group scope and membership, fix precedence, and confirm replication. A GPO linked to an OU does not define password policy for domain accounts.
### ✅ Verify
Run `Get-ADUserResultantPasswordPolicy` and test with a controlled non-production account.

---
## 🔌 AD-018 — RPC Server Unavailable
### 🚨 Symptoms
Replication, WMI, remote administration, GPO processing, or DC promotion fails with error 1722.
### 🔎 Diagnose
```powershell
Test-NetConnection dc02 -Port 135
Resolve-DnsName dc02.contoso.com
```
Use `repadmin /showrepl` to identify the failing direction and partner. Check Windows Firewall, network ACLs, TCP 135, dynamic RPC ports, DNS, routing, IPsec, endpoint security, required services, and packet loss.
### 🛠️ Resolve
Restore correct name resolution and bidirectional connectivity. Permit TCP 135 and the approved dynamic RPC range only between required systems. Remove stale DNS records and start failed services after identifying why they stopped.
### ✅ Verify
Repeat port tests, run `repadmin /syncall /AdeP`, and retry the original operation.

---
## 📡 AD-019 — Client Cannot Locate a Domain Controller
### 🚨 Symptoms
Domain join fails, logon is slow, **No logon servers** appears, or the client selects a remote DC.
### 🔎 Diagnose
```cmd
ipconfig /all
nltest /dsgetdc:contoso.com /force
nltest /dsgetsite
```
```powershell
Resolve-DnsName _ldap._tcp.dc._msdcs.contoso.com -Type SRV
```
Check client DNS, DHCP options 006/015, DNS suffixes, SRV/A records, AD Sites and Services subnet mapping, VPN DNS behaviour, firewall rules, and DC advertising.
### 🛠️ Resolve
Point clients only to internal AD DNS, correct DHCP/VPN settings, create missing subnets, repair DC DNS registration, and remove stale records.
### ✅ Verify
Flush DNS, rediscover the DC, confirm the expected site and DC, access SYSVOL, and test domain authentication.

---
## 👻 AD-020 — Lingering Objects After Restore
### 🚨 Symptoms
Deleted objects reappear, replication is blocked, or Directory Service Events 1988 or 2042 occur after a long outage or unsupported restore.

> [!CAUTION]
> Do not force replication before determining which DC contains authoritative, current data. Preserve logs and backups. Always run advisory mode first.

### 🔎 Diagnose
Identify the healthy reference DC, affected naming context, object GUID, tombstone lifetime, and how long the suspect DC was offline.
```cmd
repadmin /showrepl
repadmin /replsummary
repadmin /removelingeringobjects <DestinationDC> <SourceDC-GUID> <NamingContext> /ADVISORY_MODE
```
### 🛠️ Resolve
Remove lingering objects only with an approved procedure and a known-good reference DC. If confidence in the DC is low, demote and rebuild it instead of attempting high-risk cleanup.
### ✅ Verify
Run advisory mode again, confirm clean replication, inspect Directory Service logs, and compare critical objects across DCs.
### 🛡️ Prevention
Alert on long replication gaps, retire failed DCs promptly, use supported virtualization restore, and test disaster-recovery procedures.

---
<p align="center"><a href="../SCENARIO-INDEX.md"><b>📚 Scenario Index</b></a> · <a href="../../README.md"><b>🏠 Repository Home</b></a> · <a href="#top"><b>⬆️ Back to Top</b></a></p>
<p align="center"><b>Author: Xuan Toan Nguyen</b><br>Systems Administration &amp; IT Support • Adelaide, South Australia<br><a href="https://github.com/toannguyenitoz">GitHub</a> · <a href="https://www.linkedin.com/in/toan-nguyen-it-oz">LinkedIn</a></p>
<p align="center"><sub>⭐ Star the repository if these guides help your troubleshooting. • #ToanNguyenITOz</sub></p>