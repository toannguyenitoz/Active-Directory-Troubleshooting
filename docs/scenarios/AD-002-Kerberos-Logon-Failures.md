<p align="center"><img src="../../assets/images/ad-troubleshooting-header.svg" alt="Active Directory Troubleshooting Handbook" width="100%"></p>

<p align="center">
<img src="https://img.shields.io/badge/Scenario-AD--002-0078D4?style=for-the-badge" alt="AD-002">
<img src="https://img.shields.io/badge/Category-Kerberos-5B9BD5?style=for-the-badge" alt="Kerberos">
<img src="https://img.shields.io/badge/Severity-High-E67E22?style=for-the-badge" alt="High">
<img src="https://img.shields.io/badge/Tools-klist%20%7C%20setspn%20%7C%20w32tm-7F5AF0?style=for-the-badge" alt="Tools">
<img src="https://img.shields.io/badge/Status-Complete-16A34A?style=for-the-badge" alt="Complete">
</p>

# 🔐 AD-002 — Kerberos Logon Failures

> [!WARNING]
> Do not delete SPNs or reset service-account passwords until every dependent service, cluster, scheduled task, application pool, and credential store has been identified.

## 🧭 Quick navigation
[Overview](#-overview) · [Symptoms](#-symptoms-and-impact) · [Causes](#-likely-causes) · [Diagnosis](#-diagnostic-workflow) · [Resolution](#-resolution-options) · [Verification](#-verification) · [Prevention](#-prevention)

<p align="center"><img src="../../assets/images/troubleshooting-workflow.svg" alt="Structured troubleshooting workflow" width="100%"></p>

## 📖 Overview
Kerberos is the preferred authentication protocol in an Active Directory domain. A failure may affect interactive logon, SMB, SQL Server, IIS, WinRM, scheduled tasks, or applications that depend on integrated Windows authentication.

## 🚨 Symptoms and impact
- Users repeatedly receive credential prompts.
- Access works by IP address but fails by host name.
- `KRB_AP_ERR_MODIFIED`, `KDC_ERR_S_PRINCIPAL_UNKNOWN`, or `KDC_ERR_PREAUTH_FAILED` appears.
- NTLM is used unexpectedly.
- Services fail after a password or service-account change.

## 🧩 Likely causes
- Duplicate, missing, or incorrect SPNs.
- Client, DC, and service clocks differ beyond Kerberos tolerance.
- DNS resolves a service name to the wrong host.
- Service account password does not match the configured service.
- Ticket cache contains stale tickets.
- Account encryption settings are incompatible.

## 🔎 Diagnostic workflow

### 1️⃣ Confirm DNS and DC discovery
```powershell
Resolve-DnsName dc01.contoso.com
nltest /dsgetdc:contoso.com
```

### 2️⃣ Confirm time synchronisation
```cmd
w32tm /query /status
w32tm /stripchart /computer:dc01.contoso.com /samples:5 /dataonly
```

### 3️⃣ Inspect Kerberos tickets
```cmd
klist
klist purge
```
Reproduce the issue and run `klist` again.

### 4️⃣ Validate SPNs
```cmd
setspn -Q HTTP/app.contoso.com
setspn -X
setspn -L CONTOSO\svc-web
```
A production SPN should normally exist once and on the identity that actually runs the service.

### 5️⃣ Review event logs
Check **System**, **Security**, and **Microsoft-Windows-Kerberos-Key-Distribution-Center/Operational**. Useful events include 4, 7, 11, 14, 16, 27, 4768, 4769, and 4771.

## 🛠️ Resolution options
- Correct DNS records and aliases.
- Remove a duplicate SPN only after identifying the valid owner:
```cmd
setspn -D HTTP/app.contoso.com CONTOSO\wrong-account
setspn -S HTTP/app.contoso.com CONTOSO\svc-web
```
- Restart the service after correcting its account password.
- Restore the domain time hierarchy; the forest-root PDC Emulator should use an approved reliable source.
- Purge tickets or sign out after changes.
- Review `msDS-SupportedEncryptionTypes` before changing encryption policy.

## ✅ Verification
```cmd
klist get HTTP/app.contoso.com
setspn -Q HTTP/app.contoso.com
```
Confirm the service ticket is issued for the expected SPN and that authentication no longer falls back to NTLM.

## 🛡️ Prevention
Use group Managed Service Accounts where supported, monitor duplicate SPNs, document aliases, maintain DNS hygiene, and monitor time drift.

## 🔗 Related scenarios
- [AD-013 — Kerberos Errors Caused by Clock Skew](AD-013-to-AD-016-Time-Recovery-Performance-Promotion.md#ad-013--kerberos-errors-caused-by-clock-skew)
- [AD-008 — Secure Channel Failure](AD-004-to-AD-008-Core-Services.md#ad-008--secure-channel-or-trust-relationship-failure)
- [AD-011 — Repeated Account Lockouts](AD-009-to-AD-012-Database-LDAP-Security.md#ad-011--repeated-account-lockouts)

---
<p align="center"><a href="../SCENARIO-INDEX.md"><b>📚 Scenario Index</b></a> · <a href="../../README.md"><b>🏠 Repository Home</b></a> · <a href="#top"><b>⬆️ Back to Top</b></a></p>
<p align="center"><b>Author: Xuan Toan Nguyen</b><br>Systems Administration &amp; IT Support • Adelaide, South Australia<br><a href="https://github.com/toannguyenitoz">GitHub</a> · <a href="https://www.linkedin.com/in/toan-nguyen-it-oz">LinkedIn</a></p>
<p align="center"><sub>⭐ Star the repository if this guide helps your troubleshooting. • #ToanNguyenITOz</sub></p>