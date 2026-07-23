# Contributing

Thank you for helping improve the Active Directory Troubleshooting knowledge base.

## What you can contribute

- Corrections to commands or technical explanations
- New troubleshooting scenarios
- Lab instructions and diagrams
- PowerShell scripts with clear safety notes
- Event ID references
- Screenshots that do not expose sensitive information
- Improvements to grammar, formatting, and accessibility

## Before contributing

1. Test commands in a non-production lab.
2. Remove company names, usernames, IP addresses, domain names, ticket numbers, and credentials.
3. Prefer read-only diagnostic commands before remediation commands.
4. Explain the risk of any command that modifies AD DS, DNS, SYSVOL, replication, or FSMO roles.
5. Use primary technical references, preferably Microsoft Learn or Microsoft troubleshooting documentation.

## Scenario format

Copy [`docs/TROUBLESHOOTING-TEMPLATE.md`](docs/TROUBLESHOOTING-TEMPLATE.md) and use the next available scenario ID from [`docs/SCENARIO-INDEX.md`](docs/SCENARIO-INDEX.md).

File naming example:

```text
docs/replication/AD-003-replication-failures.md
```

## PowerShell standards

- Use approved PowerShell verbs.
- Include comment-based help.
- Use `CmdletBinding()` for reusable scripts.
- Add input validation and error handling.
- Avoid hard-coded production values.
- Clearly mark destructive or service-impacting operations.
- Never include credentials, secrets, tokens, or private keys.

## Pull requests

A pull request should include:

- A clear title
- A summary of the change
- Test environment and validation performed
- Risk or compatibility notes
- Screenshots where useful

By contributing, you agree that your contribution may be distributed under the repository's MIT License.
