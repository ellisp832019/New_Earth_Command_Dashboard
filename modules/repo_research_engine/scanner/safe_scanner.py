from __future__ import annotations

from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Sequence
import datetime as _dt
import json
import re
try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - fallback for older Python versions
    tomllib = None  # type: ignore[assignment]

IGNORE_DIRS = {
    ".git",
    ".idea",
    ".vscode",
    ".dart_tool",
    ".pytest_cache",
    ".venv",
    "__pycache__",
    "build",
    "dist",
    "node_modules",
    "target",
    "vendor",
    ".gradle",
    ".pio",
    ".husky",
    ".cache",
}

BINARY_EXTS = {
    ".7z",
    ".avi",
    ".bin",
    ".dll",
    ".dmg",
    ".elf",
    ".exe",
    ".gif",
    ".ico",
    ".jpg",
    ".jpeg",
    ".mov",
    ".mp3",
    ".mp4",
    ".pdf",
    ".png",
    ".rar",
    ".so",
    ".svg",
    ".wav",
    ".webp",
    ".zip",
}

IMAGE_EXTS = {".gif", ".ico", ".jpg", ".jpeg", ".png", ".svg", ".webp"}
DIAGRAM_SOURCE_EXTS = {".drawio", ".gv", ".mmd", ".mermaid", ".dot", ".puml", ".plantuml", ".uml"}

SCRIPT_EXTS = {".sh", ".ps1", ".bat", ".cmd", ".py"}
DOC_EXTS = {".md", ".txt", ".rst", ".adoc", ".org"}
CONFIG_EXTS = {".json", ".yaml", ".yml", ".toml", ".ini", ".env", ".cfg"}
FIRMWARE_EXTS = {".ino", ".cpp", ".c", ".h", ".hpp", ".cc", ".cxx"}
HARDWARE_EXTS = {
    ".brd",
    ".dxf",
    ".kicad_pcb",
    ".kicad_sch",
    ".sch",
    ".pcb",
    ".step",
    ".stp",
}

LICENSE_FILE_NAMES = {
    "license",
    "license.md",
    "license.txt",
    "licence",
    "licence.md",
    "copying",
    "copyright",
}

RISK_TERMS = (
    "secret",
    "password",
    "token",
    "private_key",
    "credential",
    "api_key",
    "apikey",
    "oauth",
    "aws_access_key",
)

LICENSE_PATTERNS = (
    ("MIT", re.compile(r"\bmit license\b", re.IGNORECASE)),
    ("Apache-2.0", re.compile(r"\bapache license\b.*\bversion 2\.0\b", re.IGNORECASE | re.DOTALL)),
    ("GPL", re.compile(r"\bgnu general public license\b", re.IGNORECASE)),
    ("BSD", re.compile(r"\bbsd license\b", re.IGNORECASE)),
    ("ISC", re.compile(r"\bisc license\b", re.IGNORECASE)),
    ("MPL", re.compile(r"\bmozilla public license\b", re.IGNORECASE)),
    ("Unlicense", re.compile(r"\bunlicense\b", re.IGNORECASE)),
)

LANGUAGE_EXTENSIONS = {
    ".dart": "Dart",
    ".py": "Python",
    ".ts": "TypeScript",
    ".tsx": "TypeScript/React",
    ".js": "JavaScript",
    ".jsx": "JavaScript/React",
    ".json": "JSON",
    ".yaml": "YAML",
    ".yml": "YAML",
    ".toml": "TOML",
    ".md": "Markdown",
    ".sql": "SQL",
    ".cpp": "C++",
    ".c": "C",
    ".h": "C/C++ Header",
    ".hpp": "C++ Header",
    ".ino": "Arduino",
    ".ps1": "PowerShell",
    ".sh": "Shell",
    ".html": "HTML",
    ".css": "CSS",
    ".xml": "XML",
    ".rs": "Rust",
    ".go": "Go",
    ".java": "Java",
    ".kt": "Kotlin",
    ".swift": "Swift",
}

DEPENDENCY_MANIFEST_NAMES = {
    "package.json",
    "pubspec.yaml",
    "requirements.txt",
    "pyproject.toml",
    "poetry.lock",
    "cargo.toml",
    "go.mod",
    "platformio.ini",
    "makefile",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
}


@dataclass(frozen=True)
class FileRecord:
    path: str
    suffix: str
    size_bytes: int
    category: str
    language: str
    flags: List[str]
    directory: str


class SafeRepoScanner:
    def __init__(
        self,
        repo_path: str,
        max_file_size: int = 1_000_000,
        content_sample_limit: int = 200_000,
    ) -> None:
        self.repo = Path(repo_path).expanduser().resolve()
        self.max_file_size = max_file_size
        self.content_sample_limit = content_sample_limit
        if not self.repo.exists() or not self.repo.is_dir():
            raise ValueError(f"Repo path does not exist or is not a directory: {self.repo}")

    def classify(self, p: Path) -> str:
        name = p.name.lower()
        suffix = p.suffix.lower()
        if name.startswith("readme") or suffix in DOC_EXTS or name in {"docs", "changelog"}:
            return "documentation"
        if suffix in CONFIG_EXTS or name in {"dockerfile", "makefile"}:
            return "configuration"
        if suffix in HARDWARE_EXTS:
            return "hardware_design"
        if suffix in {".ino"} or suffix in FIRMWARE_EXTS:
            return "firmware_or_code"
        if suffix in SCRIPT_EXTS:
            return "script"
        if suffix in BINARY_EXTS:
            return "binary_or_asset"
        return "other"

    def detect_language(self, p: Path) -> str:
        name = p.name.lower()
        suffix = p.suffix.lower()
        if name == "dockerfile":
            return "Docker"
        if name == "makefile":
            return "Make"
        return LANGUAGE_EXTENSIONS.get(suffix, "Unknown")

    def flags_for(self, p: Path, size: int) -> List[str]:
        flags: List[str] = []
        lower = str(p).lower()
        name = p.name.lower()
        suffix = p.suffix.lower()

        if size > self.max_file_size:
            flags.append("large_file_skipped_for_content_read")
        if suffix in BINARY_EXTS:
            flags.append("binary_or_asset_do_not_parse_as_text")
        if suffix in SCRIPT_EXTS or name in {"dockerfile", "makefile"}:
            flags.append("script_present_do_not_execute")
        if any(term in lower for term in RISK_TERMS):
            flags.append("possible_secret_or_credential_path")
        if suffix in {".pem", ".key", ".crt", ".cer", ".pfx", ".p12"}:
            flags.append("certificate_or_private_key_candidate")
        if name.startswith(".env"):
            flags.append("environment_file_check_for_secrets")
        if suffix in HARDWARE_EXTS:
            flags.append("hardware_design_file_review_manually")
        return flags

    def scan(self) -> Dict[str, Any]:
        files: List[FileRecord] = []
        category_counts: Counter[str] = Counter()
        language_counts: Counter[str] = Counter()
        docs: List[Dict[str, Any]] = []
        document_index: List[Dict[str, Any]] = []
        image_assets: List[Dict[str, Any]] = []
        diagram_files: List[Dict[str, Any]] = []
        manifest_files: List[Dict[str, Any]] = []
        license_candidates: List[Dict[str, Any]] = []
        known_licenses: set[str] = set()
        unknown_license_count = 0
        directories: set[str] = set()

        for p in self.repo.rglob("*"):
            if p.is_dir():
                continue
            if self._is_ignored(p):
                continue
            try:
                size = p.stat().st_size
            except OSError:
                continue

            category = self.classify(p)
            language = self.detect_language(p)
            flags = self.flags_for(p, size)
            record = FileRecord(
                path=str(p.relative_to(self.repo)),
                suffix=p.suffix.lower(),
                size_bytes=size,
                category=category,
                language=language,
                flags=flags,
                directory=str(p.relative_to(self.repo).parent).replace("\\", "/"),
            )
            files.append(record)
            category_counts[category] += 1
            language_counts[language] += 1

            if category == "documentation":
                doc_text = self._safe_read_text(p)
                doc_summary = self._index_document(record, doc_text)
                docs.append(
                    {
                        "path": record.path,
                        "language": language,
                        "size_bytes": size,
                        "flags": flags,
                        "document_type": doc_summary.get("document_type", "documentation"),
                        "title": doc_summary.get("title", ""),
                    }
                )
                document_index.append(doc_summary)
                if self._contains_diagram_markers(doc_text):
                    diagram_files.append(self._index_diagram_source(record, doc_text, source_kind="embedded_markdown"))
            if self._looks_like_image_asset(p):
                image_asset = self._index_image_asset(record)
                image_assets.append(image_asset)
                if image_asset.get("asset_type") == "diagram":
                    diagram_files.append(self._index_diagram_source(record, "", source_kind="image_asset"))
            if self._looks_like_diagram_source(p):
                diagram_text = self._safe_read_text(p)
                diagram_files.append(self._index_diagram_source(record, diagram_text))
            if self._is_dependency_manifest(p):
                manifest_files.append({"path": record.path, "suffix": record.suffix, "size_bytes": size})
            if self._looks_like_license_file(p):
                detected_license = self._detect_license_text(self._safe_read_text(p))
                if detected_license == "Unknown":
                    unknown_license_count += 1
                else:
                    known_licenses.add(detected_license)
                license_candidates.append(
                    {
                        "path": record.path,
                        "candidate_type": self._license_candidate_type(p),
                        "detected_license": detected_license,
                        "review_status": (
                            "known" if detected_license != "Unknown" else "needs_review"
                        ),
                    }
                )

            self._accumulate_directories(directories, p)

        dependency_summary = self._detect_dependencies(files)
        frameworks = self._detect_frameworks(files, dependency_summary)
        repository_tree = self._build_tree(files)

        return {
            "repo_path": str(self.repo),
            "repo_name": self.repo.name,
            "scanned_at": _dt.datetime.now().isoformat(timespec="seconds"),
            "file_count": len(files),
            "directory_count": len(directories),
            "category_counts": dict(sorted(category_counts.items())),
            "language_counts": dict(sorted(language_counts.items())),
            "frameworks": frameworks,
            "documents": docs,
            "document_index": document_index,
            "image_assets": image_assets,
            "diagram_files": diagram_files,
            "license_detection": license_candidates,
            "license_summary": {
                "candidate_count": len(license_candidates),
                "known_licenses": sorted(known_licenses),
                "unknown_candidate_count": unknown_license_count,
            },
            "dependency_summary": dependency_summary,
            "files": [asdict(f) for f in files],
            "repository_tree": repository_tree,
            "scan_notes": [
                "Read-only scan only.",
                "No code execution performed.",
                "Binary, script, and credential-looking files were flagged for manual review.",
            ],
        }

    def save(self, out_path: str) -> None:
        output = Path(out_path)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(self.scan(), indent=2), encoding="utf-8")

    def _is_ignored(self, path: Path) -> bool:
        rel_parts = path.relative_to(self.repo).parts
        return any(part in IGNORE_DIRS for part in rel_parts)

    def _accumulate_directories(self, directories: set[str], path: Path) -> None:
        relative_parent = path.relative_to(self.repo).parent
        if str(relative_parent) not in {".", ""}:
            parts = relative_parent.parts
            for index in range(1, len(parts) + 1):
                directories.add("/".join(parts[:index]))

    def _is_dependency_manifest(self, path: Path) -> bool:
        return path.name.lower() in DEPENDENCY_MANIFEST_NAMES

    def _looks_like_license_file(self, path: Path) -> bool:
        name = path.name.lower()
        return name in LICENSE_FILE_NAMES or name.startswith("license.") or name.startswith("licence.")

    def _license_candidate_type(self, path: Path) -> str:
        name = path.name.lower()
        if name.startswith("license"):
            return "license"
        if name.startswith("licence"):
            return "licence"
        if name.startswith("copying"):
            return "copying"
        if name.startswith("copyright"):
            return "copyright"
        return "candidate"

    def _safe_read_text(self, path: Path) -> str:
        try:
            if path.stat().st_size > self.content_sample_limit:
                return path.read_text(encoding="utf-8", errors="ignore")[: self.content_sample_limit]
            return path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            return ""

    def _index_document(self, record: FileRecord, text: str) -> Dict[str, Any]:
        document_type = "markdown" if record.suffix.lower() == ".md" else "text"
        headings = self._extract_markdown_headings(text) if document_type == "markdown" else []
        links = self._extract_markdown_links(text) if document_type == "markdown" else []
        tables = self._extract_markdown_tables(text) if document_type == "markdown" else []
        reference_notes = self._extract_reference_notes(text) if document_type == "markdown" else []
        title = self._document_title(text, record.path, headings)
        return {
            "path": record.path,
            "document_type": document_type,
            "title": title,
            "heading_count": len(headings),
            "headings": headings[:20],
            "link_count": len(links),
            "links": links[:20],
            "table_count": len(tables),
            "table_samples": tables[:10],
            "reference_note_count": len(reference_notes),
            "reference_notes": reference_notes[:12],
            "word_count": len(re.findall(r"\b\S+\b", text)),
        }

    def _looks_like_image_asset(self, path: Path) -> bool:
        suffix = path.suffix.lower()
        return suffix in IMAGE_EXTS

    def _looks_like_diagram_source(self, path: Path) -> bool:
        suffix = path.suffix.lower()
        name = path.name.lower()
        return suffix in DIAGRAM_SOURCE_EXTS or name.endswith(".drawio.svg")

    def _contains_diagram_markers(self, text: str) -> bool:
        lowered = text.lower()
        markers = (
            "```mermaid",
            "flowchart",
            "sequencediagram",
            "classdiagram",
            "statediagram",
            "erdiagram",
            "@startuml",
            "@enduml",
            "<mxfile",
            "digraph ",
        )
        return any(marker in lowered for marker in markers)

    def _index_image_asset(self, record: FileRecord) -> Dict[str, Any]:
        path = record.path.lower()
        asset_type = "image_asset"
        if any(term in path for term in ("screenshot", "screen_capture", "screen-shot", "ui_preview", "preview")):
            asset_type = "screenshot"
        elif any(term in path for term in ("icon", "logo", "favicon", "badge")):
            asset_type = "icon"
        elif any(term in path for term in ("diagram", "flow", "graph", "architecture", "schema")):
            asset_type = "diagram"
        elif any(term in path for term in ("mockup", "wireframe", "design", "illustration", "asset")):
            asset_type = "design_asset"

        hints = []
        if asset_type == "screenshot":
            hints.append("review ui flow visually")
        if asset_type == "icon":
            hints.append("likely brand or navigation asset")
        if asset_type == "diagram":
            hints.append("review alongside architecture notes")
        if asset_type == "design_asset":
            hints.append("may be a presentation or product design asset")
        if not hints:
            hints.append("binary asset - inspect manually")

        return {
            "path": record.path,
            "asset_type": asset_type,
            "size_bytes": record.size_bytes,
            "flags": record.flags,
            "language": record.language,
            "hints": hints,
        }

    def _index_diagram_source(
        self,
        record: FileRecord,
        text: str,
        *,
        source_kind: str = "source_file",
    ) -> Dict[str, Any]:
        lowered = text.lower()
        name = Path(record.path).name.lower()
        if source_kind == "embedded_markdown":
            diagram_type = "embedded_markdown_diagram"
        elif source_kind == "image_asset":
            diagram_type = "diagram_image_asset"
        elif record.suffix.lower() in {".mmd", ".mermaid"}:
            diagram_type = "mermaid"
        elif record.suffix.lower() in {".puml", ".plantuml", ".uml"}:
            diagram_type = "plantuml"
        elif record.suffix.lower() in {".dot", ".gv"}:
            diagram_type = "graphviz"
        elif record.suffix.lower() == ".drawio" or name.endswith(".drawio.svg"):
            diagram_type = "drawio"
        else:
            diagram_type = "diagram"

        markers = []
        for marker, label in (
            ("flowchart", "flowchart"),
            ("sequenceDiagram", "sequence diagram"),
            ("classDiagram", "class diagram"),
            ("stateDiagram", "state diagram"),
            ("erDiagram", "entity relationship diagram"),
            ("@startuml", "plantuml"),
            ("<mxfile", "drawio"),
            ("digraph", "graphviz"),
        ):
            if marker.lower() in lowered:
                markers.append(label)

        return {
            "path": record.path,
            "diagram_type": diagram_type,
            "source_kind": source_kind,
            "size_bytes": record.size_bytes,
            "flags": record.flags,
            "language": record.language,
            "markers": markers or [diagram_type],
        }

    def _detect_license_text(self, text: str) -> str:
        if not text.strip():
            return "Unknown"
        for name, pattern in LICENSE_PATTERNS:
            if pattern.search(text):
                return name
        return "Unknown"

    def _document_title(
        self,
        text: str,
        fallback_path: str,
        headings: Sequence[Dict[str, Any]],
    ) -> str:
        for heading in headings:
            title = str(heading.get("text", "")).strip()
            if title:
                return title
        for line in text.splitlines():
            stripped = line.strip().lstrip("#").strip()
            if stripped:
                return stripped[:120]
        return fallback_path

    def _extract_markdown_headings(self, text: str) -> List[Dict[str, Any]]:
        headings: List[Dict[str, Any]] = []
        for line in text.splitlines():
            stripped = line.lstrip()
            if not stripped.startswith("#"):
                continue
            level = len(stripped) - len(stripped.lstrip("#"))
            title = stripped[level:].strip()
            if title:
                headings.append({"level": level, "text": title})
        return headings

    def _extract_markdown_links(self, text: str) -> List[Dict[str, Any]]:
        links: List[Dict[str, Any]] = []
        seen: set[tuple[str, str]] = set()
        for label, target in re.findall(r"\[([^\]]+)\]\(([^)]+)\)", text):
            key = (label.strip(), target.strip())
            if key in seen:
                continue
            seen.add(key)
            links.append({"label": label.strip(), "target": target.strip(), "style": "inline"})
        reference_targets = {
            match.group(1).strip(): match.group(2).strip()
            for match in re.finditer(r"^\[([^\]]+)\]:\s*(\S+)", text, flags=re.MULTILINE)
        }
        for label, ref in re.findall(r"\[([^\]]+)\]\[([^\]]+)\]", text):
            target = reference_targets.get(ref.strip())
            if not target:
                continue
            key = (label.strip(), target)
            if key in seen:
                continue
            seen.add(key)
            links.append({"label": label.strip(), "target": target, "style": "reference"})
        return links

    def _extract_markdown_tables(self, text: str) -> List[Dict[str, Any]]:
        tables: List[Dict[str, Any]] = []
        lines = text.splitlines()
        index = 0
        while index < len(lines) - 1:
            current = lines[index].strip()
            next_line = lines[index + 1].strip()
            if "|" in current and re.fullmatch(r"[:\-\|\s]+", next_line):
                rows = [current]
                cursor = index + 2
                while cursor < len(lines):
                    candidate = lines[cursor].strip()
                    if not candidate or "|" not in candidate:
                        break
                    rows.append(candidate)
                    cursor += 1
                tables.append({"row_count": len(rows), "sample": rows[:4]})
                index = cursor
                continue
            index += 1
        return tables

    def _extract_reference_notes(self, text: str) -> List[str]:
        notes: List[str] = []
        for line in text.splitlines():
            stripped = line.strip()
            if re.match(r"^\[[^\]]+\]:\s*", stripped) or re.match(r"^\[\^[^\]]+\]:\s*", stripped):
                notes.append(stripped)
        return notes

    def _detect_dependencies(self, files: Sequence[FileRecord]) -> Dict[str, Any]:
        dependencies: Dict[str, Dict[str, Any]] = {}
        dependency_names: set[str] = set()

        for record in files:
            if Path(record.path).name.lower() not in DEPENDENCY_MANIFEST_NAMES:
                continue
            absolute = self.repo / record.path
            parsed = self._parse_dependency_manifest(absolute)
            if parsed:
                dependencies[record.path] = parsed
                for item in parsed.get("dependencies", []):
                    dependency_names.add(str(item))

        manifest_entries = [
            {
                "path": path,
                "kind": data.get("kind", "unknown"),
                "dependencies": data.get("dependencies", [])[:12],
                "dependency_count": len(data.get("dependencies", [])),
            }
            for path, data in sorted(dependencies.items())
        ]
        framework_groups = self._group_dependencies_by_framework(manifest_entries)
        manifest_drilldowns = self._dependency_manifest_drilldowns(manifest_entries)

        return {
            "manifests": manifest_entries,
            "framework_groups": framework_groups,
            "manifest_drilldowns": manifest_drilldowns,
            "dependency_count": len(dependency_names),
            "dependency_names": sorted(dependency_names),
        }

    def _parse_dependency_manifest(self, path: Path) -> Dict[str, Any]:
        name = path.name.lower()
        text = self._safe_read_text(path)
        if not text.strip():
            return {}

        if name == "package.json":
            try:
                decoded = json.loads(text)
            except json.JSONDecodeError:
                return {}
            deps = set()
            for key in ("dependencies", "devDependencies", "peerDependencies"):
                value = decoded.get(key, {})
                if isinstance(value, dict):
                    deps.update(value.keys())
            return {"kind": "npm", "dependencies": sorted(deps)}

        if name == "pubspec.yaml":
            deps = self._parse_simple_yaml_dependencies(text)
            return {"kind": "flutter", "dependencies": deps}

        if name == "requirements.txt":
            deps = self._parse_requirements(text)
            return {"kind": "python", "dependencies": deps}

        if name == "pyproject.toml":
            deps = self._parse_pyproject_dependencies(text)
            return {"kind": "python", "dependencies": deps}

        if name == "go.mod":
            deps = self._parse_go_mod_dependencies(text)
            return {"kind": "go", "dependencies": deps}

        if name == "platformio.ini":
            deps = self._parse_platformio_dependencies(text)
            return {"kind": "platformio", "dependencies": deps}

        if name in {"build.gradle", "build.gradle.kts", "pom.xml"}:
            deps = self._parse_generic_java_dependencies(text)
            return {"kind": "java", "dependencies": deps}

        if name == "cargo.toml":
            deps = self._parse_toml_dependencies(text, ("dependencies", "dev-dependencies", "build-dependencies"))
            return {"kind": "rust", "dependencies": deps}

        return {"kind": "manifest", "dependencies": []}

    def _parse_simple_yaml_dependencies(self, text: str) -> List[str]:
        dependencies: List[str] = []
        in_dependencies = False
        current_indent = None
        for raw_line in text.splitlines():
            stripped = raw_line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            if stripped.startswith("dependencies:") or stripped.startswith("dev_dependencies:"):
                in_dependencies = True
                current_indent = len(raw_line) - len(raw_line.lstrip())
                continue
            if in_dependencies:
                indent = len(raw_line) - len(raw_line.lstrip())
                if current_indent is not None and indent <= current_indent:
                    in_dependencies = False
                    current_indent = None
                    continue
                if ":" in stripped:
                    key = stripped.split(":", 1)[0].strip(" -")
                    if key and key.lower() not in {"sdk", "flutter"}:
                        dependencies.append(key)
        return sorted(set(dependencies))

    def _parse_requirements(self, text: str) -> List[str]:
        dependencies: List[str] = []
        for raw_line in text.splitlines():
            line = raw_line.strip()
            if not line or line.startswith("#") or line.startswith("-e "):
                continue
            dependency = re.split(r"[<>=!~; \[]", line, maxsplit=1)[0].strip()
            if dependency:
                dependencies.append(dependency)
        return sorted(set(dependencies))

    def _parse_pyproject_dependencies(self, text: str) -> List[str]:
        if tomllib is None:
            return []
        try:
            data = tomllib.loads(text)
        except Exception:
            return []

        dependencies: set[str] = set()
        project = data.get("project", {})
        if isinstance(project, dict):
            for item in project.get("dependencies", []) or []:
                dependencies.add(self._dependency_name_from_requirement(str(item)))
        tool_poetry = data.get("tool", {}).get("poetry", {}) if isinstance(data.get("tool"), dict) else {}
        if isinstance(tool_poetry, dict):
            for item in tool_poetry.get("dependencies", {}) or {}:
                if item.lower() != "python":
                    dependencies.add(item)
        return sorted(dep for dep in dependencies if dep)

    def _parse_go_mod_dependencies(self, text: str) -> List[str]:
        dependencies: List[str] = []
        in_require = False
        for raw_line in text.splitlines():
            line = raw_line.strip()
            if not line or line.startswith("//"):
                continue
            if line.startswith("require ("):
                in_require = True
                continue
            if in_require and line == ")":
                in_require = False
                continue
            if line.startswith("require ") and not line.endswith("("):
                parts = line.split()
                if len(parts) >= 2:
                    dependencies.append(parts[1])
                continue
            if in_require:
                parts = line.split()
                if parts:
                    dependencies.append(parts[0])
        return sorted(set(dependencies))

    def _parse_platformio_dependencies(self, text: str) -> List[str]:
        dependencies: List[str] = []
        in_lib_deps = False
        for raw_line in text.splitlines():
            line = raw_line.strip()
            if not line or line.startswith(";") or line.startswith("#"):
                continue
            if line.lower().startswith("lib_deps"):
                in_lib_deps = True
                value = line.split("=", 1)[1] if "=" in line else ""
                if value.strip():
                    dependencies.append(value.strip())
                continue
            if in_lib_deps and line.startswith("["):
                in_lib_deps = False
                continue
            if in_lib_deps and line:
                dependencies.append(line.rstrip(","))
        return sorted(set(dependencies))

    def _parse_generic_java_dependencies(self, text: str) -> List[str]:
        dependencies: List[str] = []
        for pattern in (r'implementation\s+["\']([^"\']+)["\']', r"<artifactId>([^<]+)</artifactId>"):
            for match in re.findall(pattern, text, flags=re.IGNORECASE):
                dependency = self._dependency_name_from_requirement(str(match))
                if dependency:
                    dependencies.append(dependency)
        return sorted(set(dependencies))

    def _parse_toml_dependencies(self, text: str, sections: Sequence[str]) -> List[str]:
        if tomllib is None:
            return []
        try:
            data = tomllib.loads(text)
        except Exception:
            return []

        dependencies: set[str] = set()

        def walk(section: Dict[str, Any], section_name: str) -> None:
            value = section.get(section_name, {})
            if isinstance(value, dict):
                dependencies.update(value.keys())

        for section_name in sections:
            walk(data, section_name)
            tool = data.get("tool", {})
            if isinstance(tool, dict):
                walk(tool.get("poetry", {}) if isinstance(tool.get("poetry"), dict) else {}, section_name)

        return sorted(dep for dep in dependencies if dep)

    def _dependency_name_from_requirement(self, requirement: str) -> str:
        cleaned = requirement.strip().strip('"').strip("'")
        if not cleaned:
            return ""
        return re.split(r"[<>=!~ \[]", cleaned, maxsplit=1)[0].strip()

    def _dependency_manifest_drilldowns(self, manifests: Sequence[Dict[str, Any]]) -> List[Dict[str, Any]]:
        grouped: Dict[str, Dict[str, Any]] = {}
        for manifest in manifests:
            runtime = self._runtime_name_for_manifest_kind(str(manifest.get("kind", "unknown")))
            entry = grouped.setdefault(
                runtime,
                {"runtime": runtime, "manifests": [], "dependency_count": 0},
            )
            entry["manifests"].append(
                {
                    "path": manifest.get("path", ""),
                    "kind": manifest.get("kind", "unknown"),
                    "dependencies": list(manifest.get("dependencies", [])),
                    "dependency_count": manifest.get("dependency_count", 0),
                }
            )
            entry["dependency_count"] += int(manifest.get("dependency_count", 0))

        drilldowns: List[Dict[str, Any]] = []
        for runtime, data in sorted(grouped.items()):
            drilldowns.append(
                {
                    "runtime": runtime,
                    "dependency_count": data["dependency_count"],
                    "manifests": sorted(data["manifests"], key=lambda item: item["path"]),
                }
            )
        return drilldowns

    def _runtime_name_for_manifest_kind(self, kind: str) -> str:
        mapping = {
            "flutter": "Flutter / Dart",
            "npm": "Node.js",
            "python": "Python",
            "go": "Go",
            "rust": "Rust",
            "java": "Java",
            "platformio": "PlatformIO / Arduino",
            "manifest": "Generic manifest",
        }
        return mapping.get(kind.lower(), kind.title() if kind else "Unknown")

    def _group_dependencies_by_framework(
        self,
        manifests: Sequence[Dict[str, Any]],
    ) -> List[Dict[str, Any]]:
        grouped: Dict[str, Dict[str, Any]] = {}
        for manifest in manifests:
            framework = self._framework_name_for_manifest_kind(str(manifest.get("kind", "unknown")))
            entry = grouped.setdefault(
                framework,
                {"framework": framework, "manifests": [], "dependencies": set()},
            )
            entry["manifests"].append(
                {
                    "path": manifest.get("path", ""),
                    "kind": manifest.get("kind", "unknown"),
                    "dependency_count": manifest.get("dependency_count", 0),
                }
            )
            entry["dependencies"].update(manifest.get("dependencies", []))

        ordered: List[Dict[str, Any]] = []
        for framework, data in sorted(grouped.items()):
            ordered.append(
                {
                    "framework": framework,
                    "manifests": sorted(data["manifests"], key=lambda item: item["path"]),
                    "dependencies": sorted(data["dependencies"]),
                    "dependency_count": len(data["dependencies"]),
                }
            )
        return ordered

    def _framework_name_for_manifest_kind(self, kind: str) -> str:
        mapping = {
            "flutter": "Flutter / Dart",
            "npm": "Node.js / Web UI",
            "python": "Python",
            "go": "Go",
            "rust": "Rust",
            "java": "Java",
            "platformio": "PlatformIO / Arduino",
            "manifest": "Generic manifest",
        }
        return mapping.get(kind.lower(), kind.title() if kind else "Unknown")

    def _detect_frameworks(self, files: Sequence[FileRecord], dependency_summary: Dict[str, Any]) -> List[Dict[str, Any]]:
        file_names = {Path(record.path).name.lower() for record in files}
        paths = " ".join(record.path.lower() for record in files)
        dependency_names = {name.lower() for name in dependency_summary.get("dependency_names", [])}

        frameworks: List[Dict[str, Any]] = []

        def add(name: str, reason: str) -> None:
            if not any(item["name"] == name for item in frameworks):
                frameworks.append({"name": name, "reason": reason})

        if "pubspec.yaml" in file_names or any(record.language == "Dart" for record in files):
            add("Flutter / Dart", "pubspec.yaml and Dart files were detected.")
        if "package.json" in file_names:
            add("Node.js", "package.json was detected.")
        if {"react", "next", "vite", "vue", "svelte"} & dependency_names:
            add("Web UI", "Front-end framework dependencies were detected.")
        if any(record.language == "Python" for record in files) or "requirements.txt" in file_names:
            add("Python", "Python files or requirements.txt were detected.")
        if "platformio.ini" in file_names or any(record.suffix == ".ino" for record in files):
            add("PlatformIO / Arduino", "PlatformIO or Arduino firmware files were detected.")
        if "esp32" in paths or "espidf" in paths or "esp-idf" in paths:
            add("ESP32", "ESP32-specific project terms were found.")
        if any(record.category == "hardware_design" for record in files):
            add("KiCad / Hardware Design", "Hardware design files were detected.")
        if "go.mod" in file_names:
            add("Go", "go.mod was detected.")
        if "cargo.toml" in file_names:
            add("Rust", "Cargo.toml was detected.")

        return frameworks

    def _build_tree(self, files: Sequence[FileRecord]) -> Dict[str, Any]:
        root = {
            "name": self.repo.name,
            "path": ".",
            "kind": "directory",
            "file_count": 0,
            "directory_count": 0,
            "children": [],
        }

        for record in sorted(files, key=lambda item: item.path.lower()):
            parts = Path(record.path).parts
            node = root
            accumulated_parts: List[str] = []
            for index, part in enumerate(parts):
                accumulated_parts.append(part)
                is_leaf = index == len(parts) - 1
                child = self._find_child(node["children"], part)
                if child is None:
                    child = {
                        "name": part,
                        "path": "/".join(accumulated_parts),
                        "kind": "file" if is_leaf else "directory",
                        "file_count": 0,
                        "directory_count": 0,
                        "children": [],
                    }
                    node["children"].append(child)
                if is_leaf:
                    child.update(
                        {
                            "suffix": record.suffix,
                            "size_bytes": record.size_bytes,
                            "category": record.category,
                            "language": record.language,
                            "flags": record.flags,
                        }
                    )
                else:
                    child["directory_count"] = child.get("directory_count", 0) + 1
                node = child
            self._increment_counts(root, parts)

        return root

    def _find_child(self, children: List[Dict[str, Any]], name: str) -> Dict[str, Any] | None:
        for child in children:
            if child["name"] == name:
                return child
        return None

    def _increment_counts(self, root: Dict[str, Any], parts: Sequence[str]) -> None:
        root["file_count"] = root.get("file_count", 0) + 1
        node = root
        for index, part in enumerate(parts):
            child = self._find_child(node["children"], part)
            if child is None:
                return
            child["file_count"] = child.get("file_count", 0) + 1
            if index < len(parts) - 1:
                child["directory_count"] = child.get("directory_count", 0) + 1
            node = child
