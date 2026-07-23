# AD-013 to AD-016 — Time, Recovery, Performance, and DC Promotion

## AD-013 — Kerberos Errors Caused by Clock Skew

### Symptoms
Kerberos authentication fails, tickets are invalid, or event messages report a time difference.

### Diagnose
```cmd
w32tm /query /status
w32tm /query /source
w32tm /query /configuration
w32tm /monitor
```
Confirm domain members use the domain hierarchy and the forest-root PDC Emulator uses an approved reliable external source. Check hypervisor time integration and third-party time agents.

### Resolve
For domain members/DCs:
```cmd
w32tm /config /syncfromflags:domhier /update
w32tm /resync /rediscover
```
Configure external peers only on the designated PDC Emulator according to organizational standards.

### Verify
Compare offsets, confirm the expected source, purge stale Kerberos tickets if needed, and retest authentication.

---

## AD-014 — AD Recycle Bin Restore Failure

### Symptoms
Deleted objects cannot be found, restore fails, or a restored object lacks links or memberships.

### Diagnose
```powershell
Get-ADOptionalFeature 'Recycle Bin Feature'
Get-ADObject -Filter 'isDeleted -eq $true' -IncludeDeletedObjects -Properties *
```
Confirm Recycle Bin was enabled before deletion. Check deleted-object lifetime, tombstone lifetime, parent OU existence, permissions, and whether garbage collection has removed the object.

### Resolve
Restore deleted parent containers first when necessary:
```powershell
Restore-ADObject -Identity '<object-guid>'
```
If the object is no longer recoverable, use an approved authoritative System State restore or recreate it from documented configuration.

### Verify
Confirm attributes, group memberships, ACLs, application mappings, replication, and logon.

---

## AD-015 — High LSASS CPU Usage

### Symptoms
A DC becomes slow, authentication latency rises, or `lsass.exe` consumes sustained CPU.

### Diagnose
Collect Performance Monitor counters for Processor, NTDS, LDAP, Kerberos, memory, and network. Review expensive LDAP queries, authentication storms, retry loops, endpoint security integrations, replication problems, and recent changes. Never terminate LSASS.

Useful evidence includes Directory Service event 1644, application connection logs, process dumps collected under an approved support procedure, and a before/after performance baseline.

### Resolve
Optimize abusive LDAP clients, stop retry storms, patch supported defects, update security software with vendor guidance, and distribute authentication load across healthy DCs. Reboot only after evidence capture and confirmation of failover capacity.

### Verify
Compare CPU, LDAP latency, authentication rate, queues, and user impact before and after remediation.

---

## AD-016 — New Domain Controller Promotion Failure

### Symptoms
Server Manager or `Install-ADDSDomainController` fails during prerequisite checks, replication, DNS setup, or reboot.

### Diagnose
Validate OS support, static IP, internal DNS, time, credentials, site/subnet mapping, functional levels, replication health, disk space, and required ports.

```cmd
dcdiag /e /v
repadmin /replsummary
nltest /dsgetdc:contoso.com
```
Review `C:\Windows\debug\DCPROMO.LOG`, `DCPROMOUI.LOG`, and relevant event logs.

### Resolve
Correct the earliest prerequisite or connectivity failure. Remove incomplete metadata only when the failed promotion created partial DC objects. Reattempt with explicit site, DNS, and replication-source settings when appropriate.

### Verify
Confirm advertising, SYSVOL/NETLOGON, DNS records, Global Catalog status if required, inbound/outbound replication, and backup completion.

[Back to scenario index](../SCENARIO-INDEX.md)