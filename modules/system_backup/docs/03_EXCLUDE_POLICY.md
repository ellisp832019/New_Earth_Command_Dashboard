# Exclude Policy

The module backs up the whole `D:\` drive, but skips files that are usually regenerated.

Default excludes:

```text
.git
node_modules
build
dist
.cache
.gradle
.flutter_tool
.dart_tool
__pycache__
.pytest_cache
target
tmp
temp
logs
.local_backup_runtime
backup_tmp
```

Do not exclude:

- source files
- `.md` files
- documents
- images
- diagrams
- meeting files
- Obsidian notes
- Omega OS folders
- config examples
- design docs
- exported reports
