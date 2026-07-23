# Active Directory Troubleshooting Scenario Index

This index tracks practical troubleshooting articles planned for the repository.

| ID | Scenario | Category | Status |
|---:|---|---|---|
| AD-001 | Domain Controller will not boot | Domain Controllers | Planned |
| AD-002 | Kerberos logon failures | Authentication | Planned |
| AD-003 | Active Directory replication failures | Replication | Planned |
| AD-004 | Missing DNS SRV records | DNS | Planned |
| AD-005 | Group Policy not applying | Group Policy | Planned |
| AD-006 | FSMO role holder unreachable | FSMO | Planned |
| AD-007 | SYSVOL not replicating with DFSR | SYSVOL / DFSR | Planned |
| AD-008 | Secure channel or trust relationship failure | Authentication | Planned |
| AD-009 | NTDS.dit database growing too large | Database | Planned |
| AD-010 | LDAP queries timing out | LDAP | Planned |
| AD-011 | Repeated account lockouts | Security | Planned |
| AD-012 | Organizational Unit permission issues | Delegation | Planned |
| AD-013 | Kerberos errors caused by clock skew | Authentication | Planned |
| AD-014 | AD Recycle Bin restore failure | Recovery | Planned |
| AD-015 | High LSASS CPU usage | Performance | Planned |
| AD-016 | New Domain Controller promotion failure | Domain Controllers | Planned |
| AD-017 | Fine-Grained Password Policy ignored | Security | Planned |
| AD-018 | RPC Server Unavailable | Networking | Planned |
| AD-019 | Client cannot locate a Domain Controller | DNS / Locator | Planned |
| AD-020 | Lingering objects after restore | Replication | Planned |
| AD-021 | SYSVOL and NETLOGON shares missing | SYSVOL / DFSR | Backlog |
| AD-022 | Event ID 2213 pauses DFSR replication | SYSVOL / DFSR | Backlog |
| AD-023 | Duplicate SPN causes Kerberos failure | Authentication | Backlog |
| AD-024 | Time service hierarchy is incorrect | Authentication | Backlog |
| AD-025 | DNS scavenging deletes required records | DNS | Backlog |
| AD-026 | Replication fails with error 1722 | Replication | Backlog |
| AD-027 | Replication fails with error 8453 | Replication | Backlog |
| AD-028 | Tombstone lifetime exceeded | Replication | Backlog |
| AD-029 | GPO shows access denied | Group Policy | Backlog |
| AD-030 | WMI filter prevents GPO application | Group Policy | Backlog |
| AD-031 | Loopback processing behaves unexpectedly | Group Policy | Backlog |
| AD-032 | Password changes do not replicate quickly | Replication | Backlog |
| AD-033 | RODC password caching failure | Domain Controllers | Backlog |
| AD-034 | Domain trust validation fails | Trusts | Backlog |
| AD-035 | Global Catalog unavailable | Domain Controllers | Backlog |
| AD-036 | Universal group membership not updating | Replication | Backlog |
| AD-037 | AD-integrated DNS zone not replicating | DNS | Backlog |
| AD-038 | Deleted object cannot be recovered | Recovery | Backlog |
| AD-039 | USN rollback detected | Recovery | Backlog |
| AD-040 | Domain Controller snapshot rollback | Recovery | Backlog |
| AD-041 | KCC topology generation errors | Replication | Backlog |
| AD-042 | Site and subnet mapping is incorrect | Sites and Services | Backlog |
| AD-043 | Clients authenticate against a remote site | Sites and Services | Backlog |
| AD-044 | Authentication fails after machine password mismatch | Authentication | Backlog |
| AD-045 | LDAP signing requirement breaks an application | LDAP | Backlog |
| AD-046 | LDAP channel binding compatibility issue | LDAP | Backlog |
| AD-047 | Expensive LDAP query affects DC performance | Performance | Backlog |
| AD-048 | RID pool exhaustion warning | FSMO | Backlog |
| AD-049 | PDC Emulator time synchronization failure | FSMO | Backlog |
| AD-050 | Schema extension fails | Schema | Backlog |

## Standard article format

Every scenario should contain:

1. Overview
2. Symptoms
3. Business impact
4. Likely causes
5. Prerequisites and safety checks
6. Diagnostic workflow
7. Commands and expected results
8. Resolution options
9. Verification
10. Prevention
11. Relevant event IDs
12. References

[Back to README](../README.md)
