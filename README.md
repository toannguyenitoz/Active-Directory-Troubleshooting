<div align="center">

# 🛡️ Active Directory Troubleshooting

### Practical diagnostics, root-cause analysis, PowerShell tools, labs, and recovery guidance for Windows Server administrators

[![Windows Server](https://img.shields.io/badge/Windows%20Server-2016%20%7C%202019%20%7C%202022%20%7C%202025-0078D4?logo=windows)](https://learn.microsoft.com/windows-server/)
[![Active Directory](https://img.shields.io/badge/Active%20Directory-DS-0078D4?logo=microsoft)](https://learn.microsoft.com/windows-server/identity/ad-ds/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-5391FE?logo=powershell)](https://learn.microsoft.com/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Under%20Active%20Development-success)](#roadmap)

</div>

---

## 📌 About This Repository

This repository is a practical Active Directory troubleshooting knowledge base for:

- System Administrators
- Infrastructure Engineers
- IT Support L2/L3 teams
- Helpdesk engineers moving into Windows Server administration
- Students building enterprise lab experience

The goal is to document **100+ real-world Active Directory troubleshooting scenarios** using a consistent approach:

> **Symptoms → Possible causes → Diagnostic steps → Commands → Resolution → Prevention**

---

## 🚨 Core Troubleshooting Areas

| Area | Examples |
|---|---|
| Domain Controllers | DC boot failure, failed promotion, database issues |
| Authentication | Kerberos, NTLM, clock skew, SPNs, secure channel |
| Replication | Replication failures, lingering objects, DFSR, USN issues |
| DNS | Missing SRV records, dynamic updates, client DC location |
| Group Policy | GPO not applying, loopback, WMI filters, replication delay |
| SYSVOL | DFSR health, SYSVOL not shared, migration issues |
| FSMO | Role-holder failure, seizure, transfer, time hierarchy |
| Directory Database | NTDS.dit growth, offline maintenance, integrity checks |
| LDAP | Timeouts, signing, channel binding, expensive queries |
| Recovery | AD Recycle Bin, authoritative restore, system-state recovery |
| Performance | LSASS high CPU, LDAP load, replication backlog |
| Security | Account lockouts, stale objects, delegation, auditing |

---

## 🗂️ Repository Structure

```text
Active-Directory-Troubleshooting/
├── docs/
│   ├── domain-controllers/
│   ├── authentication/
│   ├── replication/
│   ├── dns/
│   ├── group-policy/
│   ├── sysvol-dfsr/
│   ├── fsmo/
│   ├── ldap/
│   ├── recovery/
│   ├── performance/
│   └── security/
├── scripts/
│   ├── health-check/
│   ├── replication/
│   ├── dns/
│   ├── kerberos/
│   └── reporting/
├── labs/
├── diagrams/
├── cheatsheets/
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

---

## 🧭 Scenario Index

### Phase 1 — Initial 20 Scenarios

- [ ] Domain Controller will not boot
- [ ] Kerberos logon failures
- [ ] Active Directory replication failures
- [ ] Missing DNS SRV records
- [ ] Group Policy not applying
- [ ] FSMO role holder unreachable
- [ ] SYSVOL not replicating with DFSR
- [ ] Secure channel or trust failure
- [ ] NTDS.dit growing too large
- [ ] LDAP queries timing out
- [ ] Repeated account lockouts
- [ ] Organizational Unit permission issues
- [ ] Kerberos ticket errors caused by clock skew
- [ ] AD Recycle Bin restore failure
- [ ] High LSASS CPU usage on a Domain Controller
- [ ] New Domain Controller promotion failure
- [ ] Fine-Grained Password Policy ignored
- [ ] RPC Server Unavailable
- [ ] Client cannot locate a Domain Controller
- [ ] Lingering objects after restore

See the detailed tracker in [`docs/SCENARIO-INDEX.md`](docs/SCENARIO-INDEX.md).

---

## 🧰 Essential Active Directory Tools

```powershell
# Domain Controller health
dcdiag /v

# Replication summary
repadmin /replsummary

# Replication details
repadmin /showrepl * /csv

# Discover a Domain Controller
nltest /dsgetdc:contoso.com

# Verify secure channel
Test-ComputerSecureChannel -Verbose

# Check SYSVOL and NETLOGON shares
net share

# Group Policy results
gpresult /h C:\Temp\GPReport.html

# Kerberos tickets
klist

# Service Principal Names
setspn -Q */server01

# DNS SRV records
nslookup -type=SRV _ldap._tcp.dc._msdcs.contoso.com
```

---

## ⚡ PowerShell Quick Health Check

Run the starter script from an elevated PowerShell session on a management server or Domain Controller:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\health-check\Invoke-ADHealthCheck.ps1
```

The script checks:

- Domain Controller discovery
- Core AD services
- SYSVOL and NETLOGON shares
- DCDIAG summary
- Replication summary
- DNS diagnostics
- FSMO role holders
- Recent critical Directory Service events

> Always review scripts in a lab before using them in production.

---

## 🧪 Recommended Lab Environment

| Component | Suggested configuration |
|---|---|
| Hypervisor | Hyper-V, VMware Workstation, or VirtualBox |
| Domain Controllers | 2 Windows Server VMs |
| Client | 1 Windows 11 VM |
| Domain | `corp.contoso.local` or another lab-only namespace |
| Sites | HQ and Branch |
| Services | AD DS, DNS, DHCP, Group Policy, DFSR |
| Optional | Windows Admin Center, RSAT, Wireshark |

Never use production credentials, production domain names, or sensitive company data in a public lab.

---

## 🧠 Troubleshooting Method

1. Confirm the business impact and affected scope.
2. Record exact error messages and timestamps.
3. Check DNS before changing Active Directory.
4. Validate time synchronization and network connectivity.
5. Review Event Viewer logs on clients and Domain Controllers.
6. Use native diagnostic tools before applying changes.
7. Change one variable at a time.
8. Verify replication and service health after remediation.
9. Document the root cause and prevention measures.

---

## 🗺️ Roadmap

- [x] Repository foundation
- [x] Initial scenario index
- [x] Starter AD health-check script
- [ ] Publish the first 20 detailed scenarios
- [ ] Add PowerShell reporting toolkit
- [ ] Add diagrams for authentication and replication flow
- [ ] Add downloadable cheat sheets
- [ ] Expand to 50 scenarios
- [ ] Expand to 100+ scenarios
- [ ] Add automated Markdown validation

---

## 🤝 Contributing

Contributions, corrections, lab screenshots, and real-world troubleshooting examples are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a pull request.

---

## ⚠️ Disclaimer

This project is intended for education, lab practice, and authorized administration only. Commands that modify directory services, replication, DNS, FSMO roles, or the AD database can cause outages or data loss when used incorrectly.

Always:

- Test in a lab first
- Take verified backups
- Confirm the recovery plan
- Follow your organization's change-management process

---

## 👨‍💻 Author

**Xuan Toan Nguyen**  
Systems Administrator & ICT Support Professional  
Adelaide, South Australia

[![LinkedIn](https://img.shields.io/badge/LinkedIn-toan--nguyen--it--oz-0A66C2?logo=linkedin)](https://www.linkedin.com/in/toan-nguyen-it-oz)
[![GitHub](https://img.shields.io/badge/GitHub-toannguyenitoz-181717?logo=github)](https://github.com/toannguyenitoz)

---

<div align="center">

⭐ Star the repository if it helps your Windows Server learning journey.

[Back to top](#-active-directory-troubleshooting)

</div>
