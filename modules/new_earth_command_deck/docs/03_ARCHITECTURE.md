# Architecture

```text
[Stream Deck / Hotkeys / Custom ESP32 Deck]
                 |
                 v
        [Command Deck Bridge]
                 |
        -----------------------
        |          |          |
        v          v          v
 [Dashboard]  [Scripts]  [OBS/Meet/VS Code]
        |
        v
    [Omega OS]
        |
        v
 [Logs, Meetings, Docs, Knowledge, Exports]
```

## Layers

### 1. Physical input layer

- Stream Deck
- Keyboard shortcuts
- Future ESP32-S3 custom controls

### 2. Command bridge

Small local script/app that receives button actions and triggers:

- Opening folders
- Opening URLs
- Creating files
- Running scripts
- Starting recordings
- Creating handoff docs

### 3. Dashboard layer

The UI where all pages and modules live.

### 4. Omega OS layer

The permanent storage layer for:

- Meeting notes
- Transcripts
- Build logs
- Decisions
- Screenshots
- Campaign files
- Project records

### 5. Project repo layer

Actual code remains inside project repos:

- MicroGrow
- New Earth Dashboard
- New Earth Living
- BioCalm

The Command Deck does not replace repos. It orchestrates them.
