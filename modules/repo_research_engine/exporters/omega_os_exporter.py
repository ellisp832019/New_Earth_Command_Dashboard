from __future__ import annotations

from datetime import datetime
from pathlib import Path
from shutil import copy2
from typing import Any, Dict, Iterable, List
import json


PROFILE_FOLDERS = {
    "MicroGrow": "MICROGROW",
    "New Earth Dashboard": "NEW_EARTH_DASHBOARD",
    "New Earth Living": "NEW_EARTH_LIVING",
    "BioCalm": "BIOCALM",
    "New Earth Rehabilitation": "REHABILITATION",
    "Omega OS": "GENERAL",
    "Generic": "GENERAL",
    "Template Project": "GENERAL",
}


class OmegaOsExportAdapter:
    def __init__(self, export_root: str | Path) -> None:
        self.export_root = Path(export_root).expanduser().resolve()

    def export(
        self,
        analysis: Dict[str, Any],
        report_dir: str | Path,
        prompts_dir: str | Path | None = None,
    ) -> Path:
        profile_name = str(analysis.get("profile_name", "Generic"))
        profile_folder = PROFILE_FOLDERS.get(profile_name, "GENERAL")
        repo_slug = self._slugify(str(analysis.get("repo_name", "repository")))
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        destination = self.export_root / profile_folder / repo_slug / timestamp
        destination.mkdir(parents=True, exist_ok=True)

        report_dir = Path(report_dir)
        prompts_dir_path = Path(prompts_dir) if prompts_dir else None

        for filename in (
            "repo_research_report.md",
            "repo_summary.md",
            "security_report.md",
            "risk_report.md",
            "license_review.md",
            "vault_note.md",
            "knowledge_report.md",
            "implementation_opportunities.md",
            "learning_notes.md",
            "repo_comparison.md",
            "change_tracking.md",
            "change_history.md",
            "dependency_graph.md",
            "architecture_graph.md",
            "analysis.json",
            "scan_manifest.json",
            "repo_inventory.json",
            "repository_tree.json",
            "repo_comparison.json",
            "change_tracking.json",
            "change_history.json",
            "dependency_graph.json",
            "architecture_graph.json",
            "comparison_analysis.json",
            "report_template_selection.json",
            "report_template_selection.md",
            "report_search_index.json",
            "report_search_index.md",
            "release_notes.json",
            "release_notes.md",
            "bundle_delta_summary.json",
            "bundle_delta_summary.md",
        ):
            source = report_dir / filename
            if source.exists():
                copy2(source, destination / filename)

        if prompts_dir_path and prompts_dir_path.exists():
            prompts_destination = destination / "generated_prompts"
            prompts_destination.mkdir(parents=True, exist_ok=True)
            for prompt_file in prompts_dir_path.glob("*.md"):
                copy2(prompt_file, prompts_destination / prompt_file.name)

        manifest = {
            "profile_name": profile_name,
            "profile_folder": profile_folder,
            "repo_name": analysis.get("repo_name"),
            "repo_path": analysis.get("repo_path"),
            "exported_at": datetime.now().isoformat(timespec="seconds"),
            "source_report_dir": str(report_dir),
        }
        (destination / "export_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        return destination

    def _slugify(self, value: str) -> str:
        slug = value.strip().lower().replace(" ", "_").replace("-", "_")
        return "".join(ch for ch in slug if ch.isalnum() or ch == "_").strip("_")
