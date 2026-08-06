from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List


class PromptExporter:
    PROMPT_TYPES = (
        (
            "bug_fixing",
            "Bug Fixing",
            "Find and fix a concrete bug in the repository without running untrusted code.",
        ),
        (
            "feature_creation",
            "Feature Creation",
            "Design and implement a new feature that fits the repository's current architecture.",
        ),
        (
            "architecture_review",
            "Architecture Review",
            "Review the architecture, highlight strengths, and note risks or refactor opportunities.",
        ),
        (
            "firmware_review",
            "Firmware Review",
            "Review firmware-oriented code with safety, testability, and hardware boundaries in mind.",
        ),
        (
            "flutter_review",
            "Flutter Review",
            "Review Flutter and Dart code for structure, navigation, state management, and UI clarity.",
        ),
        (
            "esp32_review",
            "ESP32 Review",
            "Review ESP32-oriented code for firmware safety, power boundaries, and local-first behaviour.",
        ),
        (
            "dashboard_review",
            "Dashboard Review",
            "Review the repository as a Dashboard module and focus on calm local-first integration points.",
        ),
        (
            "documentation_generation",
            "Documentation Generation",
            "Generate practical documentation from the repository scan and knowledge extraction results.",
        ),
    )

    def __init__(self, analysis: Dict[str, Any]) -> None:
        self.analysis = analysis

    def render_prompt(self, prompt_key: str, title: str, description: str) -> str:
        profile = self.analysis.get("profile_name", "Unknown profile")
        repo_path = self.analysis.get("repo_path", "")
        repo_name = self.analysis.get("repo_name", "Unknown repository")
        useful_files = self.analysis.get("top_useful_files", [])[:10]
        risk_level = self.analysis.get("security", {}).get("risk_level", "unknown")
        focus = ", ".join(self.analysis.get("output_focus", [])) or "general analysis"
        useful_lines = "\n".join(f"- `{item['path']}`" for item in useful_files) or "- No high-signal files were flagged."

        return (
            f"# Codex Prompt - {title}\n\n"
            f"Repository: `{repo_name}`\n"
            f"Path: `{repo_path}`\n"
            f"Profile: `{profile}`\n"
            f"Risk level: `{risk_level}`\n"
            f"Focus areas: {focus}\n\n"
            f"{description}\n\n"
            "Rules:\n"
            "1. Keep the work local-first and read-only unless the task explicitly says otherwise.\n"
            "2. Do not run unknown code from the repository.\n"
            "3. Keep secrets masked and avoid copying sensitive values into the output.\n"
            "4. Prefer calm, reviewable changes.\n\n"
            "Useful files to inspect first:\n"
            f"{useful_lines}\n\n"
            "Requested output:\n"
            "- Clear reasoning\n"
            "- Practical next steps\n"
            "- Minimal risk to the repository\n"
            "- Any assumptions called out explicitly\n"
        )

    def save_all(self, out_dir: str | Path) -> Dict[str, str]:
        output_dir = Path(out_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

        outputs: Dict[str, str] = {}
        for index, (key, title, description) in enumerate(self.PROMPT_TYPES, start=1):
            filename = f"{index:02d}_{key}.md"
            content = self.render_prompt(key, title, description)
            target = output_dir / filename
            target.write_text(content, encoding="utf-8")
            outputs[filename] = str(target)
        return outputs

