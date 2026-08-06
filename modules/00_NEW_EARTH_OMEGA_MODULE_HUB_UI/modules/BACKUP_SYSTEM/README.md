# Backup System

## Purpose

Daily/weekly backup command centre with restore points, logs and target checks.

## Current state

This module is intentionally a shell. It can be shown in the Module Hub, governed with a manifest, and expanded later without hard-coding the implementation now.

## What it should grow into

- core workflow implementation
- local file and vault bridge
- module-specific health and logging
- dashboard integration
- later automation once the shell is stable

## Requested permissions

- file_read
- file_write_backup_target
- scheduled_tasks
- system_health
