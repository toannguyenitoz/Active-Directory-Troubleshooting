# AD-009 to AD-012 — Database, LDAP, Lockout, and Delegation

## AD-009 — NTDS.dit Database Growing Too Large

### Symptoms
The database consumes unusual disk space, backup windows increase, or the DC approaches low disk capacity.

### Diagnose
```powershell
Get-Item C:\Windows\NTDS\ntds.dit
Get-Volume
```
Review object churn, bulk imports/deletions, lingering objects, excessive attribute use, and Directory Service events. Online defragmentation reuses internal free pages but does not shrink the file.

### Resolve
Prefer capacity expansion or rebuilding a healthy replica when risk is high. Offline compaction requires DSRM, verified System State backup, adequate temporary space, and a rollback plan. Use `ntdsutil files compact to <path>` only during an approved maintenance window.

### Verify
Confirm database integrity, free space, successful replication, and a successful System State backup.

---

## AD-010 — LDAP Queries Timing Out

### Symptoms
Applications authenticate slowly, searches time out, or DC CPU rises during application activity.

### Diagnose
```powershell
Test-NetConnection dc01 -Port 389
Test-NetConnection dc01 -Port 636
```
Use `ldp.exe`, application logs, Performance Monitor, and event 1644 diagnostic logging with care. Review search base, filter, returned attributes, paging, indexes, referrals, GC usage, signing, channel binding, and certificates.

### Resolve
Optimize filters, request only necessary attributes, enable paging, query the correct naming context or Global Catalog, and add sane retry/timeout behavior. Correct LDAPS certificate or LDAP signing/channel-binding incompatibilities rather than disabling security globally.

### Verify
Measure response time, DC CPU, event 1644 volume, and application success under normal load.

---

## AD-011 — Repeated Account Lockouts

### Symptoms
A user locks again shortly after unlock or password reset.

### Diagnose
Review Security event 4740 on the PDC Emulator and note Caller Computer Name. Also inspect 4771 and 4776.

```powershell
Search-ADAccount -LockedOut
Get-ADUser username -Properties LockedOut,BadPwdCount,LastBadPasswordAttempt
```
Check scheduled tasks, services, mapped drives, saved RDP credentials, mobile devices, VPN clients, Credential Manager, scripts, and disconnected sessions.

### Resolve
Update or remove the stale credential at its source. Unlock the account only after correcting the source. Treat unknown or distributed attempts as a possible security incident.

### Verify
Monitor new 4740 events and bad-password counts for an agreed observation period.

---

## AD-012 — Organizational Unit Permission Issues

### Symptoms
Delegated administrators receive Access Denied, cannot perform expected tasks, or can modify more objects than intended.

### Diagnose
Enable Advanced Features in ADUC and review Security, Effective Access, inheritance, protected objects, deny ACEs, nested groups, and AdminSDHolder.

```cmd
dsacls "OU=Users,DC=contoso,DC=com"
```
Use a dedicated test account to reproduce the exact operation.

### Resolve
Delegate the minimum required tasks to role-based groups at the correct OU. Avoid broad Full Control and direct user ACEs. Understand `adminCount` and AdminSDHolder before changing permissions on protected accounts.

### Verify
Test both expected allowed operations and expected denied operations, then confirm replication of the ACL.

[Back to scenario index](../SCENARIO-INDEX.md)