from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List
import json

DEFAULT_PROFILE_FIELDS: Dict[str, Any] = {
    "template_set": "Generic",
    "template_set_description": "Balanced local-first research bundle for general repositories.",
    "priority_keywords": [],
    "ignore_keywords": [],
    "risk_keywords": [],
    "useful_file_patterns": [],
    "output_focus": [],
    "export_targets": [],
    "export_locations": [],
    "report_templates": {
        "main_report": "repo_research_report.md",
        "summary": "repo_summary.md",
        "security": "security_report.md",
        "risk": "risk_report.md",
        "knowledge": "knowledge_report.md",
        "implementation_opportunities": "implementation_opportunities.md",
        "learning_notes": "learning_notes.md",
    },
}

REQUIRED_FIELDS = {"profile_name", "project_type"}
REQUIRED_REPORT_TEMPLATE_KEYS = {
    "main_report",
    "summary",
    "security",
    "risk",
    "knowledge",
    "implementation_opportunities",
    "learning_notes",
}


@dataclass(frozen=True)
class ProfileSpec:
    path: Path
    data: Dict[str, Any]

    @property
    def profile_name(self) -> str:
        return str(self.data.get("profile_name", self.path.stem))


class ProfileManager:
    def __init__(self, profiles_dir: str | Path) -> None:
        self.profiles_dir = Path(profiles_dir).expanduser().resolve()
        if not self.profiles_dir.exists():
            raise ValueError(f"Profiles directory does not exist: {self.profiles_dir}")

    def list_profiles(self) -> List[ProfileSpec]:
        profiles = []
        for path in sorted(self.profiles_dir.glob("*.profile.json")):
            profiles.append(ProfileSpec(path=path, data=self._load_json(path)))
        return profiles

    def load_profile(self, profile_ref: str | Path) -> Dict[str, Any]:
        candidate = Path(profile_ref)
        if candidate.exists():
            return self._normalise_profile(candidate, self._load_json(candidate))

        resolved = self._resolve_profile_name(str(profile_ref))
        if resolved is None:
            available = ", ".join(spec.profile_name for spec in self.list_profiles())
            raise ValueError(f"Unknown profile '{profile_ref}'. Available profiles: {available}")
        return self._normalise_profile(resolved.path, resolved.data)

    def save_profile(self, profile: Dict[str, Any], destination: str | Path) -> Path:
        destination_path = Path(destination)
        destination_path.parent.mkdir(parents=True, exist_ok=True)
        destination_path.write_text(json.dumps(profile, indent=2), encoding="utf-8")
        return destination_path

    def _resolve_profile_name(self, profile_ref: str) -> ProfileSpec | None:
        normalised = self._slugify(profile_ref)
        for spec in self.list_profiles():
            if self._slugify(spec.profile_name) == normalised or self._slugify(spec.path.stem) == normalised:
                return spec
        return None

    def _normalise_profile(self, source_path: Path, data: Dict[str, Any]) -> Dict[str, Any]:
        profile = dict(DEFAULT_PROFILE_FIELDS)
        profile.update(data)
        profile.setdefault("profile_name", source_path.stem)
        profile.setdefault("project_type", "generic local-first repository")
        profile.setdefault("template_set", profile.get("profile_name", "Generic"))
        profile.setdefault("template_set_description", "")
        profile.setdefault("export_locations", [])
        profile.setdefault("report_templates", dict(DEFAULT_PROFILE_FIELDS["report_templates"]))
        profile["profile_path"] = str(source_path)
        self._validate_profile(profile)
        return profile

    def _validate_profile(self, profile: Dict[str, Any]) -> None:
        missing = [field for field in REQUIRED_FIELDS if not profile.get(field)]
        if missing:
            raise ValueError(f"Profile is missing required fields: {', '.join(missing)}")

        report_templates = profile.get("report_templates")
        if not isinstance(report_templates, dict):
            raise ValueError("Profile report_templates must be a JSON object")

        missing_templates = [
            key
            for key in sorted(REQUIRED_REPORT_TEMPLATE_KEYS)
            if not str(report_templates.get(key, "")).strip()
        ]
        if missing_templates:
            joined = ", ".join(missing_templates)
            raise ValueError(
                f"Profile report_templates are missing required keys: {joined}",
            )

    def _load_json(self, path: Path) -> Dict[str, Any]:
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise ValueError(f"Profile JSON could not be parsed: {path}") from exc

    def _slugify(self, value: str) -> str:
        slug = value.strip().lower()
        slug = slug.replace(" ", "_")
        slug = slug.replace("-", "_")
        slug = "".join(ch for ch in slug if ch.isalnum() or ch == "_")
        while "__" in slug:
            slug = slug.replace("__", "_")
        return slug.strip("_")
