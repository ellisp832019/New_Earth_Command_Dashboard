from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List, Sequence


class KnowledgeExtractor:
    def __init__(self, scan: Dict[str, Any], profile: Dict[str, Any], security: Dict[str, Any]) -> None:
        self.scan = scan
        self.profile = profile
        self.security = security

    def extract(self) -> Dict[str, Any]:
        repo_name = self.scan.get("repo_name", "Unknown repository")
        repo_path = self.scan.get("repo_path", "")
        category_counts = self.scan.get("category_counts", {})
        language_counts = self.scan.get("language_counts", {})
        frameworks = self.scan.get("frameworks", [])
        docs = self.scan.get("documents", [])
        document_index = self.scan.get("document_index", [])
        dependencies = self.scan.get("dependency_summary", {})
        license_summary = self.scan.get("license_summary", {})
        useful_files = self._useful_files()

        architecture_summary = self._architecture_summary(repo_name, frameworks, language_counts, dependencies)
        project_summary = self._project_summary(repo_name, repo_path, docs, frameworks, category_counts)
        learning_notes = self._learning_notes(useful_files, docs)
        implementation_ideas = self._implementation_ideas(frameworks, useful_files)
        reusable_components = self._reusable_components(useful_files)
        risks = self._knowledge_risks()
        recommendations = self._recommendations()
        document_highlights = self._document_highlights(document_index)

        return {
            "project_summary": project_summary,
            "architecture_summary": architecture_summary,
            "learning_notes": learning_notes,
            "implementation_ideas": implementation_ideas,
            "reusable_components": reusable_components,
            "risks": risks,
            "recommendations": recommendations,
            "useful_files": useful_files,
            "profile_focus": self.profile.get("output_focus", []),
            "license_summary": license_summary,
            "document_highlights": document_highlights,
        }

    def _useful_files(self) -> List[Dict[str, Any]]:
        keywords = [word.lower() for word in self.profile.get("priority_keywords", [])]
        useful: List[Dict[str, Any]] = []
        for record in self.scan.get("files", []):
            path = record.get("path", "")
            lower_path = path.lower()
            matches = [keyword for keyword in keywords if keyword and keyword in lower_path]
            if matches or record.get("category") in {"documentation", "firmware_or_code", "hardware_design", "configuration"}:
                useful.append(
                    {
                        "path": path,
                        "category": record.get("category", "other"),
                        "language": record.get("language", "Unknown"),
                        "matches": matches,
                        "flags": record.get("flags", []),
                    }
                )
        return useful[:100]

    def _project_summary(
        self,
        repo_name: str,
        repo_path: str,
        docs: Sequence[Dict[str, Any]],
        frameworks: Sequence[Dict[str, Any]],
        category_counts: Dict[str, int],
    ) -> str:
        docs_count = len(docs)
        docs_phrase = f"{docs_count} documentation file{'s' if docs_count != 1 else ''}" if docs_count else "no obvious documentation files"
        framework_phrase = self._join_names([item.get("name", "") for item in frameworks]) or "no strong framework signal yet"
        code_count = sum(category_counts.get(key, 0) for key in ("firmware_or_code", "script", "other"))
        binary_count = category_counts.get("binary_or_asset", 0)
        return (
            f"{repo_name} at `{repo_path}` appears to be a local-first repository with {docs_phrase}, "
            f"approximately {code_count} code or script files, {binary_count} binary or asset files, "
            f"and a primary framework signal of {framework_phrase}."
        )

    def _architecture_summary(
        self,
        repo_name: str,
        frameworks: Sequence[Dict[str, Any]],
        language_counts: Dict[str, int],
        dependencies: Dict[str, Any],
    ) -> str:
        top_languages = self._join_names(self._top_keys(language_counts))
        framework_names = self._join_names([item.get("name", "") for item in frameworks])
        dependency_count = dependencies.get("dependency_count", 0)
        manifest_count = len(dependencies.get("manifests", []))
        parts = [f"{repo_name} is structured as a local repository with {top_languages or 'mixed language'} assets."]
        if framework_names:
            parts.append(f"Framework signals point to {framework_names}.")
        if dependency_count:
            parts.append(
                f"The scan identified {dependency_count} named dependencies across {manifest_count} manifest file{'s' if manifest_count != 1 else ''}."
            )
        return " ".join(parts)

    def _learning_notes(self, useful_files: Sequence[Dict[str, Any]], docs: Sequence[Dict[str, Any]]) -> List[str]:
        notes: List[str] = []
        if docs:
            notes.append("Start with the README and docs because they usually explain the project model faster than code spelunking.")
        if useful_files:
            notes.append(
                "Review the highest-signal configuration and implementation files first, then trace the supporting modules around them."
            )
        if any(item.get("category") == "hardware_design" for item in useful_files):
            notes.append("Hardware design files are present, so keep firmware and schematic review paired together.")
        if any(item.get("category") == "documentation" for item in useful_files):
            notes.append("Documentation exists and should be treated as an asset for knowledge extraction, not as filler.")
        if self.security.get("summary"):
            notes.append("Keep all security details masked when reusing these notes in other reports or prompts.")
        return self._unique_nonempty(notes) or [
            "The repository needs a manual review pass because the scan only found limited high-signal files."
        ]

    def _implementation_ideas(self, frameworks: Sequence[Dict[str, Any]], useful_files: Sequence[Dict[str, Any]]) -> List[str]:
        ideas: List[str] = []
        framework_names = {item.get("name", "") for item in frameworks}
        if any("Flutter" in name for name in framework_names):
            ideas.append("Reuse the local Flutter patterns for calm dashboard pages and shared local storage.")
        if any("PlatformIO" in name or "ESP32" in name for name in framework_names):
            ideas.append("Keep firmware analysis focused on control loops, safety boundaries, and testability.")
        if useful_files:
            ideas.append("Turn the highest-value files into small, local New Earth tasks instead of copying whole implementations.")
        if "Node.js" in framework_names:
            ideas.append("Mirror the package and script structure only where it improves maintainability, not as a blind port.")
        return self._unique_nonempty(ideas) or [
            "Use the repository as a reference for structure, naming, and local workflows only after manual review."
        ]

    def _reusable_components(self, useful_files: Sequence[Dict[str, Any]]) -> List[str]:
        components: List[str] = []
        seen: set[str] = set()
        for item in useful_files[:12]:
            label = f"{item.get('path')} ({item.get('category')})"
            if label not in seen:
                seen.add(label)
                components.append(label)
        return components or ["No obvious reusable components were detected by the scanner."]

    def _knowledge_risks(self) -> List[str]:
        security_summary = self.security.get("summary", {})
        risks: List[str] = []
        if security_summary.get("high", 0):
            risks.append("High-severity security signals were detected and must be reviewed before any adaptation.")
        if security_summary.get("medium", 0):
            risks.append("Medium-severity security signals were detected and should stay masked in all exports.")
        if security_summary.get("high", 0) or security_summary.get("medium", 0):
            risks.append("Security excerpts are intentionally masked so the knowledge bundle stays safe to share locally.")
        if not risks:
            risks.append("No major static security risk signals were detected by the safe scan, but manual review is still required.")
        return self._unique_nonempty(risks)

    def _recommendations(self) -> List[str]:
        profile_name = str(self.profile.get("profile_name", "the project"))
        return [
            f"Summarise the repository for {profile_name} using the calmest useful language and keep the actionable items short.",
            "Review the license file before adapting any code or design patterns.",
            "Use the top useful files as the manual review queue and keep everything else parked for later.",
        ]

    def _top_keys(self, mapping: Dict[str, int], limit: int = 4) -> List[str]:
        return [key for key, _ in sorted(mapping.items(), key=lambda item: (-item[1], item[0]))[:limit]]

    def _join_names(self, names: Sequence[str]) -> str:
        filtered = [name for name in names if name]
        if not filtered:
            return ""
        if len(filtered) == 1:
            return filtered[0]
        if len(filtered) == 2:
            return f"{filtered[0]} and {filtered[1]}"
        return ", ".join(filtered[:-1]) + f", and {filtered[-1]}"

    def _unique_nonempty(self, values: Sequence[str]) -> List[str]:
        unique: List[str] = []
        seen: set[str] = set()
        for value in values:
            text = str(value).strip()
            if not text or text in seen:
                continue
            seen.add(text)
            unique.append(text)
        return unique

    def _document_highlights(self, document_index: Sequence[Dict[str, Any]]) -> List[str]:
        highlights: List[str] = []
        for item in document_index[:12]:
            title = str(item.get("title", "")).strip() or str(item.get("path", "")).strip()
            heading_count = int(item.get("heading_count", 0))
            link_count = int(item.get("link_count", 0))
            table_count = int(item.get("table_count", 0))
            parts = []
            if heading_count:
                parts.append(f"{heading_count} headings")
            if link_count:
                parts.append(f"{link_count} links")
            if table_count:
                parts.append(f"{table_count} tables")
            if not parts:
                parts.append("text index only")
            highlights.append(f"{title} - {', '.join(parts)}")
        return self._unique_nonempty(highlights)
