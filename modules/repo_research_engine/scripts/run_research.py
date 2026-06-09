from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path

MODULE_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(MODULE_ROOT))

from analyser import ChangeTracker, ProfileAnalyser, RepoComparisonEngine
from exporters import GraphExporter, MarkdownExporter, OmegaOsExportAdapter, PromptExporter
from profiles import ProfileManager
from scanner.safe_scanner import SafeRepoScanner


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the safe Repo Research Engine")
    parser.add_argument("--repo", required=True, help="Local repository path to scan")
    parser.add_argument(
        "--profile",
        required=True,
        help="Profile JSON path or profile name (for example MicroGrow or profiles/microgrow.profile.json)",
    )
    parser.add_argument(
        "--profiles-dir",
        default=str(MODULE_ROOT / "profiles"),
        help="Directory containing profile JSON files",
    )
    parser.add_argument("--out", default=str(MODULE_ROOT / "reports"), help="Output folder")
    parser.add_argument(
        "--omega-root",
        default="",
        help="Optional Omega OS research library root to export into",
    )
    parser.add_argument(
        "--compare-with",
        default="",
        help="Optional second repo path or inventory JSON to compare against",
    )
    parser.add_argument(
        "--baseline-inventory",
        default="",
        help="Optional previous inventory JSON path for change tracking",
    )
    parser.add_argument(
        "--graph-export",
        action="store_true",
        help="Export dependency and architecture graph bundles",
    )
    parser.add_argument(
        "--compare-profile",
        default="",
        help="Optional profile path or name for the compared repository",
    )
    args = parser.parse_args()

    output_dir = Path(args.out).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    profile_manager = ProfileManager(args.profiles_dir)
    profile = profile_manager.load_profile(args.profile)

    scanner = SafeRepoScanner(args.repo)
    inventory = scanner.scan()
    (output_dir / "repo_inventory.json").write_text(json.dumps(inventory, indent=2), encoding="utf-8")
    (output_dir / "scan_manifest.json").write_text(json.dumps(inventory, indent=2), encoding="utf-8")
    (output_dir / "repository_tree.json").write_text(
        json.dumps(inventory.get("repository_tree", {}), indent=2),
        encoding="utf-8",
    )

    analysis = ProfileAnalyser(inventory, profile).analyse()
    (output_dir / "analysis.json").write_text(json.dumps(analysis, indent=2), encoding="utf-8")

    exporter = MarkdownExporter(analysis)
    exporter.save_bundle(output_dir)

    if args.graph_export:
        GraphExporter(inventory, analysis).save_bundle(output_dir)

    prompts_dir = output_dir / "generated_prompts"
    PromptExporter(analysis).save_all(prompts_dir)

    if args.compare_with:
        comparison_inventory = _load_comparison_inventory(
            args.compare_with,
            profile_manager,
            args.compare_profile or args.profile,
            output_dir,
        )
        comparison = RepoComparisonEngine(inventory, comparison_inventory).compare()
        (output_dir / "repo_comparison.json").write_text(
            json.dumps(comparison, indent=2),
            encoding="utf-8",
        )
        (output_dir / "repo_comparison.md").write_text(
            _render_comparison_markdown(comparison),
            encoding="utf-8",
        )

    if args.baseline_inventory:
        baseline_path = Path(args.baseline_inventory).expanduser().resolve()
        if baseline_path.exists():
            baseline_scan = json.loads(baseline_path.read_text(encoding="utf-8"))
            change_tracking = ChangeTracker(inventory, baseline_scan).track()
            change_tracking["baseline_inventory_path"] = str(baseline_path)
            (output_dir / "change_tracking.json").write_text(
                json.dumps(change_tracking, indent=2),
                encoding="utf-8",
            )
            (output_dir / "change_tracking.md").write_text(
                _render_change_tracking_markdown(change_tracking),
                encoding="utf-8",
            )
            _append_change_history(
                history_file=MODULE_ROOT / "reports" / "change_history.json",
                current_repo=args.repo,
                baseline_inventory_path=str(baseline_path),
                baseline_repo=str(baseline_scan.get("repo_name", "")),
                change_tracking=change_tracking,
            )

    if args.omega_root:
        OmegaOsExportAdapter(args.omega_root).export(analysis, output_dir, prompts_dir)

    _append_run_history(
        output_dir=output_dir,
        repo_path=args.repo,
        profile=profile.get("profile_name", args.profile),
        exit_code=0,
        graph_export=args.graph_export,
        compare_with=args.compare_with or None,
        baseline_inventory=args.baseline_inventory or None,
        compare_profile=args.compare_profile or None,
        command=[
            "python",
            str(Path(__file__).resolve()),
            "--repo",
            args.repo,
            "--profile",
            args.profile,
            "--out",
            str(output_dir),
        ],
    )

    print(f"Repository research bundle written to: {output_dir}")


def _load_comparison_inventory(
    compare_with: str,
    profile_manager: ProfileManager,
    compare_profile: str,
    output_dir: Path,
) -> dict:
    compare_path = Path(compare_with).expanduser()
    if compare_path.is_file() and compare_path.suffix.lower() == ".json":
        return json.loads(compare_path.read_text(encoding="utf-8"))

    if compare_path.exists() and compare_path.is_dir():
        profile = profile_manager.load_profile(compare_profile)
        inventory = SafeRepoScanner(str(compare_path)).scan()
        analysis = ProfileAnalyser(inventory, profile).analyse()
        (output_dir / "comparison_analysis.json").write_text(
            json.dumps(analysis, indent=2),
            encoding="utf-8",
        )
        return inventory

    raise FileNotFoundError(f"Could not resolve comparison source: {compare_with}")


def _render_comparison_markdown(comparison: dict) -> str:
    lines = [
        "# Repo Comparison",
        "",
        f"Current repo: `{comparison.get('current_repo')}`",
        f"Other repo: `{comparison.get('other_repo')}`",
        "",
        "## Summary",
        str(comparison.get("summary", "")),
        "",
        "## Files Added",
    ]
    file_details = comparison.get("file_details", {})
    for item in file_details.get("added", [])[:40]:
        flags = ", ".join(item.get("flags") or []) or "no flags"
        lines.append(
            f"- `{item.get('path')}` - {item.get('category')} - {item.get('language')} - {flags}",
        )
    if not file_details.get("added"):
        for item in comparison.get("files_added", [])[:40]:
            lines.append(f"- {item}")
    lines += ["", "## Files Removed"]
    for item in file_details.get("removed", [])[:40]:
        flags = ", ".join(item.get("flags") or []) or "no flags"
        lines.append(
            f"- `{item.get('path')}` - {item.get('category')} - {item.get('language')} - {flags}",
        )
    if not file_details.get("removed"):
        for item in comparison.get("files_removed", [])[:40]:
            lines.append(f"- {item}")
    lines += ["", "## Files Modified"]
    for item in file_details.get("modified", [])[:40]:
        current = item.get("current", {})
        other = item.get("other", {})
        changes = "; ".join(item.get("changes") or [])
        lines.append(
            f"- `{item.get('path')}` - {other.get('category')} -> {current.get('category')} - "
            f"{other.get('language')} -> {current.get('language')}",
        )
        if changes:
            lines.append(f"  - Changes: {changes}")
    if not file_details.get("modified"):
        lines.append("- No modified files were detected.")
    lines += ["", "## Recommendations"]
    for item in comparison.get("recommendations", []):
        lines.append(f"- {item}")
    return "\n".join(lines).rstrip() + "\n"


def _render_change_tracking_markdown(change_tracking: dict) -> str:
    lines = [
        "# Change Tracking",
        "",
        f"Current repo: `{change_tracking.get('current_repo')}`",
        f"Baseline repo: `{change_tracking.get('baseline_repo')}`",
        "",
        "## File Changes",
    ]
    for label in ("added", "removed", "modified"):
        items = change_tracking.get("file_changes", {}).get(label, [])
        lines.append(f"- {label.title()}: {len(items)}")
        for item in items[:40]:
            lines.append(f"  - {item}")
    lines += ["", "## New Risk Paths"]
    for item in change_tracking.get("new_risk_paths", [])[:40]:
        lines.append(f"- {item}")
    lines += ["", "## Resolved Risk Paths"]
    for item in change_tracking.get("resolved_risk_paths", [])[:40]:
        lines.append(f"- {item}")
    lines += ["", "## Recommendations"]
    for item in change_tracking.get("recommendations", []):
        lines.append(f"- {item}")
    return "\n".join(lines).rstrip() + "\n"


def _append_run_history(
    *,
    output_dir: Path,
    repo_path: str,
    profile: str,
    exit_code: int,
    graph_export: bool,
    compare_with: str | None,
    baseline_inventory: str | None,
    compare_profile: str | None,
    command: list[str],
) -> None:
  history_file = Path(MODULE_ROOT / "reports" / "run_history.json")
  history_file.parent.mkdir(parents=True, exist_ok=True)
  existing = []
  if history_file.exists():
    try:
        decoded = json.loads(history_file.read_text(encoding="utf-8"))
        if isinstance(decoded, list):
            existing = [item for item in decoded if isinstance(item, dict)]
    except Exception:
        existing = []

  report_files = sorted(
      [
          file.name
          for file in output_dir.iterdir()
          if file.is_file()
      ]
  )
  record = {
      "timestamp": datetime.now().isoformat(timespec="seconds"),
      "repo_path": repo_path,
      "profile": profile,
      "output_directory": str(output_dir),
      "exit_code": exit_code,
      "command": command + (["--graph-export"] if graph_export else []),
      "graph_export": graph_export,
      "compare_with": compare_with,
      "baseline_inventory": baseline_inventory,
      "compare_profile": compare_profile,
      "report_files": report_files,
  }
  updated = [record, *existing][:20]
  history_file.write_text(json.dumps(updated, indent=2), encoding="utf-8")


def _append_change_history(
    *,
    history_file: Path,
    current_repo: str,
    baseline_inventory_path: str,
    baseline_repo: str,
    change_tracking: dict,
) -> None:
    history_file.parent.mkdir(parents=True, exist_ok=True)
    existing = []
    if history_file.exists():
        try:
            decoded = json.loads(history_file.read_text(encoding="utf-8"))
            if isinstance(decoded, list):
                existing = [item for item in decoded if isinstance(item, dict)]
        except Exception:
            existing = []

    record = {
        "timestamp": datetime.now().isoformat(timespec="seconds"),
        "current_repo": current_repo,
        "baseline_inventory_path": baseline_inventory_path,
        "baseline_repo": baseline_repo,
        "summary": change_tracking.get("summary", ""),
        "file_changes": change_tracking.get("file_changes", {}),
        "new_risk_paths": change_tracking.get("new_risk_paths", []),
        "resolved_risk_paths": change_tracking.get("resolved_risk_paths", []),
    }
    updated = [record, *existing][:20]
    history_file.write_text(json.dumps(updated, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
