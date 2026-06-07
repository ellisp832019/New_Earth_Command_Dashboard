# BackupGuardianCard Component

Props:

```ts
type BackupGuardianStatus = {
  state: "green" | "amber" | "red" | "grey";
  source: string;
  target: string;
  lastBackupAt?: string;
  lastVerifyAt?: string;
  summary: string;
  warnings: string[];
  errors: string[];
};
```

Display:

- state badge
- source path
- target path
- latest backup
- latest verification
- summary
