# Experiment Dashboard

## Active

```dataview
TABLE project, status, category
FROM "Experiments"
WHERE status != "COMPLETE"
SORT created DESC
```

## Completed

```dataview
TABLE project, category, conclusion
FROM "Experiments"
WHERE status = "COMPLETE"
SORT created DESC
```
