# AD-002 — Kerberos Logon Failures

## Overview
Kerberos is the preferred authentication protocol in an Active Directory domain. A failure may affect interactive logon, SMB, SQL Server, IIS, WinRM, scheduled tasks, or applications that depend on integrated Windows authentication.

## Symptoms and impact
- Users repeatedly receive credential prompts.
- Access works by IP address but fails by host name.
- `KRB_AP_ERR_MODIFIED`, `KDC_ERR_S_PRINCIPAL_UNKNOWN`, or `KDC_ERR_PREAUTH_FAILED` appears.
- NTLM is used unexpectedly.
- Services fail after a password or service-account change.

## Likely causes
- Duplicate, missing, or incorrect SPNs.
- Client/DC/service time differs by more than the Kerberos tolerance.
- DNS resolves a service name to the wrong host.
- Service account password does not match the configured service.
- Ticket cache contains stale tickets.
- Account encryption settings are incompatible.

## Safety checks
Do not delete SPNs or reset service-account passwords without confirming all dependent services, clusters, scheduled tasks, and application pools.

## Diagnostic workflow
### 1. Confirm DNS and DC discovery
```powershell
Resolve-DnsName dc01.contoso.com
nltest /dsgetdc:contoso.com
```

### 2. Confirm time
```cmd
w32tm /query /status
w32tm /stripchart /computer:dc01.contoso.com /samples:5 /dataonly
```

### 3. Inspect tickets
```cmd
klist
klist purge
```
Reproduce the problem and run `klist` again.

### 4. Validate SPNs
```cmd
setspn -Q HTTP/app.contoso.com
setspn -X
setspn -L CONTOSO\svc-web
```
A production SPN should normally exist once and on the identity that actually runs the service.

### 5. Review logs
Check **System**, **Security**, and **Microsoft-Windows-Kerberos-Key-Distribution-Center/Operational**. Useful events include 4, 7, 11, 14, 16, 27, 4768, 4769, and 4771.

## Resolution options
- Correct DNS records and aliases.
- Remove a duplicate SPN only after identifying the valid owner:
```cmd
setspn -D HTTP/app.contoso.com CONTOSO\wrong-account
setspn -S HTTP/app.contoso.com CONTOSO\svc-web
```
- Restart the service after correcting its account password.
- Restore domain time hierarchy; the forest-root PDC Emulator should use a reliable external source.
- Purge tickets or sign out after changes.
- Review `msDS-SupportedEncryptionTypes` before changing encryption policy.

## Verification
```cmd
klist get HTTP/app.contoso.com
setspn -Q HTTP/app.contoso.com
```
Confirm the service ticket is issued for the expected SPN and that authentication no longer falls back to NTLM.

## Prevention
Use group Managed Service Accounts where supported, monitor duplicate SPNs, document aliases, maintain DNS hygiene, and monitor time drift.

[Back to scenario index](../SCENARIO-INDEX.md)