# Install Checklist

1. Copy `NE_REPO_INTELLIGENCE_BRIDGE` into your project repo or into:
   `D:/NEW_EARTH_OMEGA_OS_PACK/23_AI_AND_AUTOMATION/03_OBSIDIAN_REPO_SYNC_MODULE`
2. Open the matching profile in `profiles/`.
3. Set `repo_root` to the project repo path if running centrally.
4. Confirm Obsidian vault path:
   `D:/NEW_EARTH_OMEGA_OS_PACK/09_KNOWLEDGE_VAULT_OBSIDIAN`
5. Confirm dashboard bridge path:
   `D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/01_PROJECT_REPO_BRIDGE/<ProjectName>`
6. Run:
   `./scripts/validate_config.ps1 -Profile ./profiles/microgrow.json`
7. Run:
   `./scripts/sync_all.ps1 -Profile ./profiles/microgrow.json`
8. Open Obsidian and check `03_REPO_KNOWLEDGE_EXPORTS/<ProjectName>`.
9. Point the Dashboard at the JSON files in the project bridge folder.
