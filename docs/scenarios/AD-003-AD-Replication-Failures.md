# AD-003 — Active Directory Replication Failures

## Overview
AD replication keeps directory partitions consistent across domain controllers. Failures can cause stale passwords, missing users/groups, inconsistent GPOs, authentication failures, and unreliable disaster recovery.

## Symptoms
- `repadmin /replsummary` reports failures.
- Changes appear on one DC but not another.
- Event IDs 1311, 1566, 1865, 1925, 2042, or 2087 appear.
- Password changes work against one DC only.

## Likely causes
DNS misconfiguration, blocked RPC, broken site topology, time skew, authentication failure, lingering objects, tombstone lifetime exceeded, or a failed DC that was not cleaned up.

## Diagnostic workflow
```cmd
repadmin /replsummary
repadmin /showrepl * /csv > showrepl.csv
repadmin /queue
repadmin /bridgeheads
repadmin /kcc *
dcdiag /test:replications /v
```
Confirm DC DNS settings point only to internal AD DNS servers. Test connectivity:
```powershell
Test-NetConnection dc02 -Port 135
Resolve-DnsName _ldap._tcp.dc._msdcs.contoso.com -Type SRV
```
Review Directory Service, DFS Replication, DNS Server, and System logs. Identify the first error rather than treating all downstream failures separately.

## Resolution
- Correct DNS client settings and stale records.
- Restore RPC/firewall connectivity, including TCP 135 and dynamic RPC ports.
- Force topology recalculation only after the root cause is fixed:
```cmd
repadmin /kcc dc01
repadmin /syncall /AdeP
```
- Remove metadata for permanently failed DCs.
- Do not force replication from a DC with Event 2042 until lingering-object and tombstone risks are assessed.

## Verification
```cmd
repadmin /replsummary
repadmin /showrepl
dcdiag /test:replications
```
Create a temporary test object and confirm it appears on all writable DCs.

## Prevention
Monitor replication daily, define sites/subnets correctly, keep DNS healthy, avoid unsupported snapshot rollback, and maintain tested System State backups.

[Back to scenario index](../SCENARIO-INDEX.md)