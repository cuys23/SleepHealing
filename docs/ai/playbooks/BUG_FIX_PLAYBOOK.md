# Bug Fix Playbook

## Required sequence

1. Define expected versus actual behavior.
2. Capture reproduction.
3. Map execution/data flow.
4. Identify root cause with evidence.
5. Add or design regression test.
6. Implement smallest safe fix.
7. Run focused test.
8. Run broader relevant tests.
9. Runtime QA.
10. Regression scan.
11. Review final diff.
12. Report evidence and remaining risk.

## Severity

- Blocking: prevents core use, data loss, security, release
- High: major feature broken, common failure
- Medium: workaround exists or limited scope
- Low: polish/edge case

## Do not

- change multiple unrelated modules
- suppress exceptions
- clear user data as a fix
- replace architecture without proof
- claim runtime verification from static analysis
