from __future__ import annotations

from collections import Counter
from typing import Any, Dict, Iterable, List, Sequence


class RepoComparisonEngine:
    def __init__(self, current: Dict[str, Any], other: Dict[str, Any]) -> None:
        self.current = current
        self.other = other

    def compare(self) -> Dict[str, Any]:
        current_files = self._file_map(self.current)
        other_files = self._file_map(self.other)

        current_paths = set(current_files)
        other_paths = set(other_files)

        added = sorted(current_paths - other_paths)
        removed = sorted(other_paths - current_paths)
        shared = sorted(current_paths & other_paths)
        modified = sorted(
            path
            for path in shared
            if self._is_modified(current_files[path], other_files[path])
        )

        category_deltas = self._delta_counts(
            self.current.get("category_counts", {}),
            self.other.get("category_counts", {}),
        )
        language_deltas = self._delta_counts(
            self.current.get("language_counts", {}),
            self.other.get("language_counts", {}),
        )
        framework_changes = self._compare_named_lists(
            [item.get("name", "") for item in self.current.get("frameworks", [])],
            [item.get("name", "") for item in self.other.get("frameworks", [])],
        )
        dependency_changes = self._compare_named_lists(
            self.current.get("dependency_summary", {}).get("dependency_names", []),
            self.other.get("dependency_summary", {}).get("dependency_names", []),
        )
        license_changes = self._compare_named_lists(
            self._license_names(self.current),
            self._license_names(self.other),
        )

        return {
            "current_repo": self.current.get("repo_name"),
            "other_repo": self.other.get("repo_name"),
            "current_path": self.current.get("repo_path"),
            "other_path": self.other.get("repo_path"),
            "file_count_delta": self._delta(
                self.current.get("file_count", 0), self.other.get("file_count", 0)
            ),
            "directory_count_delta": self._delta(
                self.current.get("directory_count", 0), self.other.get("directory_count", 0)
            ),
            "category_deltas": category_deltas,
            "language_deltas": language_deltas,
            "files_added": added,
            "files_removed": removed,
            "files_shared": shared[:200],
            "files_modified": modified,
            "file_details": {
                "added": [self._file_snapshot(current_files[path]) for path in added[:120]],
                "removed": [self._file_snapshot(other_files[path]) for path in removed[:120]],
                "modified": [
                    {
                        "path": path,
                        "current": self._file_snapshot(current_files[path]),
                        "other": self._file_snapshot(other_files[path]),
                        "changes": self._describe_changes(current_files[path], other_files[path]),
                    }
                    for path in modified[:120]
                ],
            },
            "framework_changes": framework_changes,
            "dependency_changes": dependency_changes,
            "license_changes": license_changes,
            "summary": self._summary(added, removed, modified, framework_changes, dependency_changes),
            "recommendations": self._recommendations(category_deltas, added, removed),
        }

    def _file_map(self, scan: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
        return {
            str(item.get("path", "")): item
            for item in scan.get("files", [])
            if str(item.get("path", "")).strip()
        }

    def _delta_counts(self, current: Dict[str, int], other: Dict[str, int]) -> Dict[str, int]:
        keys = set(current) | set(other)
        return {
            key: int(current.get(key, 0)) - int(other.get(key, 0))
            for key in sorted(keys)
        }

    def _compare_named_lists(
        self,
        current: Sequence[str],
        other: Sequence[str],
    ) -> Dict[str, List[str]]:
        current_set = {item.strip() for item in current if item and item.strip()}
        other_set = {item.strip() for item in other if item and item.strip()}
        return {
            "added": sorted(current_set - other_set),
            "removed": sorted(other_set - current_set),
            "shared": sorted(current_set & other_set),
        }

    def _delta(self, current: int, other: int) -> int:
        return int(current) - int(other)

    def _file_snapshot(self, record: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "path": record.get("path", ""),
            "category": record.get("category", ""),
            "language": record.get("language", ""),
            "suffix": record.get("suffix", ""),
            "size_bytes": record.get("size_bytes", 0),
            "flags": sorted(set(record.get("flags", []) or [])),
        }

    def _describe_changes(self, current: Dict[str, Any], other: Dict[str, Any]) -> List[str]:
        changes: List[str] = []
        for key, label in (
            ("suffix", "suffix"),
            ("size_bytes", "size"),
            ("category", "category"),
            ("language", "language"),
        ):
            if current.get(key) != other.get(key):
                changes.append(f"{label}: {other.get(key)} -> {current.get(key)}")

        current_flags = sorted(set(current.get("flags", []) or []))
        other_flags = sorted(set(other.get("flags", []) or []))
        if current_flags != other_flags:
            changes.append(
                f"flags: {', '.join(other_flags) or 'none'} -> {', '.join(current_flags) or 'none'}",
            )
        return changes or ["content or metadata changed"]

    def _license_names(self, scan: Dict[str, Any]) -> List[str]:
        values = []
        for item in scan.get("licenses", []) or scan.get("license_detection", []):
            if isinstance(item, dict):
                value = item.get("detected_license") or item.get("license") or item.get("license_name")
            else:
                value = str(item)
            if value and str(value).strip():
                values.append(str(value).strip())
        return values

    def _summary(
        self,
        added: Sequence[str],
        removed: Sequence[str],
        modified: Sequence[str],
        framework_changes: Dict[str, List[str]],
        dependency_changes: Dict[str, List[str]],
    ) -> str:
        parts = [
            f"{len(added)} files added",
            f"{len(removed)} files removed",
            f"{len(modified)} files modified",
        ]
        if framework_changes["added"] or framework_changes["removed"]:
            parts.append("framework signals changed")
        if dependency_changes["added"] or dependency_changes["removed"]:
            parts.append("dependencies changed")
        return ", ".join(parts) + "."

    def _is_modified(self, current: Dict[str, Any], other: Dict[str, Any]) -> bool:
        keys_to_compare = ("suffix", "size_bytes", "category", "language")
        for key in keys_to_compare:
            if current.get(key) != other.get(key):
                return True

        current_flags = sorted(set(current.get("flags", []) or []))
        other_flags = sorted(set(other.get("flags", []) or []))
        return current_flags != other_flags

    def _recommendations(
        self,
        category_deltas: Dict[str, int],
        added: Sequence[str],
        removed: Sequence[str],
    ) -> List[str]:
        recommendations = []
        if added:
            recommendations.append("Review newly added files before adapting anything from the repository.")
        if removed:
            recommendations.append("Check whether removed files indicate a refactor or a missing capability.")
        if category_deltas.get("documentation", 0) > 0:
            recommendations.append("Revisit the updated documentation for architectural clues.")
        if category_deltas.get("script", 0) > 0:
            recommendations.append("Treat new scripts as untrusted and review them manually.")
        return recommendations or [
            "The repositories are broadly similar, so focus on the most recent useful files."
        ]


class ChangeTracker:
    def __init__(self, current: Dict[str, Any], baseline: Dict[str, Any]) -> None:
        self.current = current
        self.baseline = baseline

    def track(self) -> Dict[str, Any]:
        comparison = RepoComparisonEngine(self.current, self.baseline).compare()
        current_files = {item.get("path", ""): item for item in self.current.get("files", [])}
        baseline_files = {item.get("path", ""): item for item in self.baseline.get("files", [])}

        new_risks = self._risk_paths(self.current) - self._risk_paths(self.baseline)
        resolved_risks = self._risk_paths(self.baseline) - self._risk_paths(self.current)

        return {
            "current_repo": self.current.get("repo_name"),
            "baseline_repo": self.baseline.get("repo_name"),
            "summary": comparison["summary"],
            "file_changes": {
                "added": comparison["files_added"],
                "removed": comparison["files_removed"],
                "modified": comparison["files_modified"],
            },
            "category_deltas": comparison["category_deltas"],
            "new_risk_paths": sorted(new_risks),
            "resolved_risk_paths": sorted(resolved_risks),
            "recommendations": self._recommendations(new_risks, resolved_risks),
        }

    def _risk_paths(self, scan: Dict[str, Any]) -> set[str]:
        risk_paths: set[str] = set()
        for item in scan.get("files", []):
            path = str(item.get("path", ""))
            flags = item.get("flags", []) or []
            if path and flags:
                risk_paths.add(path)
        for finding in scan.get("security", {}).get("findings", []) or []:
            path = str(finding.get("path", ""))
            if path:
                risk_paths.add(path)
        return risk_paths

    def _recommendations(self, new_risks: set[str], resolved_risks: set[str]) -> List[str]:
        recommendations: List[str] = []
        if new_risks:
            recommendations.append("Review newly introduced risky files before adapting the repository.")
        if resolved_risks:
            recommendations.append("Confirm the resolved risks were intentionally addressed.")
        if not recommendations:
            recommendations.append("No major tracked changes were detected beyond the current file movement.")
        return recommendations
