# New Earth Knowledge Fabric Sync Architecture

This page groups the three companion diagrams that explain the full local-first documentation and sync flow.

## 1. End-to-End Sync Architecture

![End-to-End Sync Architecture](./visuals/knowledge_fabric_sync_architecture_01_end_to_end.png)

Shows the full path from dashboard action to bridge orchestration, Obsidian sync, vault mirroring, exports, and the feedback loop back into the dashboard.

## 2. Repo Intelligence Bridge Control Panel

![Repo Intelligence Bridge Control Panel](./visuals/knowledge_fabric_sync_architecture_02_bridge_control_panel.png)

Shows how the dashboard UI triggers the bridge controller, runs PowerShell sync commands, captures live output, and exposes the last sync log.

## 3. Obsidian Sync Module and Vault Fabric

![Obsidian Sync Module and Vault Fabric](./visuals/knowledge_fabric_sync_architecture_03_obsidian_sync.png)

Shows how the local repo tree becomes generated markdown, JSON exports, vault copies, backlinks, session notes, and graph-backed knowledge.

## 4. Executive Overview

![Executive Overview](./visuals/knowledge_fabric_sync_architecture_04_executive_overview.png)

Shows the whole flow in one presentation-friendly view for quick recall.

## Why This Set Matters

- It keeps the whole flow local-first.
- It separates the dashboard control layer from the vault-building engine.
- It makes the docs easier to review from top-level flow down to implementation details.
- It gives the repo one indexed place to explain how the system works end to end.
