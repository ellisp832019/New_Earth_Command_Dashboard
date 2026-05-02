# Safe Install Instructions

Windows Smart App Control may block downloaded zip files that contain `.bat`, `.cmd`, `.exe`, `.ps1`, or script-style files.

This safer package contains no `.bat` setup file.

## How to install

1. Extract this zip.
2. Open your New Earth Dashboard repo folder.
3. Manually copy these folders into the repo:
   - `docs`
   - `lib`
   - `tools`

## Important

The Python bridge file is saved as:

```text
tools/voice_bridge/voice_bridge.py.txt
```

This is deliberate so Windows treats it as a normal text file.

Only rename it to:

```text
voice_bridge.py
```

when you are ready to run the local Python prototype.

## Do not run unknown setup files

For this first step, you do not need a `.bat` file.

The safer method is manual copy/paste into the dashboard repo.
