# AD-021 to AD-025 — SYSVOL, DFSR, SPN, Time and DNS

> Practical troubleshooting guidance for Windows Server Active Directory environments. Test every remediation in a lab and follow change-management procedures before production use.

## Navigation

- [AD-021 — SYSVOL and NETLOGON shares missing](#ad-021--sysvol-and-netlogon-shares-missing)
- [AD-022 — Event ID 2213 pauses DFSR replication](#ad-022--event-id-2213-pauses-dfsr-replication)
- [AD-023 — Duplicate SPN causes Kerberos failure](#ad-023--duplicate-spn-causes-kerberos-failure)
- [AD-024 — Time service hierarchy is incorrect](#ad-024--time-service-hierarchy-is-incorrect)
- [AD-025 — DNS scavenging deletes required records](#ad-025--dns-scavenging-deletes-required-records)

---

# AD-021 — SYSVOL and NETLOGON shares missing

**Category:** SYSVOL / DFSR  
**Severity:** Critical  
**Typical impact:** Group Policy and logon scripts fail; new or restored domain controllers may not advertise correctly.

## Symptoms

- `net share` does not list `SYSVOL` or `NETLOGON`.
- `dcdiag /test:advertising` fails.
- Event Viewer shows DFS Replication or Netlogon errors.
- Clients report Group Policy processing failures.
- A newly promoted DC remains in initial synchronization.

## Likely causes

- DFSR initial synchronization has not completed.
- The DC cannot contact an upstream replication partner.
- DNS, RPC, firewall, time or secure-channel problems block replication.
- SYSVOL migration state is inconsistent.
- DFSR database or local configuration is damaged.

## Diagnostic workflow

```powershell
Get-Service DFSR,Netlogon
Get-SmbShare -Name SYSVOL,NETLOGON -ErrorAction SilentlyContinue
dcdiag /test:advertising /test:sysvolcheck /v
repadmin /replsummary
repadmin /showrepl

dfsrmig /getglobalstate
dfsrmig /getmigrationstate
```

Review:

```text
Applications and Services Logs
└─ DFS Replication

Windows Logs
└─ System
└─ Directory Service
```

Important DFSR events include 2213, 4012, 4114, 4602 and 4604.

## Resolution

1. Fix DNS, time, RPC and AD replication before changing SYSVOL.
2. Confirm the DC has a healthy replication partner.
3. Restart Netlogon only after DFSR reports successful SYSVOL initialization.
4. For a single unhealthy non-authoritative DC, use the supported non-authoritative SYSVOL recovery process.
5. For forest-wide recovery, designate exactly one authoritative SYSVOL source and follow Microsoft recovery guidance.

> [!CAUTION]
> Do not manually share SYSVOL or NETLOGON to hide an underlying DFSR problem. Do not copy SYSVOL files manually between DCs as a substitute for supported recovery.

## Verification

```powershell
Get-SmbShare -Name SYSVOL,NETLOGON
dcdiag /test:advertising /test:sysvolcheck
repadmin /replsummary
```

Confirm that a test GPO appears consistently in every DC's SYSVOL and applies to a test client.

## Prevention

- Maintain at least two healthy DNS-enabled DCs per production domain.
- Monitor DFSR and replication event logs.
- Verify system-state backups.
- Never revert a DC by unsupported hypervisor snapshot methods.

---

# AD-022 — Event ID 2213 pauses DFSR replication

**Category:** SYSVOL / DFSR  
**Severity:** High

## Overview

DFSR Event ID 2213 indicates that replication was paused after an unexpected shutdown or dirty database recovery. Depending on the operating system and configuration, administrator action may be required to resume replication.

## Symptoms

- Event ID 2213 appears in the DFS Replication log.
- SYSVOL changes do not replicate.
- Replication backlog grows.
- GPO versions differ between DCs.

## Diagnostics

```powershell
Get-WinEvent -FilterHashtable @{LogName='DFS Replication'; Id=2213} -MaxEvents 20 |
    Select-Object TimeCreated, MachineName, Message

repadmin /replsummary

dfsrdiag backlog /rgname:'Domain System Volume' /rfname:'SYSVOL Share' `
  /smem:SOURCE-DC /rmem:DESTINATION-DC
```

Read the event message carefully and capture the volume GUID before taking action.

## Resolution

Use the WMI resume command specified in the event message, substituting the affected volume GUID:

```powershell
wmic /namespace:\\root\microsoftdfs path dfsrReplicatedFolderInfo `
  where "state=5" get replicationgroupname,replicatedfoldername,state
```

On systems where Event 2213 explicitly provides the resume command, run the exact generated command from the event after confirming storage health and obtaining approval.

Then restart or poll DFSR:

```powershell
Restart-Service DFSR

dfsrdiag pollad
```

> [!WARNING]
> Resuming DFSR without investigating repeated unexpected shutdowns, disk errors or storage instability can lead to recurring incidents.

## Verification

- Confirm a DFSR recovery/resume event is logged.
- Confirm the backlog decreases.
- Confirm SYSVOL and GPO versions match across DCs.

---

# AD-023 — Duplicate SPN causes Kerberos failure

**Category:** Authentication  
**Severity:** High

## Symptoms

- `KRB_AP_ERR_MODIFIED` appears in logs or application errors.
- Users receive repeated credential prompts.
- Kerberos authentication fails while NTLM may still work.
- SQL Server, IIS, SMB or service accounts fail after a migration or account change.

## Root cause

A Service Principal Name must uniquely identify the account that owns a service. Duplicate SPNs cause the KDC to issue a ticket encrypted for the wrong account.

## Diagnostics

```powershell
setspn -X
setspn -Q HTTP/app01.contoso.com
setspn -Q MSSQLSvc/sql01.contoso.com:1433

Get-ADObject -LDAPFilter '(servicePrincipalName=HTTP/app01.contoso.com)' `
  -Properties servicePrincipalName |
  Select-Object Name,DistinguishedName,servicePrincipalName
```

Also confirm:

- The application actually runs under the expected account.
- DNS aliases and load-balancer names have corresponding SPNs.
- The service account password is synchronized across all service instances.

## Resolution

Remove only the incorrect duplicate and then add the SPN to the correct account using duplicate-safe syntax:

```powershell
setspn -D HTTP/app01.contoso.com CONTOSO\WrongAccount
setspn -S HTTP/app01.contoso.com CONTOSO\CorrectServiceAccount
```

Purge cached tickets on a test client:

```powershell
klist purge
```

Restart the affected service if required.

## Verification

```powershell
setspn -Q HTTP/app01.contoso.com
klist
```

Confirm the service ticket is issued for the expected SPN and authentication succeeds without falling back to NTLM.

## Prevention

- Use `setspn -S`, not `setspn -A`.
- Document service-account ownership.
- Scan for duplicate SPNs regularly.
- Prefer group Managed Service Accounts where supported.

---

# AD-024 — Time service hierarchy is incorrect

**Category:** Authentication / Time  
**Severity:** Critical

## Expected hierarchy

```text
External reliable NTP source
        ↓
Forest-root PDC Emulator
        ↓
Other domain controllers
        ↓
Domain members
```

## Symptoms

- Kerberos errors caused by excessive clock skew.
- Event IDs 12, 36, 47 or 50 from Time-Service.
- DCs use the local CMOS clock or an unsuitable internet source.
- Virtualized DCs drift or switch between host time and domain time.

## Diagnostics

```powershell
w32tm /query /status
w32tm /query /source
w32tm /query /configuration
w32tm /monitor

Get-ADDomain | Select-Object PDCEmulator
```

## Resolution

Configure only the forest-root PDC Emulator with approved external NTP peers:

```powershell
w32tm /config /manualpeerlist:'0.au.pool.ntp.org,0x8 1.au.pool.ntp.org,0x8' `
  /syncfromflags:manual /reliable:yes /update
Restart-Service W32Time
w32tm /resync /rediscover
```

Configure other domain members to follow the domain hierarchy:

```powershell
w32tm /config /syncfromflags:domhier /update
Restart-Service W32Time
w32tm /resync /rediscover
```

> [!NOTE]
> Use NTP sources approved by your organization. Ensure UDP 123 is allowed and disable conflicting hypervisor time synchronization for virtualized DCs when required by your platform design.

## Verification

```powershell
w32tm /query /source
w32tm /query /status
w32tm /monitor
```

Confirm that non-PDC systems trace back through the domain hierarchy and that the PDC uses the approved source.

---

# AD-025 — DNS scavenging deletes required records

**Category:** DNS  
**Severity:** High

## Symptoms

- Valid hosts intermittently disappear from DNS.
- Applications fail after the scavenging cycle.
- Static servers or appliances lose A/PTR records.
- Domain Controller locator records disappear and later re-register.

## Root causes

- A static record was created as dynamic and aged.
- No-refresh and refresh intervals are too aggressive.
- DHCP ownership and DNS update credentials are misconfigured.
- Multiple DHCP servers update records inconsistently.
- Scavenging is enabled without understanding record timestamps.

## Diagnostics

```powershell
Get-DnsServerScavenging
Get-DnsServerZoneAging -Name 'contoso.com'
Get-DnsServerResourceRecord -ZoneName 'contoso.com' |
  Select-Object HostName,RecordType,Timestamp
```

Export current records before changing aging settings:

```powershell
Export-DnsServerZone -Name 'contoso.com' -FileName 'contoso-before-scavenging.dns'
```

## Resolution

- Restore required records and mark true infrastructure records as static where appropriate.
- Align DHCP lease duration with DNS no-refresh and refresh intervals.
- Use dedicated DHCP DNS-update credentials.
- Enable scavenging on a controlled subset of DNS servers, not indiscriminately everywhere.
- Investigate why DC records are not refreshing instead of merely recreating them.

Example zone-aging configuration:

```powershell
Set-DnsServerZoneAging -Name 'contoso.com' -Aging $true `
  -NoRefreshInterval 7.00:00:00 -RefreshInterval 7.00:00:00
```

> [!CAUTION]
> Scavenging changes can remove large numbers of records. Back up the zone, understand timestamps, and use conservative intervals.

## Verification

```powershell
Resolve-DnsName _ldap._tcp.dc._msdcs.contoso.com -Type SRV
Resolve-DnsName app01.contoso.com
```

Confirm required A, AAAA, PTR and SRV records survive subsequent aging and scavenging cycles.

---

## Related tools

- [`Test-ADCoreServices.ps1`](../../scripts/health-check/Test-ADCoreServices.ps1)
- [`Find-DuplicateSPN.ps1`](../../scripts/kerberos/Find-DuplicateSPN.ps1)
- [`Get-ADTimeHealth.ps1`](../../scripts/health-check/Get-ADTimeHealth.ps1)
- [`Get-DnsAgingReport.ps1`](../../scripts/dns/Get-DnsAgingReport.ps1)

[Back to scenario index](../SCENARIO-INDEX.md) · [Back to README](../../README.md)
