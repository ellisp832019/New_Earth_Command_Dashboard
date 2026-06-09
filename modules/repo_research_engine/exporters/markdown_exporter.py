from __future__ import annotations

from datetime import datetime
import json
from pathlib import Path
from typing import Any, Dict, Iterable, List


class MarkdownExporter:
    def __init__(self, analysis: Dict[str, Any]) -> None:
        self.analysis = analysis

    def render(self) -> str:
        return self._render_main_report()

    def save(self, out_path: str) -> None:
        path = Path(out_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(self.render(), encoding="utf-8")

    def save_bundle(self, out_dir: str | Path) -> Dict[str, str]:
        output_dir = Path(out_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        template_selection = self.analysis.get("report_templates", {})

        outputs = {
            "repo_research_report.md": self._render_main_report(),
            "repo_summary.md": self._render_repo_summary(),
            "security_report.md": self._render_security_report(),
            "risk_report.md": self._render_risk_report(),
            "license_review.md": self._render_license_review_panel(),
            "vault_note.md": self._render_vault_note(),
            "knowledge_report.md": self._render_knowledge_report(),
            "implementation_opportunities.md": self._render_implementation_opportunities(),
            "learning_notes.md": self._render_learning_notes(),
            "report_template_selection.json": {
                "profile_name": self.analysis.get("profile_name"),
                "report_templates": template_selection,
            },
            "report_template_selection.md": self._render_template_selection(template_selection),
        }

        written: Dict[str, str] = {}
        for filename, content in outputs.items():
            target = output_dir / filename
            if isinstance(content, str):
                target.write_text(content, encoding="utf-8")
            else:
                target.write_text(json.dumps(content, indent=2), encoding="utf-8")
            written[filename] = str(target)
        return written

    def _render_main_report(self) -> str:
        a = self.analysis
        lines: List[str] = []
        lines += [
            f"# Repo Research Report - {a.get('profile_name')}",
            "",
            f"Generated: {datetime.now().isoformat(timespec='seconds')}",
            f"Repo: `{a.get('repo_path')}`",
            f"Profile: **{a.get('profile_name')}**",
            f"Project type: {a.get('project_type')}",
            f"Relevance score: **{a.get('relevance_score')}**",
            f"Risk level: **{a.get('security', {}).get('risk_level', 'unknown')}**",
            "",
            "## Project Summary",
            a.get("project_summary", "No summary available."),
            "",
            "## Architecture Summary",
            a.get("architecture_summary", "No architecture summary available."),
            "",
            "## Category Counts",
        ]
        for key, value in (a.get("category_counts") or {}).items():
            lines.append(f"- {key}: {value}")

        lines += ["", "## Framework Signals"]
        frameworks = a.get("frameworks", [])
        if frameworks:
            for item in frameworks:
                lines.append(f"- {item.get('name')}: {item.get('reason')}")
        else:
            lines.append("- No strong framework signal detected.")

        lines += ["", "## Dependency Summary"]
        dependency_summary = a.get("dependency_summary", {})
        manifests = dependency_summary.get("manifests", [])
        if manifests:
            lines.append(f"- Manifest files parsed: {len(manifests)}")
            for manifest in manifests[:8]:
                sample = ", ".join(manifest.get("dependencies", [])[:6]) or "No parsed dependencies"
                lines.append(
                    f"- `{manifest.get('path')}` ({manifest.get('kind', 'unknown')}): {sample}",
                )
        else:
            lines.append("- No dependency manifests were parsed.")

        framework_groups = dependency_summary.get("framework_groups", [])
        if framework_groups:
            lines.append("")
            lines.append("### By Framework")
            for group in framework_groups[:8]:
                lines.append(
                    f"- {group.get('framework', 'Unknown')}: "
                    f"{group.get('dependency_count', 0)} dependencies across "
                    f"{len(group.get('manifests', []))} manifest(s)",
                )

        manifest_drilldowns = dependency_summary.get("manifest_drilldowns", [])
        if manifest_drilldowns:
            lines.append("")
            lines.append("### By Runtime")
            for group in manifest_drilldowns[:8]:
                lines.append(
                    f"- {group.get('runtime', 'Unknown')}: "
                    f"{group.get('dependency_count', 0)} parsed dependencies",
                )
                for manifest in group.get("manifests", [])[:6]:
                    sample = ", ".join(manifest.get("dependencies", [])[:5]) or "No parsed dependencies"
                    lines.append(
                        f"  - `{manifest.get('path')}` ({manifest.get('kind', 'unknown')}): {sample}",
                    )

        lines += ["", "## File-Type Drilldowns"]
        drilldowns = a.get("file_type_drilldowns", [])
        if drilldowns:
            for group in drilldowns:
                lines.append(f"### {group.get('label', 'Files')} ({group.get('count', 0)})")
                for item in group.get("files", [])[:6]:
                    flags = ", ".join(item.get("flags") or []) or "no flags"
                    lines.append(
                        f"- `{item.get('path')}` - {item.get('language', 'Unknown')} - {flags}",
                    )
                lines.append("")
        else:
            lines.append("- No drilldown categories were identified.")

        lines += ["", "## Image Asset Discovery"]
        image_assets = a.get("image_assets", [])
        if image_assets:
            asset_groups: Dict[str, List[Dict[str, Any]]] = {}
            for item in image_assets:
                asset_groups.setdefault(str(item.get("asset_type", "image_asset")), []).append(item)
            for asset_type, items in sorted(asset_groups.items()):
                lines.append(f"### {asset_type} ({len(items)})")
                for item in items[:8]:
                    hints = ", ".join(item.get("hints") or []) or "inspect manually"
                    lines.append(f"- `{item.get('path')}` - {hints}")
                lines.append("")
        else:
            lines.append("- No image assets were detected.")

        lines += ["", "## Diagram Discovery"]
        diagram_files = a.get("diagram_files", [])
        if diagram_files:
            for item in diagram_files[:20]:
                markers = ", ".join(item.get("markers") or []) or "diagram"
                lines.append(f"- `{item.get('path')}` - {item.get('diagram_type')} - {markers}")
        else:
            lines.append("- No diagram or flowchart sources were detected.")

        lines += ["", "## Licences"]
        license_summary = a.get("license_summary", {})
        if license_summary:
            lines.append(
                f"- Candidates: {license_summary.get('candidate_count', 0)} | "
                f"Known: {', '.join(license_summary.get('known_licenses', [])) or 'None'} | "
                f"Needs review: {license_summary.get('unknown_candidate_count', 0)}",
            )
        licenses = a.get("licenses", [])
        if licenses:
            for item in licenses:
                candidate_type = item.get("candidate_type", "candidate")
                detected = item.get("detected_license", "Unknown")
                status = item.get("review_status", "needs_review")
                status_label = "reviewed" if status == "known" else "needs review"
                lines.append(
                    f"- `{item.get('path')}` [{candidate_type}] - {detected} ({status_label})",
                )
        else:
            lines.append("- No obvious licence file detected.")

        lines += ["", "## Top Useful Files"]
        for f in a.get("top_useful_files", [])[:50]:
            match = ", ".join(f.get("matches") or []) or "general relevance"
            lines.append(f"- `{f['path']}` - {f['category']} - {match}")

        lines += ["", "## Document Index"]
        document_highlights = a.get("knowledge", {}).get("document_highlights", [])
        if document_highlights:
            for item in document_highlights[:20]:
                lines.append(f"- {item}")
        else:
            lines.append("- No document index highlights were generated.")

        lines += ["", "## Security Overview"]
        security = a.get("security", {})
        summary = security.get("summary", {})
        if summary:
            for key, value in summary.items():
                lines.append(f"- {key}: {value}")
        else:
            lines.append("- No security findings were flagged.")

        lines += ["", "## Recommended Next Actions"]
        for item in a.get("recommendations", []):
            lines.append(f"- {item}")

        lines += [
            "",
            "## Prompt Generator",
            "Use the generated prompt files in `generated_prompts/` for bug fixing, feature creation, architecture review, firmware review, Flutter review, ESP32 review, dashboard review, and documentation generation.",
        ]
        return "\n".join(lines).rstrip() + "\n"

    def _render_repo_summary(self) -> str:
        a = self.analysis
        lines = [
            f"# Repo Summary - {a.get('profile_name')}",
            "",
            f"Repository: `{a.get('repo_name')}`",
            f"Path: `{a.get('repo_path')}`",
            f"Files scanned: **{a.get('file_count')}**",
            f"Directories indexed: **{a.get('directory_count')}**",
            f"Risk level: **{a.get('security', {}).get('risk_level', 'unknown')}**",
            "",
            "## Overview",
            a.get("project_summary", "No summary available."),
            "",
            "## Useful Files",
        ]
        for item in a.get("top_useful_files", [])[:30]:
            lines.append(f"- `{item['path']}`")
        lines += ["", "## Notes"]
        for note in a.get("learning_notes", []):
            lines.append(f"- {note}")
        return "\n".join(lines).rstrip() + "\n"

    def _render_security_report(self) -> str:
        security = self.analysis.get("security", {})
        lines = [
            "# Security Report",
            "",
            f"Risk level: **{security.get('risk_level', 'unknown')}**",
            "",
            "## Summary",
        ]
        summary = security.get("summary", {})
        if summary:
            for severity, count in summary.items():
                lines.append(f"- {severity}: {count}")
        else:
            lines.append("- No findings were flagged by the static detector.")

        lines += ["", "## Findings"]
        findings = security.get("findings", [])
        if findings:
            for finding in findings:
                lines.append(
                    f"- `{finding.get('path')}` - {finding.get('finding_type')} - {finding.get('severity')} - {finding.get('masked_excerpt')}"
                )
        else:
            lines.append("- No findings to report.")

        lines += ["", "## Safety Notes"]
        for note in security.get("notes", []):
            lines.append(f"- {note}")
        return "\n".join(lines).rstrip() + "\n"

    def _render_license_review_panel(self) -> str:
        lines = [
            "# Licence Review Panel",
            "",
            "## Summary",
        ]
        license_summary = self.analysis.get("license_summary", {})
        lines.append(
            f"- Candidates: {license_summary.get('candidate_count', 0)}",
        )
        lines.append(
            f"- Known licences: {', '.join(license_summary.get('known_licenses', [])) or 'None'}",
        )
        lines.append(
            f"- Needs review: {license_summary.get('unknown_candidate_count', 0)}",
        )

        lines += ["", "## Candidate Review"]
        licenses = self.analysis.get("licenses", [])
        if licenses:
            for item in licenses:
                candidate_type = item.get("candidate_type", "candidate")
                detected = item.get("detected_license", "Unknown")
                review_status = item.get("review_status", "needs_review")
                lines.append(
                    f"- `{item.get('path')}` [{candidate_type}] - {detected} - {review_status}",
                )
        else:
            lines.append("- No licence candidates were detected.")

        lines += ["", "## Review Notes"]
        lines += [
            "- Keep licence excerpts masked if they are copied into notes or prompts.",
            "- Treat unknown licence candidates as a manual review item before reuse.",
            "- Prefer the detected licence name over any assumptions from file naming alone.",
        ]
        return "\n".join(lines).rstrip() + "\n"

    def _render_vault_note(self) -> str:
        template = self._load_vault_template()
        replacements = {
            "{{REPO_NAME}}": self.analysis.get("repo_name", "Unknown repository"),
            "{{PROFILE_NAME}}": self.analysis.get("profile_name", "Unknown profile"),
            "{{WHY_RESEARCHED}}": self._vault_why_researched(),
            "{{USEFUL_IDEAS}}": self._vault_bullet_block(self.analysis.get("implementation_ideas", [])),
            "{{FILES_WORTH_REVIEWING}}": self._vault_file_block(self.analysis.get("top_useful_files", [])),
            "{{RISKS_LICENCE_NOTES}}": self._vault_risk_block(),
            "{{WHAT_TO_ADAPT}}": self._vault_bullet_block(self.analysis.get("reusable_components", [])),
            "{{WHAT_TO_IGNORE}}": self._vault_ignore_block(),
            "{{NEXT_TASKS}}": self._vault_bullet_block(self.analysis.get("recommendations", [])),
            "{{SOURCE_REPO}}": str(self.analysis.get("repo_path", "")),
            "{{LOCAL_SCAN_REPORT}}": "repo_research_report.md",
        }
        rendered = template
        for token, value in replacements.items():
            rendered = rendered.replace(token, value)
        return rendered.rstrip() + "\n"

    def _load_vault_template(self) -> str:
        template_name = (
            self.analysis.get("report_templates", {}).get("vault_note")
            or "repo_research_note_template.md"
        )
        template_path = (
            Path(__file__).resolve().parents[1] / "vault_templates" / str(template_name)
        )
        if template_path.exists():
            return template_path.read_text(encoding="utf-8")
        return (
            "# {{REPO_NAME}} - Repo Research Note\n\n"
            "## Profile\n{{PROFILE_NAME}}\n\n"
            "## Why this repo was researched\n{{WHY_RESEARCHED}}\n\n"
            "## Useful ideas\n{{USEFUL_IDEAS}}\n\n"
            "## Files worth reviewing\n{{FILES_WORTH_REVIEWING}}\n\n"
            "## Risks / licence notes\n{{RISKS_LICENCE_NOTES}}\n\n"
            "## What to adapt\n{{WHAT_TO_ADAPT}}\n\n"
            "## What to ignore\n{{WHAT_TO_IGNORE}}\n\n"
            "## Next tasks\n{{NEXT_TASKS}}\n\n"
            "## Links\n- Source repo: {{SOURCE_REPO}}\n- Local scan report: {{LOCAL_SCAN_REPORT}}\n"
        )

    def _vault_why_researched(self) -> str:
        project_summary = self.analysis.get("project_summary", "No summary available.")
        architecture_summary = self.analysis.get("architecture_summary", "")
        return "\n".join(
            [
                project_summary,
                architecture_summary,
            ]
        ).strip()

    def _vault_bullet_block(self, items: List[str]) -> str:
        if not items:
            return "- No items were highlighted."
        return "\n".join(f"- {item}" for item in items[:8])

    def _vault_file_block(self, useful_files: List[Dict[str, Any]]) -> str:
        if not useful_files:
            return "- No high-signal files were flagged."
        lines = []
        for item in useful_files[:8]:
            lines.append(f"- `{item.get('path')}` - {item.get('category', 'other')}")
        return "\n".join(lines)

    def _vault_risk_block(self) -> str:
        risks = self.analysis.get("knowledge", {}).get("risks", [])
        licenses = self.analysis.get("licenses", [])
        lines = []
        if risks:
            lines.extend(f"- {item}" for item in risks[:6])
        if licenses:
            lines.append("- Licence candidates were detected and should be reviewed before reuse.")
        if not lines:
            lines.append("- No major static risks were detected by the safe scan.")
        return "\n".join(lines)

    def _vault_ignore_block(self) -> str:
        notes = [
            "Ignore low-signal binaries unless they are directly relevant to the task.",
            "Ignore generated output and build artifacts when reviewing the source architecture.",
        ]
        return "\n".join(f"- {note}" for note in notes)

    def _render_risk_report(self) -> str:
        lines = [
            "# Risk Report",
            "",
            "## Risk Flags",
        ]
        risk_flags = self.analysis.get("risk_flags", [])
        if risk_flags:
            for item in risk_flags[:100]:
                extra = item.get("masked_excerpt")
                suffix = f" - {extra}" if extra else ""
                lines.append(
                    f"- `{item.get('path')}` - {item.get('severity', 'unknown')} - {', '.join(item.get('risk_matches') or item.get('flags') or [])}{suffix}"
                )
        else:
            lines.append("- No major static risks were detected.")

        lines += ["", "## Guidance"]
        lines += [
            "- Review every high-severity item manually before adapting code.",
            "- Keep any sensitive values masked in notes and exports.",
            "- Prefer learning patterns over copying code directly.",
        ]
        return "\n".join(lines).rstrip() + "\n"

    def _render_knowledge_report(self) -> str:
        knowledge = self.analysis.get("knowledge", {})
        lines = [
            "# Knowledge Report",
            "",
            "## Project Summary",
            knowledge.get("project_summary", "No project summary available."),
            "",
            "## Architecture Summary",
            knowledge.get("architecture_summary", "No architecture summary available."),
            "",
            "## Reusable Components",
        ]
        for item in knowledge.get("reusable_components", []):
            lines.append(f"- {item}")

        lines += ["", "## Risks"]
        for item in knowledge.get("risks", []):
            lines.append(f"- {item}")

        lines += ["", "## Recommendations"]
        for item in knowledge.get("recommendations", []):
            lines.append(f"- {item}")
        return "\n".join(lines).rstrip() + "\n"

    def _render_implementation_opportunities(self) -> str:
        lines = [
            "# Implementation Opportunities",
            "",
            "## Ideas",
        ]
        for item in self.analysis.get("implementation_ideas", []):
            lines.append(f"- {item}")

        lines += ["", "## Reusable Components"]
        for item in self.analysis.get("reusable_components", []):
            lines.append(f"- {item}")
        return "\n".join(lines).rstrip() + "\n"

    def _render_learning_notes(self) -> str:
        lines = [
            "# Learning Notes",
            "",
            "## Notes",
        ]
        for item in self.analysis.get("learning_notes", []):
            lines.append(f"- {item}")
        return "\n".join(lines).rstrip() + "\n"

    def _render_template_selection(self, templates: Dict[str, Any]) -> str:
        lines = [
            "# Report Template Selection",
            "",
            "## Selected Templates",
        ]
        if templates:
            for key, value in templates.items():
                lines.append(f"- {key}: `{value}`")
        else:
            lines.append("- No template mapping was provided by the profile.")
        return "\n".join(lines).rstrip() + "\n"
