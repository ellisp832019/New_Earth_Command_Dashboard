from __future__ import annotations

import json
from pathlib import Path

from analyser.profile_analyser import ProfileAnalyser
from analyser.comparison_engine import ChangeTracker, RepoComparisonEngine
from exporters import MarkdownExporter, OmegaOsExportAdapter, PromptExporter
from exporters.graph_exporter import GraphExporter
from profiles import ProfileManager
from scanner.safe_scanner import SafeRepoScanner
from sources import (
    GitHubSourceAdapter,
    LocalPdfResearchSourceAdapter,
    RemoteFileRef,
    RemoteRepositoryRef,
    RemoteRepositorySnapshot,
    ResearchDocument,
    ResearchSourceRef,
    WebsiteResearchSourceAdapter,
)
from intelligence import (
    AiGenerationRequest,
    AiGenerationResponse,
    KnowledgeChunk,
    LocalAiProvider,
    RagSearchHit,
    RagSearchIndex,
)
from scripts.run_research import (
    _append_change_history,
    _append_export_history,
    _build_report_search_index,
    _build_release_notes,
    _build_bundle_delta_summary,
    _render_comparison_markdown,
    _render_release_notes_markdown,
    _render_bundle_delta_summary_markdown,
)


def test_scanner_finds_readme(tmp_path):
    (tmp_path / "README.md").write_text("# Test Repo", encoding="utf-8")
    result = SafeRepoScanner(str(tmp_path)).scan()
    assert result["file_count"] == 1
    assert result["files"][0]["category"] == "documentation"
    assert result["document_index"][0]["heading_count"] == 1


def test_document_index_extracts_headings_links_tables_and_notes(tmp_path):
    (tmp_path / "README.md").write_text(
        "# Title\n\n## Overview\nSee [Guide](guide.md).\n\n| A | B |\n|---|---|\n| 1 | 2 |\n\n[ref]: https://example.invalid\n[^1]: Footnote\n",
        encoding="utf-8",
    )

    result = SafeRepoScanner(str(tmp_path)).scan()
    document_index = result["document_index"][0]

    assert document_index["title"] == "Title"
    assert document_index["heading_count"] == 2
    assert document_index["link_count"] == 1
    assert document_index["table_count"] == 1
    assert document_index["reference_note_count"] == 2


def test_image_asset_discovery_classifies_visual_assets(tmp_path):
    (tmp_path / "screenshots").mkdir()
    (tmp_path / "screenshots" / "dashboard-screenshot.png").write_bytes(b"\x89PNG\r\n\x1a\n")
    (tmp_path / "icons").mkdir()
    (tmp_path / "icons" / "app-icon.ico").write_bytes(b"ICON")
    (tmp_path / "docs").mkdir()
    (tmp_path / "docs" / "architecture-diagram.svg").write_text("<svg></svg>", encoding="utf-8")

    result = SafeRepoScanner(str(tmp_path)).scan()
    asset_types = {item["asset_type"] for item in result["image_assets"]}

    assert "screenshot" in asset_types
    assert "icon" in asset_types
    assert "diagram" in asset_types


def test_diagram_discovery_finds_sources_and_embedded_flowcharts(tmp_path):
    (tmp_path / "flowchart.mmd").write_text(
        "flowchart TD\n  A --> B\n  B --> C\n",
        encoding="utf-8",
    )
    (tmp_path / "sequence.puml").write_text(
        "@startuml\nAlice -> Bob: Hello\n@enduml\n",
        encoding="utf-8",
    )
    (tmp_path / "README.md").write_text(
        "# Docs\n\n```mermaid\nflowchart LR\n  X --> Y\n```\n",
        encoding="utf-8",
    )

    result = SafeRepoScanner(str(tmp_path)).scan()
    diagram_types = {item["diagram_type"] for item in result["diagram_files"]}

    assert "mermaid" in diagram_types
    assert "plantuml" in diagram_types
    assert "embedded_markdown_diagram" in diagram_types


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
    assert result["dependency_summary"]["manifest_drilldowns"][0]["runtime"] == "Flutter / Dart"


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
    assert (output_dir / "license_review.md").exists()
    assert (output_dir / "report_template_selection.md").exists()
    assert len(list((output_dir / "generated_prompts").glob("*.md"))) == 8
    assert "Dependency Summary" in (output_dir / "repo_research_report.md").read_text(
        encoding="utf-8",
    )


def test_report_search_index_indexes_generated_reports(tmp_path):
    (tmp_path / "repo_research_report.md").write_text("# Main Report\n\nAlpha beta.", encoding="utf-8")
    (tmp_path / "knowledge_report.md").write_text("# Knowledge\n\nUseful notes.", encoding="utf-8")
    (tmp_path / "repo_comparison.md").write_text("# Comparison\n\nChanged files.", encoding="utf-8")

    _build_report_search_index(tmp_path)

    index_json = json.loads((tmp_path / "report_search_index.json").read_text(encoding="utf-8"))
    index_md = (tmp_path / "report_search_index.md").read_text(encoding="utf-8")

    assert index_json["report_count"] == 3
    assert any(item["path"] == "repo_comparison.md" for item in index_json["reports"])
    assert "Report Search Index" in index_md


def test_release_notes_capture_comparison_and_change_tracking(tmp_path):
    analysis = {
        "repo_name": "demo",
        "profile_name": "MicroGrow",
        "project_summary": "Summary.",
        "knowledge": {"risks": ["Masked risk reminder." ]},
        "recommendations": ["Do a calm review."],
        "top_useful_files": [{"path": "README.md"}, {"path": "lib/main.dart"}],
    }
    comparison = {"summary": "2 files added, 1 file removed, 1 file modified."}
    change_tracking = {
        "summary": "1 files added, 1 files removed, 1 files modified.",
        "file_changes": {"added": ["a.py"], "removed": ["b.py"], "modified": ["c.py"]},
    }

    release_notes = _build_release_notes(
        analysis=analysis,
        comparison=comparison,
        change_tracking=change_tracking,
        output_dir=tmp_path,
    )
    rendered = _render_release_notes_markdown(release_notes)

    assert release_notes["repo_name"] == "demo"
    assert release_notes["comparison_summary"] == comparison["summary"]
    assert "Release Notes" in rendered
    assert "Change Tracking Summary" in rendered
    assert "Release Checks" in rendered


def test_bundle_delta_summary_compares_previous_run(tmp_path):
    history_file = tmp_path / "run_history.json"
    history_file.write_text(
        json.dumps(
            [
                {
                    "timestamp": "2024-01-01T00:00:00",
                    "repo_path": "D:/old",
                    "profile": "Generic",
                    "output_directory": "D:/old/out",
                    "report_files": ["repo_research_report.md", "security_report.md"],
                }
            ]
        ),
        encoding="utf-8",
    )
    current_run = {
        "repo_path": "D:/new",
        "profile": "MicroGrow",
        "report_files": [
            "repo_research_report.md",
            "security_report.md",
            "bundle_delta_summary.md",
        ],
    }

    bundle_delta = _build_bundle_delta_summary(
        output_dir=tmp_path / "out",
        current_run=current_run,
        history_file=history_file,
    )
    rendered = _render_bundle_delta_summary_markdown(bundle_delta)

    assert bundle_delta["report_deltas"]["added"] == ["bundle_delta_summary.md"]
    assert bundle_delta["current_run"]["profile"] == "MicroGrow"
    assert "Bundle Delta Summary" in rendered
    assert "Report Deltas" in rendered


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
    assert "Dependency Summary" in report


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


def test_source_adapter_interfaces_are_read_only():
    repository = RemoteRepositoryRef(
        provider="GitHub",
        owner="new-earth",
        name="dashboard",
        url="https://example.invalid/new-earth/dashboard",
    )
    snapshot = RemoteRepositorySnapshot(
        repository=repository,
        files=(RemoteFileRef(path="README.md", language="Markdown"),),
        metadata={"branch": "main"},
    )

    class DummyGitHubAdapter(GitHubSourceAdapter):
        def search_repositories(self, query: str, *, limit: int = 20):
            return []

        def fetch_repository_snapshot(self, repository: RemoteRepositoryRef):
            return snapshot

        def fetch_file_tree(self, repository: RemoteRepositoryRef, *, path: str = ""):
            return list(snapshot.files)

        def fetch_file_text(self, repository: RemoteRepositoryRef, path: str):
            return ""

    adapter = DummyGitHubAdapter()

    assert adapter.provider_name == "GitHub"
    assert snapshot.repository.name == "dashboard"
    assert snapshot.source_type == "read-only"
    assert adapter.fetch_repository_snapshot(repository) == snapshot


def test_research_source_interfaces_mark_network_opt_in():
    source = ResearchSourceRef(
        source_kind="website",
        identifier="example",
        uri="https://example.invalid/research",
        title="Example research article",
    )
    document = ResearchDocument(source=source, text="Notes")

    assert LocalPdfResearchSourceAdapter.SOURCE_KIND == "pdf"
    assert WebsiteResearchSourceAdapter.REQUIRES_NETWORK_OPT_IN is True
    assert document.source.title == "Example research article"
    assert document.text == "Notes"


def test_local_ai_and_rag_interfaces_are_local_first():
    class DummyLocalAiProvider(LocalAiProvider):
        @property
        def provider_name(self) -> str:
            return "LocalTest"

        def generate(self, request: AiGenerationRequest) -> AiGenerationResponse:
            return AiGenerationResponse(text=request.prompt, provider_name=self.provider_name)

        def embed(self, texts):
            return [[float(len(text))] for text in texts]

    class DummyRagIndex(RagSearchIndex):
        def __init__(self) -> None:
            self.chunks = []

        def index_documents(self, chunks):
            self.chunks = list(chunks)

        def search(self, query: str, *, limit: int = 10):
            return [
                RagSearchHit(
                    chunk_id=chunk.chunk_id,
                    score=1.0,
                    snippet=chunk.text[:24],
                    source_uri=chunk.source_uri,
                )
                for chunk in self.chunks[:limit]
                if query.lower() in chunk.text.lower()
            ]

        def clear(self) -> None:
            self.chunks.clear()

    provider = DummyLocalAiProvider()
    index = DummyRagIndex()
    chunk = KnowledgeChunk(chunk_id="1", source_uri="local://doc", text="New Earth dashboard notes")
    index.index_documents([chunk])

    assert provider.REQUIRES_NETWORK is False
    assert index.REQUIRES_NETWORK is False
    assert provider.generate(AiGenerationRequest(prompt="hello")).text == "hello"
    assert provider.embed(["abc", "abcd"]) == [[3.0], [4.0]]
    assert index.search("dashboard")[0].chunk_id == "1"


def test_omega_export_adapter_creates_bundle(tmp_path):
    analysis = {
        "profile_name": "MicroGrow",
        "repo_name": "demo-repo",
        "repo_path": str(tmp_path),
    }
    report_dir = tmp_path / "reports"
    report_dir.mkdir()
    (report_dir / "repo_research_report.md").write_text("report", encoding="utf-8")
    (report_dir / "report_template_selection.md").write_text("templates", encoding="utf-8")
    (report_dir / "report_template_selection.json").write_text(
        json.dumps({"profile_name": "MicroGrow", "report_templates": {}}),
        encoding="utf-8",
    )
    (report_dir / "report_search_index.md").write_text("search index", encoding="utf-8")
    (report_dir / "report_search_index.json").write_text(
        json.dumps({"report_count": 1, "reports": []}),
        encoding="utf-8",
    )
    (report_dir / "release_notes.md").write_text("release notes", encoding="utf-8")
    (report_dir / "release_notes.json").write_text(
        json.dumps({"repo_name": "demo-repo"}),
        encoding="utf-8",
    )
    (report_dir / "license_review.md").write_text("licence review", encoding="utf-8")
    (report_dir / "bundle_delta_summary.md").write_text("bundle delta", encoding="utf-8")
    (report_dir / "bundle_delta_summary.json").write_text(
        json.dumps({"summary": "1 reports added"}),
        encoding="utf-8",
    )
    adapter = OmegaOsExportAdapter(tmp_path / "omega")
    destination = adapter.export(analysis, report_dir)
    assert destination.exists()
    assert (destination / "repo_research_report.md").exists()
    assert (destination / "export_manifest.json").exists()
    assert (destination / "report_template_selection.md").exists()
    assert (destination / "report_search_index.md").exists()
    assert (destination / "release_notes.md").exists()
    assert (destination / "bundle_delta_summary.md").exists()
    assert (destination / "license_review.md").exists()


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
    assert "Key Anchors" in (output_dir / "architecture_graph.md").read_text(
        encoding="utf-8",
    )
