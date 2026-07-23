# Active Directory Troubleshooting Scenario Index

This index tracks practical troubleshooting articles in the repository.

## Phase 1 — Completed

| ID | Scenario | Category | Article | Status |
|---:|---|---|---|---|
| AD-001 | Domain Controller will not boot | Domain Controllers | [Open](scenarios/AD-001-Domain-Controller-Wont-Boot.md) | ✅ Complete |
| AD-002 | Kerberos logon failures | Authentication | [Open](scenarios/AD-002-Kerberos-Logon-Failures.md) | ✅ Complete |
| AD-003 | Active Directory replication failures | Replication | [Open](scenarios/AD-003-AD-Replication-Failures.md) | ✅ Complete |
| AD-004 | Missing DNS SRV records | DNS | [Open](scenarios/AD-004-to-AD-008-Core-Services.md#ad-004--missing-dns-srv-records) | ✅ Complete |
| AD-005 | Group Policy not applying | Group Policy | [Open](scenarios/AD-004-to-AD-008-Core-Services.md#ad-005--group-policy-not-applying) | ✅ Complete |
| AD-006 | FSMO role holder unreachable | FSMO | [Open](scenarios/AD-004-to-AD-008-Core-Services.md#ad-006--fsmo-role-holder-unreachable) | ✅ Complete |
| AD-007 | SYSVOL not replicating with DFSR | SYSVOL / DFSR | [Open](scenarios/AD-004-to-AD-008-Core-Services.md#ad-007--sysvol-not-replicating-with-dfsr) | ✅ Complete |
| AD-008 | Secure channel or trust relationship failure | Authentication | [Open](scenarios/AD-004-to-AD-008-Core-Services.md#ad-008--secure-channel-or-trust-relationship-failure) | ✅ Complete |
| AD-009 | NTDS.dit database growing too large | Database | [Open](scenarios/AD-009-to-AD-012-Database-LDAP-Security.md#ad-009--ntdsdit-database-growing-too-large) | ✅ Complete |
| AD-010 | LDAP queries timing out | LDAP | [Open](scenarios/AD-009-to-AD-012-Database-LDAP-Security.md#ad-010--ldap-queries-timing-out) | ✅ Complete |
| AD-011 | Repeated account lockouts | Security | [Open](scenarios/AD-009-to-AD-012-Database-LDAP-Security.md#ad-011--repeated-account-lockouts) | ✅ Complete |
| AD-012 | Organizational Unit permission issues | Delegation | [Open](scenarios/AD-009-to-AD-012-Database-LDAP-Security.md#ad-012--organizational-unit-permission-issues) | ✅ Complete |
| AD-013 | Kerberos errors caused by clock skew | Authentication | [Open](scenarios/AD-013-to-AD-016-Time-Recovery-Performance-Promotion.md#ad-013--kerberos-errors-caused-by-clock-skew) | ✅ Complete |
| AD-014 | AD Recycle Bin restore failure | Recovery | [Open](scenarios/AD-013-to-AD-016-Time-Recovery-Performance-Promotion.md#ad-014--ad-recycle-bin-restore-failure) | ✅ Complete |
| AD-015 | High LSASS CPU usage | Performance | [Open](scenarios/AD-013-to-AD-016-Time-Recovery-Performance-Promotion.md#ad-015--high-lsass-cpu-usage) | ✅ Complete |
| AD-016 | New Domain Controller promotion failure | Domain Controllers | [Open](scenarios/AD-013-to-AD-016-Time-Recovery-Performance-Promotion.md#ad-016--new-domain-controller-promotion-failure) | ✅ Complete |
| AD-017 | Fine-Grained Password Policy ignored | Security | [Open](scenarios/AD-017-to-AD-020-Policy-RPC-Locator-Lingering.md#ad-017--fine-grained-password-policy-ignored) | ✅ Complete |
| AD-018 | RPC Server Unavailable | Networking | [Open](scenarios/AD-017-to-AD-020-Policy-RPC-Locator-Lingering.md#ad-018--rpc-server-unavailable) | ✅ Complete |
| AD-019 | Client cannot locate a Domain Controller | DNS / Locator | [Open](scenarios/AD-017-to-AD-020-Policy-RPC-Locator-Lingering.md#ad-019--client-cannot-locate-a-domain-controller) | ✅ Complete |
| AD-020 | Lingering objects after restore | Replication | [Open](scenarios/AD-017-to-AD-020-Policy-RPC-Locator-Lingering.md#ad-020--lingering-objects-after-restore) | ✅ Complete |

## Phase 2 — In Progress

| ID | Scenario | Category | Article | Status |
|---:|---|---|---|---|
| AD-021 | SYSVOL and NETLOGON shares missing | SYSVOL / DFSR | [Open](scenarios/AD-021-to-AD-025-SYSVOL-SPN-Time-DNS.md#ad-021--sysvol-and-netlogon-shares-missing) | ✅ Complete |
| AD-022 | Event ID 2213 pauses DFSR replication | SYSVOL / DFSR | [Open](scenarios/AD-021-to-AD-025-SYSVOL-SPN-Time-DNS.md#ad-022--event-id-2213-pauses-dfsr-replication) | ✅ Complete |
| AD-023 | Duplicate SPN causes Kerberos failure | Authentication | [Open](scenarios/AD-021-to-AD-025-SYSVOL-SPN-Time-DNS.md#ad-023--duplicate-spn-causes-kerberos-failure) | ✅ Complete |
| AD-024 | Time service hierarchy is incorrect | Authentication | [Open](scenarios/AD-021-to-AD-025-SYSVOL-SPN-Time-DNS.md#ad-024--time-service-hierarchy-is-incorrect) | ✅ Complete |
| AD-025 | DNS scavenging deletes required records | DNS | [Open](scenarios/AD-021-to-AD-025-SYSVOL-SPN-Time-DNS.md#ad-025--dns-scavenging-deletes-required-records) | ✅ Complete |
| AD-026 | Replication fails with error 1722 | Replication | [Open](scenarios/AD-026-to-AD-030-Replication-and-Group-Policy.md#ad-026--replication-fails-with-error-1722) | ✅ Complete |
| AD-027 | Replication fails with error 8453 | Replication | [Open](scenarios/AD-026-to-AD-030-Replication-and-Group-Policy.md#ad-027--replication-fails-with-error-8453) | ✅ Complete |
| AD-028 | Tombstone lifetime exceeded | Replication | [Open](scenarios/AD-026-to-AD-030-Replication-and-Group-Policy.md#ad-028--tombstone-lifetime-exceeded) | ✅ Complete |
| AD-029 | GPO shows access denied | Group Policy | [Open](scenarios/AD-026-to-AD-030-Replication-and-Group-Policy.md#ad-029--gpo-shows-access-denied) | ✅ Complete |
| AD-030 | WMI filter prevents GPO application | Group Policy | [Open](scenarios/AD-026-to-AD-030-Replication-and-Group-Policy.md#ad-030--wmi-filter-prevents-gpo-application) | ✅ Complete |
| AD-031 | Loopback processing behaves unexpectedly | Group Policy | — | Backlog |
| AD-032 | Password changes do not replicate quickly | Replication | — | Backlog |
| AD-033 | RODC password caching failure | Domain Controllers | — | Backlog |
| AD-034 | Domain trust validation fails | Trusts | — | Backlog |
| AD-035 | Global Catalog unavailable | Domain Controllers | — | Backlog |
| AD-036 | Universal group membership not updating | Replication | — | Backlog |
| AD-037 | AD-integrated DNS zone not replicating | DNS | — | Backlog |
| AD-038 | Deleted object cannot be recovered | Recovery | — | Backlog |
| AD-039 | USN rollback detected | Recovery | — | Backlog |
| AD-040 | Domain Controller snapshot rollback | Recovery | — | Backlog |
| AD-041 | KCC topology generation errors | Replication | — | Backlog |
| AD-042 | Site and subnet mapping is incorrect | Sites and Services | — | Backlog |
| AD-043 | Clients authenticate against a remote site | Sites and Services | — | Backlog |
| AD-044 | Authentication fails after machine password mismatch | Authentication | — | Backlog |
| AD-045 | LDAP signing requirement breaks an application | LDAP | — | Backlog |
| AD-046 | LDAP channel binding compatibility issue | LDAP | — | Backlog |
| AD-047 | Expensive LDAP query affects DC performance | Performance | — | Backlog |
| AD-048 | RID pool exhaustion warning | FSMO | — | Backlog |
| AD-049 | PDC Emulator time synchronization failure | FSMO | — | Backlog |
| AD-050 | Schema extension fails | Schema | — | Backlog |

## Progress

- **Completed:** 30
- **Published target:** 50
- **Overall progress:** 60%

## Standard article format

Every full scenario should contain:

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
