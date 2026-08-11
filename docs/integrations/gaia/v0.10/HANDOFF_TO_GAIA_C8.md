# Handoff to GAIA C8

GAIA C8 should treat this Dashboard branch as the downstream consumer surface for the merged C7A contract.

## What C8 should verify

- the exact merged GAIA main SHA remains pinned in the Dashboard
- the read-only programme intelligence surface still renders safely
- the dependency pin evidence still matches the lockfile
- the dashboard remains fail-closed when GAIA is unavailable or incompatible
- the existing operations surface is still present

## What C8 should not do here

- no Dashboard release publication
- no GAIA repository mutation
- no MicroGrow mutation
- no direct execution or Git mutation from the Dashboard surface

## Notes

The Dashboard should continue to consume the exact merged GAIA SHA produced by C7A until a later, explicitly approved integration update changes that contract.
