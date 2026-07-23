# AD-001 – Domain Controller Won't Boot

## Overview
A Domain Controller that fails to boot is a critical Active Directory issue affecting authentication, DNS, Group Policy and replication.

## Symptoms
- Boot loop or BSOD
- AD DS service fails
- SYSVOL unavailable
- NETLOGON missing

## Possible Causes
- NTDS.dit corruption
- Disk failure
- Corrupted system files
- Failed Windows Update
- Registry corruption

## Diagnosis
```cmd
dcdiag /v
chkdsk C: /f
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```

Check Event Viewer and boot into DSRM if required.

## Resolution
1. Repair Windows.
2. Restore System State backup.
3. Repair or rebuild the DC.
4. Perform metadata cleanup if necessary.

## Verification
```cmd
dcdiag
repadmin /replsummary
repadmin /showrepl
net share
```

## Prevention
- Regular System State backups
- Monitor Event Logs
- Test Windows Updates
- Monitor disk health
