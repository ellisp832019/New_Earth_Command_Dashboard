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
