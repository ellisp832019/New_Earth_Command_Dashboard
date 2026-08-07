# Risk And Readiness Guide

Release readiness is calculated from the registry evidence, verification
records, module documentation status and open risks.

- Any open `P0` risk blocks readiness.
- A required failed verification prevents `ready`.
- Missing evidence or documentation usually keeps the result at
  `not_ready`.
- A green test suite does not automatically resolve architecture or security
  risks.
