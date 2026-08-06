# Functional Specification: New Earth Command Deck Dashboard Module

## Objective

Create a dashboard module that acts as the software control centre for the Stream Deck and future New Earth Command Core hardware.

## Users

- Peter as builder/operator
- Hayley for finance/asset quick actions
- Future team/collaborators with restricted access

## Features

### F1 Command grid

Display grouped buttons that trigger local actions or open pages.

### F2 Command registry

Load button/action definitions from JSON.

### F3 Local path settings

Allow setting project paths and Omega OS paths.

### F4 Meeting starter

Create meeting folders and files from templates.

### F5 Build session logger

Create daily build session logs.

### F6 Codex handoff creator

Generate Codex handoff markdown files.

### F7 OBS/recording helper

Document and trigger hotkeys where possible.

### F8 Action log

Record every command action.

### F9 Safety confirmations

Require confirmation for commands marked `Confirm` or `Dangerous`.

### F10 Future hardware bridge

Allow serial/WebSocket messages from ESP32-S3 Command Core.

## Non-goals for V1

- Cloud sync
- Full voice AI
- Custom PCB
- Remote public access
- Dangerous hardware control
