# AD-017 to AD-020 — Password Policy, RPC, DC Locator, and Lingering Objects

## AD-017 — Fine-Grained Password Policy Ignored

### Symptoms
A user receives the default domain password policy rather than the expected Password Settings Object (PSO).

### Diagnose
```powershell
Get-ADUserResultantPasswordPolicy username
Get-ADFineGrainedPasswordPolicy -Filter *
Get-ADFineGrainedPasswordPolicySubject -Identity 'PSO-Helpdesk'
```
PSOs apply directly to users or global security groups, not OUs. If several apply, the lowest precedence value wins; a directly assigned PSO has priority over group-derived PSOs.

### Resolve
Assign the PSO to the correct user or global group, correct group scope/membership, fix precedence, and confirm replication. A GPO linked to an OU does not define the password policy for domain accounts.

### Verify
Run `Get-ADUserResultantPasswordPolicy` and test with a controlled non-production account.

---

## AD-018 — RPC Server Unavailable

### Symptoms
Replication, WMI, remote administration, GPO processing, or DC promotion fails with error 1722.

### Diagnose
```powershell
Test-NetConnection dc02 -Port 135
Resolve-DnsName dc02.contoso.com
```
Use `repadmin /showrepl` to identify the failing direction and partner. Check Windows Firewall, network ACLs, TCP 135, dynamic RPC ports, DNS, routing, IPsec, endpoint security, required services, and packet loss.

### Resolve
Restore correct name resolution and bidirectional connectivity. Permit TCP 135 and the approved dynamic RPC range only between required systems. Remove stale DNS records and start failed services after identifying why they stopped.

### Verify
Repeat port tests, run `repadmin /syncall /AdeP`, and retry the original operation.

---

## AD-019 — Client Cannot Locate a Domain Controller

### Symptoms
Domain join fails, logon is slow, “No logon servers” appears, or the client selects a remote DC.

### Diagnose
```cmd
ipconfig /all
nltest /dsgetdc:contoso.com /force
nltest /dsgetsite
```
```powershell
Resolve-DnsName _ldap._tcp.dc._msdcs.contoso.com -Type SRV
```
Check client DNS, DHCP options 006/015, DNS suffixes, SRV/A records, AD Sites and Services subnet mapping, VPN DNS behavior, firewall rules, and DC advertising.

### Resolve
Point clients only to internal AD DNS, correct DHCP/VPN settings, create missing subnets, repair DC DNS registration, and remove stale records.

### Verify
Flush DNS, rediscover the DC, confirm the expected site and DC, access SYSVOL, and test domain authentication.

---

## AD-020 — Lingering Objects After Restore

### Symptoms
Deleted objects reappear, replication is blocked, or Directory Service events 1988 or 2042 occur after a long outage or unsupported restore.

### Safety warning
Do not force replication before determining which DC contains authoritative, current data. Preserve logs and backups.

### Diagnose
Identify the healthy reference DC, affected naming context, object GUID, tombstone lifetime, and how long the suspect DC was offline.

```cmd
repadmin /showrepl
repadmin /replsummary
repadmin /removelingeringobjects <DestinationDC> <SourceDC-GUID> <NamingContext> /ADVISORY_MODE
```
Always use advisory mode first.

### Resolve
Remove lingering objects only with an approved procedure and a known-good reference DC. If confidence in the DC is low, demote and rebuild it instead of attempting high-risk cleanup. Never reconnect a DC that exceeded tombstone lifetime without assessment.

### Verify
Run advisory mode again, confirm clean replication, inspect Directory Service logs, and compare critical objects across DCs.

### Prevention
Alert on long replication gaps, retire failed DCs promptly, use supported virtualization restore, and test disaster-recovery procedures.

[Back to scenario index](../SCENARIO-INDEX.md)