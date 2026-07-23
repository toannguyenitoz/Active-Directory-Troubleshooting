# AD-026 to AD-030 — Replication and Group Policy

> Practical guidance for diagnosing replication errors and Group Policy failures in Active Directory. Validate every change in a lab and maintain verified backups.

## Navigation

- [AD-026 — Replication fails with error 1722](#ad-026--replication-fails-with-error-1722)
- [AD-027 — Replication fails with error 8453](#ad-027--replication-fails-with-error-8453)
- [AD-028 — Tombstone lifetime exceeded](#ad-028--tombstone-lifetime-exceeded)
- [AD-029 — GPO shows access denied](#ad-029--gpo-shows-access-denied)
- [AD-030 — WMI filter prevents GPO application](#ad-030--wmi-filter-prevents-gpo-application)

---

# AD-026 — Replication fails with error 1722

**Error:** `1722 — The RPC server is unavailable`  
**Category:** Replication / Networking  
**Severity:** Critical

## Symptoms

- `repadmin /replsummary` reports error 1722.
- `dcdiag` reports RPC connectivity failures.
- AD, DNS or SYSVOL changes do not reach one or more DCs.
- Event IDs 1311, 1865, 1925 or 2087 may appear.

## Likely causes

- Incorrect DNS resolution between DCs.
- TCP 135 or dynamic RPC ports blocked.
- RPC Endpoint Mapper, NTDS, Netlogon or related services unavailable.
- Broken routing, VPN, MTU or stateful firewall behavior.
- Stale DC metadata or unreachable replication partner.

## Diagnostic workflow

```powershell
Resolve-DnsName dc02.contoso.com
Test-NetConnection dc02.contoso.com -Port 135
Test-NetConnection dc02.contoso.com -Port 389
Test-NetConnection dc02.contoso.com -Port 445

repadmin /replsummary
repadmin /showrepl dc01 /all /verbose
repadmin /bind dc02

dcdiag /test:dns /v
dcdiag /test:connectivity /v
```

Check service state:

```powershell
Get-Service RpcSs,NTDS,Netlogon,DNS,DFSR
```

## Resolution

1. Correct DC DNS client settings so DCs use internal AD DNS servers only.
2. Remove stale or incorrect DNS records.
3. Permit TCP 135 and the supported dynamic RPC range between DCs.
4. Repair routing, VPN or firewall state issues.
5. Restart only the affected service after identifying the cause.
6. If the partner DC is permanently gone, perform metadata cleanup rather than repeatedly forcing replication.

## Verification

```powershell
repadmin /syncall /AdeP
repadmin /replsummary
dcdiag /test:replications
```

> [!WARNING]
> `repadmin /syncall` does not repair DNS, firewall or RPC failures. Use it only after connectivity has been restored.

---

# AD-027 — Replication fails with error 8453

**Error:** `8453 — Replication access was denied`  
**Category:** Replication / Security  
**Severity:** High

## Symptoms

- `repadmin` reports 8453.
- A newly promoted or restored DC cannot replicate.
- Replication works in one direction but not the other.
- Errors appear after permission hardening, restore or metadata changes.

## Likely causes

- Broken DC secure channel or machine-account password mismatch.
- Missing replication rights on a naming context.
- The command is run without sufficient privileges.
- Stale metadata or duplicate DC object.
- Time or Kerberos problems prevent authenticated replication.

## Diagnostics

```powershell
repadmin /showrepl * /errorsonly
repadmin /showobjmeta dc01 'CN=NTDS Settings,CN=DC01,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com'

nltest /sc_verify:contoso.com
w32tm /monitor
klist
```

Confirm the DC computer account exists in the `Domain Controllers` OU and that the NTDS Settings object is linked to the correct server object.

## Resolution

- Run diagnostics using an account delegated for the required operation.
- Correct time and DNS first.
- Repair the DC secure channel using supported domain-controller procedures.
- Restore removed replication permissions only from a known-good baseline.
- Clean stale metadata if an old DC identity conflicts with the current one.

> [!CAUTION]
> Do not grant broad permissions such as Full Control on the domain root merely to clear error 8453.

## Verification

```powershell
repadmin /syncall /AdeP
repadmin /showrepl * /errorsonly
dcdiag /test:replications
```

---

# AD-028 — Tombstone lifetime exceeded

**Category:** Replication / Recovery  
**Severity:** Critical

## Overview

A DC that has not replicated for longer than the tombstone lifetime can reintroduce objects that other DCs have permanently deleted. Active Directory therefore blocks unsafe replication in several conditions.

## Symptoms

- Replication is blocked after a DC has been offline for an extended period.
- Event ID 2042 appears.
- Lingering-object warnings appear.
- `repadmin` reports prolonged replication failure.

## Diagnostics

```powershell
Get-ADObject 'CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=contoso,DC=com' `
  -Properties tombstoneLifetime |
  Select-Object tombstoneLifetime

repadmin /showrepl * /csv
repadmin /showvector /latency dc01 'DC=contoso,DC=com'
```

Determine:

- The last successful replication time.
- Whether the DC contains unique data or roles.
- Whether system-state backups are available and valid.
- Whether virtualization rollback or unsupported restore occurred.

## Resolution options

### Preferred: demote and rebuild

For a DC offline beyond tombstone lifetime, the safest normal approach is:

1. Transfer or seize any required FSMO role after confirming the original holder will not return.
2. Remove the stale DC from service.
3. Perform metadata and DNS cleanup.
4. Build and promote a fresh server.

### Lingering-object cleanup

Use `repadmin /removelingeringobjects` only after identifying an authoritative clean reference DC and following a documented cleanup plan.

> [!DANGER]
> Do not disable replication safeguards merely to make replication run. This can spread lingering or inconsistent objects throughout the forest.

## Verification

```powershell
repadmin /replsummary
repadmin /showrepl * /errorsonly
dcdiag /e /test:replications
```

---

# AD-029 — GPO shows access denied

**Category:** Group Policy / Delegation  
**Severity:** Medium to High

## Symptoms

- `gpresult` shows a GPO denied due to security filtering.
- Group Policy processing logs show access denied.
- Users or computers can read the GPO inconsistently.
- The GPO works for administrators but not standard users.

## Likely causes

- `Authenticated Users` was removed without equivalent Read permission.
- The target lacks both Read and Apply Group Policy.
- A Deny ACE overrides an Allow ACE.
- SYSVOL NTFS permissions differ from the AD GPO object's permissions.
- The user or computer token has not refreshed after group membership changes.

## Diagnostics

```powershell
gpresult /h C:\Temp\GPResult.html
gpresult /r

Get-GPO -All | Select-Object DisplayName,Id,GpoStatus
Get-GPPermission -Name 'Workstation Baseline' -All
```

Check the operational log:

```text
Applications and Services Logs
└─ Microsoft
   └─ Windows
      └─ GroupPolicy
         └─ Operational
```

Validate access to both:

- AD object: `CN={GPO-GUID},CN=Policies,CN=System,...`
- SYSVOL path: `\\contoso.com\SYSVOL\contoso.com\Policies\{GPO-GUID}`

## Resolution

- Grant the target group `Read` and `Apply Group Policy`.
- If removing `Authenticated Users` from security filtering, preserve required Read access for policy processing.
- Remove unintended Deny entries.
- Restore default GPO permissions using a known-good baseline or supported tools.
- Correct SYSVOL ACLs only after confirming replication health.

## Verification

```powershell
gpupdate /force
gpresult /h C:\Temp\GPResult-After.html
```

Confirm the GPO appears under Applied Group Policy Objects and no longer reports access denied.

---

# AD-030 — WMI filter prevents GPO application

**Category:** Group Policy / WMI  
**Severity:** Medium

## Symptoms

- A GPO is denied because its WMI filter evaluates to false.
- Policy processing is slow.
- A filter works on one Windows version but not another.
- WMI errors appear in the GroupPolicy operational log.

## Likely causes

- Incorrect namespace or WQL syntax.
- Product-version matching uses unreliable string comparisons.
- The queried WMI class does not exist on the target.
- WMI repository or provider is unhealthy.
- The query is too broad or expensive.

## Diagnostics

Identify the linked filter:

```powershell
Get-GPO -Name 'Workstation Baseline' | Select-Object DisplayName,WmiFilter
```

Test the query locally on an affected computer:

```powershell
Get-CimInstance -Namespace root\cimv2 -Query `
  "SELECT * FROM Win32_OperatingSystem WHERE ProductType = 1"
```

Check WMI health:

```powershell
Get-Service Winmgmt
winmgmt /verifyrepository
```

Review Group Policy Operational events for filter evaluation time and result.

## Resolution

- Correct the namespace, class, property or WQL condition.
- Prefer simple, indexed properties and narrow result sets.
- Avoid using `Win32_Product`; it is slow and can trigger MSI consistency checks.
- Remove unnecessary WMI filters and use security filtering or item-level targeting when more appropriate.
- Repair WMI only when diagnostics confirm repository or provider corruption.

Example workstation filter:

```sql
SELECT * FROM Win32_OperatingSystem WHERE ProductType = 1
```

Example Windows 11 filter using build number:

```sql
SELECT * FROM Win32_OperatingSystem WHERE ProductType = 1 AND BuildNumber >= "22000"
```

> [!NOTE]
> WQL string comparisons can produce unexpected results. Test filters against every supported operating-system version.

## Verification

```powershell
gpupdate /force
gpresult /h C:\Temp\WMI-Filter-Test.html
```

Confirm the filter evaluates true on intended targets, false elsewhere, and completes without excessive delay.

---

## Related tools

- [`Test-ADReplication.ps1`](../../scripts/replication/Test-ADReplication.ps1)
- [`Get-GPOHealthReport.ps1`](../../scripts/reporting/Get-GPOHealthReport.ps1)

[Back to scenario index](../SCENARIO-INDEX.md) · [Back to README](../../README.md)
