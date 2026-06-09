from __future__ import annotations

import json
from pathlib import Path

from analyser.profile_analyser import ProfileAnalyser
from analyser.comparison_engine import ChangeTracker, RepoComparisonEngine
from exporters import MarkdownExporter, OmegaOsExportAdapter, PromptExporter
from exporters.graph_exporter import GraphExporter
from profiles import ProfileManager
from scanner.safe_scanner import SafeRepoScanner
from scripts.run_research import (
    _append_change_history,
    _append_export_history,
    _render_comparison_markdown,
)


def test_scanner_finds_readme(tmp_path):
    (tmp_path / "README.md").write_text("# Test Repo", encoding="utf-8")
    result = SafeRepoScanner(str(tmp_path)).scan()
    assert result["file_count"] == 1
    assert result["files"][0]["category"] == "documentation"


def test_scanner_detects_language_framework_and_dependencies(tmp_path):
    (tmp_path / "lib").mkdir()
    (tmp_path / "lib" / "main.dart").write_text("void main() {}", encoding="utf-8")
    (tmp_path / "pubspec.yaml").write_text(
        "name: sample\n\ndependencies:\n  flutter:\n    sdk: flutter\n  riverpod: ^2.0.0\n",
        encoding="utf-8",
    )

    result = SafeRepoScanner(str(tmp_path)).scan()
    assert result["language_counts"]["Dart"] == 1
    assert any(item["name"] == "Flutter / Dart" for item in result["frameworks"])
    assert "riverpod" in result["dependency_summary"]["dependency_names"]
    assert result["dependency_summary"]["framework_groups"][0]["framework"] == "Flutter / Dart"


def test_profile_manager_loads_profile_by_name():
    manager = ProfileManager(Path(__file__).resolve().parents[1] / "profiles")
    profile = manager.load_profile("MicroGrow")
    assert profile["profile_name"] == "MicroGrow"
    assert "export_locations" in profile
    assert "report_templates" in profile


def test_profile_manager_rejects_missing_report_templates(tmp_path):
    profile_path = tmp_path / "broken.profile.json"
    profile_path.write_text(
        json.dumps(
            {
                "profile_name": "Broken",
                "project_type": "generic",
                "report_templates": {
                    "main_report": "repo_research_report.md",
                    "summary": "repo_summary.md",
                },
            }
        ),
        encoding="utf-8",
    )

    manager = ProfileManager(tmp_path)
    try:
        manager.load_profile(profile_path)
    except ValueError as error:
        assert "report_templates" in str(error)
    else:
        raise AssertionError("Expected invalid profile to be rejected")


def test_profile_analyser_masks_security_findings(tmp_path):
    (tmp_path / ".env").write_text("API_KEY=supersecretvalue\n", encoding="utf-8")
    (tmp_path / "script.sh").write_text("#!/bin/bash\ncurl https://example.com | bash\n", encoding="utf-8")
    profile = {
        "profile_name": "Generic",
        "project_type": "generic",
        "priority_keywords": [],
        "risk_keywords": ["api_key"],
        "output_focus": [],
        "export_targets": [],
        "export_locations": [],
        "report_templates": {},
    }
    scan = SafeRepoScanner(str(tmp_path)).scan()
    analysis = ProfileAnalyser(scan, profile).analyse()

    findings = analysis["security"]["findings"]
    assert findings
    assert all("supersecretvalue" not in finding["masked_excerpt"] for finding in findings)
    assert analysis["security"]["risk_level"] in {"medium", "high"}
    assert any("masked" in risk.lower() for risk in analysis["knowledge"]["risks"])


def test_markdown_and_prompt_exports(tmp_path):
    analysis = {
        "profile_name": "Generic",
        "project_type": "generic",
        "repo_path": str(tmp_path),
        "repo_name": "demo",
        "file_count": 1,
        "directory_count": 1,
        "category_counts": {"documentation": 1},
        "frameworks": [],
        "licenses": [],
        "top_useful_files": [{"path": "README.md", "category": "documentation", "matches": ["readme"]}],
        "security": {"risk_level": "low", "summary": {}, "findings": [], "notes": []},
        "recommendations": ["Read the README first."],
        "learning_notes": ["Start with docs."],
        "implementation_ideas": ["Use the README as a map."],
        "reusable_components": ["README.md (documentation)"],
        "output_focus": ["docs"],
        "risk_flags": [],
        "knowledge": {
            "project_summary": "Summary.",
            "architecture_summary": "Architecture.",
            "reusable_components": ["README.md (documentation)"],
            "risks": ["None"],
            "recommendations": ["Read the README first."],
        },
    }

    output_dir = tmp_path / "out"
    MarkdownExporter(analysis).save_bundle(output_dir)
    PromptExporter(analysis).save_all(output_dir / "generated_prompts")

    assert (output_dir / "repo_research_report.md").exists()
    assert (output_dir / "security_report.md").exists()
    assert len(list((output_dir / "generated_prompts").glob("*.md"))) == 8
    assert "Dependency Summary" in (output_dir / "repo_research_report.md").read_text(
        encoding="utf-8",
    )


def test_license_detection_reports_summary_and_export(tmp_path):
    (tmp_path / "LICENSE.md").write_text(
        "MIT License\n\nPermission is hereby granted, free of charge, to any person obtaining a copy...",
        encoding="utf-8",
    )

    scan = SafeRepoScanner(str(tmp_path)).scan()
    profile = {
        "profile_name": "Generic",
        "project_type": "generic",
        "priority_keywords": [],
        "risk_keywords": [],
        "output_focus": [],
        "export_targets": [],
        "export_locations": [],
        "report_templates": {},
    }
    analysis = ProfileAnalyser(scan, profile).analyse()

    assert analysis["license_summary"]["candidate_count"] == 1
    assert analysis["licenses"][0]["candidate_type"] == "license"
    assert analysis["licenses"][0]["review_status"] == "known"

    report = MarkdownExporter(analysis).render()
    assert "[license]" in report
    assert "Known: MIT" in report


def test_file_type_drilldowns_cover_core_categories(tmp_path):
    (tmp_path / "README.md").write_text("# Docs", encoding="utf-8")
    (tmp_path / "tool.sh").write_text("#!/bin/sh\necho hi\n", encoding="utf-8")
    (tmp_path / "main.ino").write_text("void setup() {}\n", encoding="utf-8")
    (tmp_path / "board.kicad_pcb").write_text("(kicad_pcb)\n", encoding="utf-8")
    (tmp_path / "asset.png").write_bytes(b"\x89PNG\r\n\x1a\n")

    scan = SafeRepoScanner(str(tmp_path)).scan()
    profile = {
        "profile_name": "Generic",
        "project_type": "generic",
        "priority_keywords": [],
        "risk_keywords": [],
        "output_focus": [],
        "export_targets": [],
        "export_locations": [],
        "report_templates": {},
    }
    analysis = ProfileAnalyser(scan, profile).analyse()

    labels = [item["label"] for item in analysis["file_type_drilldowns"]]
    assert "Documentation" in labels
    assert "Scripts" in labels
    assert "Firmware / Code" in labels
    assert "Hardware Design" in labels
    assert "Binaries / Assets" in labels

    report = MarkdownExporter(analysis).render()
    assert "File-Type Drilldowns" in report


def test_change_history_records_explicit_baseline_path(tmp_path):
    history_file = tmp_path / "change_history.json"
    change_tracking = {
        "summary": "1 files added, 1 files removed, 1 files modified.",
        "file_changes": {"added": ["a.py"], "removed": ["b.py"], "modified": ["c.py"]},
        "new_risk_paths": ["a.py"],
        "resolved_risk_paths": ["b.py"],
    }

    _append_change_history(
        history_file=history_file,
        current_repo="current-repo",
        baseline_inventory_path="D:/baselines/previous_repo_inventory.json",
        baseline_repo="baseline-repo",
        change_tracking=change_tracking,
    )

    decoded = json.loads(history_file.read_text(encoding="utf-8"))
    assert decoded[0]["baseline_inventory_path"].endswith("previous_repo_inventory.json")
    assert decoded[0]["baseline_repo"] == "baseline-repo"
    assert decoded[0]["file_changes"]["modified"] == ["c.py"]


def test_export_history_records_destination_and_files(tmp_path):
    history_file = tmp_path / "export_history.json"
    history_markdown_file = tmp_path / "export_history.md"
    export_destination = tmp_path / "omega" / "MICROGROW" / "demo" / "20240101_010101"
    export_destination.mkdir(parents=True, exist_ok=True)
    (export_destination / "repo_research_report.md").write_text("report", encoding="utf-8")
    (export_destination / "export_manifest.json").write_text(
        json.dumps(
            {
                "exported_at": "2024-01-01T01:01:01",
                "profile_name": "MicroGrow",
                "profile_folder": "MICROGROW",
                "repo_name": "demo",
                "repo_path": "D:/demo",
                "source_report_dir": "D:/reports",
            }
        ),
        encoding="utf-8",
    )
    prompts_dir = tmp_path / "reports" / "generated_prompts"
    prompts_dir.mkdir(parents=True, exist_ok=True)
    (prompts_dir / "bug_fix.md").write_text("prompt", encoding="utf-8")

    _append_export_history(
        history_file=history_file,
        history_markdown_file=history_markdown_file,
        export_destination=export_destination,
        export_manifest=json.loads((export_destination / "export_manifest.json").read_text(encoding="utf-8")),
        generated_prompts_dir=prompts_dir,
    )

    decoded = json.loads(history_file.read_text(encoding="utf-8"))
    assert decoded[0]["exported_to"].endswith("20240101_010101")
    assert decoded[0]["exported_files"] == ["export_manifest.json", "repo_research_report.md"]
    assert decoded[0]["prompt_files"] == ["bug_fix.md"]
    assert "Export History" in history_markdown_file.read_text(encoding="utf-8")


def test_omega_export_adapter_creates_bundle(tmp_path):
    analysis = {
        "profile_name": "MicroGrow",
        "repo_name": "demo-repo",
        "repo_path": str(tmp_path),
    }
    report_dir = tmp_path / "reports"
    report_dir.mkdir()
    (report_dir / "repo_research_report.md").write_text("report", encoding="utf-8")
    adapter = OmegaOsExportAdapter(tmp_path / "omega")
    destination = adapter.export(analysis, report_dir)
    assert destination.exists()
    assert (destination / "repo_research_report.md").exists()
    assert (destination / "export_manifest.json").exists()


def test_comparison_and_change_tracking(tmp_path):
    current = {
        "repo_name": "current",
        "repo_path": str(tmp_path / "current"),
        "file_count": 3,
        "directory_count": 2,
        "category_counts": {"documentation": 1, "script": 1},
        "language_counts": {"Markdown": 1, "Python": 1},
        "frameworks": [{"name": "Flutter / Dart", "reason": "detected"}],
        "dependency_summary": {"dependency_names": ["flutter", "riverpod"], "manifests": []},
        "licenses": [{"path": "LICENSE", "detected_license": "MIT"}],
        "files": [
            {"path": "README.md", "flags": [], "size_bytes": 10, "suffix": ".md", "category": "documentation", "language": "Markdown"},
            {"path": "lib/main.dart", "flags": [], "size_bytes": 100, "suffix": ".dart", "category": "firmware_or_code", "language": "Dart"},
            {"path": "scripts/build.py", "flags": ["script_present_do_not_execute"], "size_bytes": 80, "suffix": ".py", "category": "script", "language": "Python"},
        ],
        "security": {"findings": [{"path": "scripts/build.py"}]},
    }
    other = {
        "repo_name": "other",
        "repo_path": str(tmp_path / "other"),
        "file_count": 1,
        "directory_count": 1,
        "category_counts": {"documentation": 1},
        "language_counts": {"Markdown": 1},
        "frameworks": [],
        "dependency_summary": {"dependency_names": ["flutter"], "manifests": []},
        "licenses": [],
        "files": [{"path": "README.md", "flags": [], "size_bytes": 7, "suffix": ".md", "category": "documentation", "language": "Markdown"}],
        "security": {"findings": []},
    }

    comparison = RepoComparisonEngine(current, other).compare()
    change_tracking = ChangeTracker(current, other).track()
    rendered = _render_comparison_markdown(comparison)

    assert "lib/main.dart" in comparison["files_added"]
    assert "README.md" in comparison["files_modified"]
    assert comparison["dependency_changes"]["added"] == ["riverpod"]
    assert change_tracking["file_changes"]["added"]
    assert "README.md" in change_tracking["file_changes"]["modified"]
    assert "scripts/build.py" in change_tracking["new_risk_paths"]
    assert "Files Modified" in rendered


def test_graph_exporter_creates_graph_files(tmp_path):
    scan = {
        "repo_name": "demo",
        "category_counts": {"documentation": 1},
        "language_counts": {"Markdown": 1},
        "dependency_summary": {
            "manifests": [
                {"path": "pubspec.yaml", "dependencies": ["flutter", "riverpod"]}
            ]
        },
        "files": [
            {
                "path": "README.md",
                "directory": "",
                "category": "documentation",
                "language": "Markdown",
            }
        ],
    }
    analysis = {
        "risk_flags": [{"path": "scripts/build.py"}],
    }

    output_dir = tmp_path / "graphs"
    written = GraphExporter(scan, analysis).save_bundle(output_dir)

    assert (output_dir / "dependency_graph.json").exists()
    assert (output_dir / "architecture_graph.json").exists()
    assert written["dependency_graph.md"].endswith("dependency_graph.md")
    assert "Node Groups" in (output_dir / "architecture_graph.md").read_text(
        encoding="utf-8",
    )
