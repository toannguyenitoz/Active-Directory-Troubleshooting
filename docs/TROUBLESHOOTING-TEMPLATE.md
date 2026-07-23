# AD-XXX — Scenario title

> **Category:** Authentication / DNS / Replication / Group Policy / Recovery  
> **Difficulty:** Beginner / Intermediate / Advanced  
> **Estimated time:** 15–60 minutes  
> **Last reviewed:** YYYY-MM-DD

## 1. Overview

Describe the problem and why it matters in an enterprise environment.

## 2. Symptoms

- Exact error message
- Relevant event IDs
- Affected users, devices, sites, or Domain Controllers
- Whether the issue is intermittent or continuous

## 3. Business impact

Explain which services are unavailable or degraded.

## 4. Likely causes

- Cause one
- Cause two
- Cause three

## 5. Prerequisites and safety checks

> [!WARNING]
> Do not make destructive changes until backups and recovery options are verified.

- Confirm administrative authorization
- Record the current configuration
- Check system-state backup status
- Confirm a maintenance window when required

## 6. Diagnostic workflow

### Step 1 — Confirm scope

```powershell
# Add read-only discovery commands here
```

### Step 2 — Check DNS and connectivity

```powershell
Resolve-DnsName dc01.contoso.com
Test-NetConnection dc01.contoso.com -Port 389
```

### Step 3 — Review logs

Document the relevant Event Viewer paths and event IDs.

### Step 4 — Run AD diagnostic tools

```powershell
dcdiag /v
repadmin /replsummary
```

## 7. Resolution options

### Option A — Least disruptive

Explain the preferred remediation.

### Option B — Alternative

Explain when this option is appropriate.

### Option C — Recovery or escalation

Explain when Microsoft Support, backup restoration, or forest recovery may be required.

## 8. Verification

```powershell
# Add post-change verification commands here
```

Expected result:

- Service restored
- Replication healthy
- No new critical events
- Users can authenticate

## 9. Prevention

- Monitoring recommendation
- Configuration baseline
- Backup recommendation
- Documentation or change-control improvement

## 10. Useful event IDs

| Event ID | Log | Meaning |
|---:|---|---|
| 0000 | Directory Service | Add description |

## 11. References

Use Microsoft Learn, Microsoft troubleshooting documentation, RFCs, or other primary technical sources.

---

[Back to Scenario Index](SCENARIO-INDEX.md) · [Back to README](../README.md)
