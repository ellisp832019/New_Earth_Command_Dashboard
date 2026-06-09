from __future__ import annotations

from pathlib import Path
from typing import Any, Dict
import json

from .knowledge_extractor import KnowledgeExtractor
from .security_analyser import SecurityAnalyzer


class ProfileAnalyser:
    def __init__(self, scan: Dict[str, Any], profile: Dict[str, Any]) -> None:
        self.scan = scan
        self.profile = profile

    @classmethod
    def from_files(cls, scan_json: str, profile_json: str) -> "ProfileAnalyser":
        return cls(
            json.loads(Path(scan_json).read_text(encoding="utf-8")),
            json.loads(Path(profile_json).read_text(encoding="utf-8")),
        )

    def analyse(self) -> Dict[str, Any]:
        security = SecurityAnalyzer(self.scan.get("repo_path", ""), self.scan.get("files", [])).analyse()
        knowledge = KnowledgeExtractor(self.scan, self.profile, security).extract()

        top_useful_files = self._top_useful_files()
        risk_flags = self._risk_flags(security)
        architecture = knowledge.get("architecture_summary", "")
        file_type_drilldowns = self._file_type_drilldowns()
        image_assets = self.scan.get("image_assets", [])
        diagram_files = self.scan.get("diagram_files", [])

        return {
            "profile_name": self.profile.get("profile_name"),
            "project_type": self.profile.get("project_type"),
            "repo_path": self.scan.get("repo_path"),
            "repo_name": self.scan.get("repo_name"),
            "scanned_at": self.scan.get("scanned_at"),
            "file_count": self.scan.get("file_count"),
            "directory_count": self.scan.get("directory_count"),
            "category_counts": self.scan.get("category_counts"),
            "language_counts": self.scan.get("language_counts"),
            "frameworks": self.scan.get("frameworks", []),
            "licenses": self.scan.get("license_detection", []),
            "license_summary": self.scan.get("license_summary", {}),
            "dependency_summary": self.scan.get("dependency_summary", {}),
            "relevance_score": self._relevance_score(top_useful_files, risk_flags),
            "top_useful_files": top_useful_files,
            "risk_flags": risk_flags,
            "security": security,
            "knowledge": knowledge,
            "architecture_summary": architecture,
            "project_summary": knowledge.get("project_summary", ""),
            "file_type_drilldowns": file_type_drilldowns,
            "image_assets": image_assets,
            "diagram_files": diagram_files,
            "learning_notes": knowledge.get("learning_notes", []),
            "implementation_ideas": knowledge.get("implementation_ideas", []),
            "reusable_components": knowledge.get("reusable_components", []),
            "recommendations": knowledge.get("recommendations", []),
            "output_focus": self.profile.get("output_focus", []),
            "export_targets": self.profile.get("export_targets", []),
            "export_locations": self.profile.get("export_locations", []),
            "report_templates": self.profile.get("report_templates", {}),
        }

    def _top_useful_files(self) -> list[Dict[str, Any]]:
        keywords = [k.lower() for k in self.profile.get("priority_keywords", [])]
        useful: list[Dict[str, Any]] = []
        for record in self.scan.get("files", []):
            path = record.get("path", "")
            lower_path = path.lower()
            matches = [keyword for keyword in keywords if keyword and keyword in lower_path]
            if matches or record.get("category") in {
                "documentation",
                "firmware_or_code",
                "hardware_design",
                "configuration",
            }:
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

    def _risk_flags(self, security: Dict[str, Any]) -> list[Dict[str, Any]]:
        risk_words = [k.lower() for k in self.profile.get("risk_keywords", [])]
        risks: list[Dict[str, Any]] = []
        for record in self.scan.get("files", []):
            path = record.get("path", "")
            lower_path = path.lower()
            matched = [risk for risk in risk_words if risk and risk in lower_path]
            if matched or record.get("flags"):
                risks.append(
                    {
                        "path": path,
                        "risk_matches": matched,
                        "flags": record.get("flags", []),
                        "severity": self._risk_severity(record, security),
                    }
                )
        findings = security.get("findings", [])
        for finding in findings:
            risks.append(
                {
                    "path": finding.get("path"),
                    "risk_matches": [finding.get("finding_type", "security_finding")],
                    "flags": [finding.get("severity", "unknown")],
                    "severity": finding.get("severity", "unknown"),
                    "masked_excerpt": finding.get("masked_excerpt", ""),
                }
            )
        return risks[:150]

    def _risk_severity(self, record: Dict[str, Any], security: Dict[str, Any]) -> str:
        flags = set(record.get("flags", []))
        if "binary_or_asset_do_not_parse_as_text" in flags:
            return "medium"
        if "script_present_do_not_execute" in flags:
            return "high"
        if "possible_secret_or_credential_path" in flags or "certificate_or_private_key_candidate" in flags:
            return "high"
        if security.get("risk_level") == "high":
            return "high"
        return "medium"

    def _relevance_score(self, useful_files: list[Dict[str, Any]], risk_flags: list[Dict[str, Any]]) -> int:
        match_bonus = sum(len(item.get("matches", [])) for item in useful_files)
        category_bonus = len(useful_files)
        risk_penalty = sum(2 if item.get("severity") == "high" else 1 for item in risk_flags[:25])
        score = max(0, (match_bonus * 2) + category_bonus - risk_penalty)
        return score

    def _file_type_drilldowns(self) -> list[Dict[str, Any]]:
        category_labels = [
            ("documentation", "Documentation"),
            ("script", "Scripts"),
            ("firmware_or_code", "Firmware / Code"),
            ("hardware_design", "Hardware Design"),
            ("binary_or_asset", "Binaries / Assets"),
        ]
        drilldowns: list[Dict[str, Any]] = []
        for category, label in category_labels:
            files = [
                record
                for record in self.scan.get("files", [])
                if record.get("category") == category
            ]
            if not files:
                continue
            drilldowns.append(
                {
                    "category": category,
                    "label": label,
                    "count": len(files),
                    "files": sorted(
                        [
                            {
                                "path": record.get("path", ""),
                                "language": record.get("language", "Unknown"),
                                "flags": record.get("flags", []),
                                "size_bytes": record.get("size_bytes", 0),
                            }
                            for record in files
                        ],
                        key=lambda item: item["path"].lower(),
                    )[:12],
                }
            )
        return drilldowns
