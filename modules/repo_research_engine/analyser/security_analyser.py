from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Sequence
import re

SECRET_PATTERNS = (
    ("api_key", re.compile(r"(?i)\b(api[_-]?key|apikey|token|secret|password|client[_-]?secret)\b\s*[:=]\s*([^\s\"']{8,})")),
    ("private_key", re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----", re.IGNORECASE)),
    ("certificate", re.compile(r"-----BEGIN CERTIFICATE-----", re.IGNORECASE)),
    ("ssh_private_key", re.compile(r"(?i)\bssh-rsa\b\s+[A-Za-z0-9+/=]{30,}")),
    ("jwt", re.compile(r"eyJ[a-zA-Z0-9_-]{8,}\.[a-zA-Z0-9_-]{8,}\.[a-zA-Z0-9_-]{8,}")),
    ("aws_key", re.compile(r"(?i)\bAKIA[0-9A-Z]{16}\b")),
)

DANGEROUS_SCRIPT_PATTERNS = (
    ("curl_pipe_bash", re.compile(r"(?i)curl\s+[^|]+\|\s*(?:ba)?sh")),
    ("rm_rf", re.compile(r"(?i)\brm\s+-rf\b")),
    ("sudo", re.compile(r"(?i)\bsudo\b")),
    ("powershell_web", re.compile(r"(?i)invoke-webrequest|iwr\s+|irm\s+")),
    ("invoke_expression", re.compile(r"(?i)invoke-expression|iex\s+")),
    ("download_execute", re.compile(r"(?i)start-process\s+.*(?:curl|wget|powershell|cmd)")),
)

SUSPICIOUS_BINARY_EXTS = {
    ".bin",
    ".dll",
    ".dmg",
    ".elf",
    ".exe",
    ".iso",
    ".msi",
    ".pkg",
    ".so",
    ".whl",
}


@dataclass(frozen=True)
class SecurityFinding:
    path: str
    finding_type: str
    severity: str
    masked_excerpt: str
    reason: str


class SecurityAnalyzer:
    def __init__(self, repo_path: str, files: Sequence[Dict[str, Any]]) -> None:
        self.repo = Path(repo_path)
        self.files = list(files)

    def analyse(self) -> Dict[str, Any]:
        findings: List[SecurityFinding] = []

        for file_record in self.files:
            relative_path = file_record.get("path", "")
            absolute = self.repo / relative_path
            suffix = file_record.get("suffix", "").lower()
            flags = list(file_record.get("flags", []))

            if suffix in SUSPICIOUS_BINARY_EXTS or "binary_or_asset_do_not_parse_as_text" in flags:
                findings.append(
                    SecurityFinding(
                        path=relative_path,
                        finding_type="suspicious_binary",
                        severity="medium",
                        masked_excerpt="Binary or asset file flagged for manual review.",
                        reason="Binary content should not be executed or copied blindly.",
                    )
                )

            if "script_present_do_not_execute" in flags:
                script_findings = self._scan_script(absolute, relative_path)
                findings.extend(script_findings)

            if self._looks_like_text_file(absolute):
                findings.extend(self._scan_for_secrets(absolute, relative_path))

        summary = self._summarise(findings)
        risk_level = self._risk_level(summary)
        return {
            "risk_level": risk_level,
            "summary": summary,
            "findings": [finding.__dict__ for finding in findings],
            "masked": True,
            "notes": [
                "All excerpts are masked.",
                "No unknown code was executed during analysis.",
                "Secret-like material should never be copied into reports unredacted.",
            ],
        }

    def _scan_script(self, path: Path, relative_path: str) -> List[SecurityFinding]:
        findings: List[SecurityFinding] = []
        text = self._safe_read_text(path)
        if not text.strip():
            return findings

        first_line = text.splitlines()[0] if text.splitlines() else ""
        if first_line.startswith("#!"):
            findings.append(
                SecurityFinding(
                    path=relative_path,
                    finding_type="script_shebang",
                    severity="low",
                    masked_excerpt=self._mask_line(first_line),
                    reason="Script files must not be executed from researched repositories.",
                )
            )

        for label, pattern in DANGEROUS_SCRIPT_PATTERNS:
            if pattern.search(text):
                findings.append(
                    SecurityFinding(
                        path=relative_path,
                        finding_type=f"dangerous_script:{label}",
                        severity="high",
                        masked_excerpt=self._mask_line(self._first_matching_line(text, pattern)),
                        reason="Potentially destructive or networked install command detected.",
                    )
                )
        return findings

    def _scan_for_secrets(self, path: Path, relative_path: str) -> List[SecurityFinding]:
        findings: List[SecurityFinding] = []
        text = self._safe_read_text(path)
        if not text.strip():
            return findings

        for label, pattern in SECRET_PATTERNS:
            for line in text.splitlines():
                if not pattern.search(line):
                    continue
                findings.append(
                    SecurityFinding(
                        path=relative_path,
                        finding_type=f"secret_like:{label}",
                        severity="high" if label in {"api_key", "private_key", "aws_key"} else "medium",
                        masked_excerpt=self._mask_line(line, pattern),
                        reason="Secret-like material was detected and masked.",
                    )
                )
                break

        if path.name.lower().startswith(".env"):
            findings.append(
                SecurityFinding(
                    path=relative_path,
                    finding_type="environment_file",
                    severity="medium",
                    masked_excerpt="Environment file present. Review locally and keep values masked.",
                    reason="Environment files often contain credentials or service endpoints.",
                )
            )

        if path.suffix.lower() in {".pem", ".key", ".crt", ".p12", ".pfx"}:
            findings.append(
                SecurityFinding(
                    path=relative_path,
                    finding_type="certificate_or_key_file",
                    severity="high",
                    masked_excerpt="Certificate or key file flagged. Do not expose contents.",
                    reason="Certificate and key material must stay fully masked.",
                )
            )

        return findings

    def _safe_read_text(self, path: Path) -> str:
        try:
            if path.stat().st_size > 200_000:
                return path.read_text(encoding="utf-8", errors="ignore")[:200_000]
            return path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            return ""

    def _looks_like_text_file(self, path: Path) -> bool:
        if not path.exists() or not path.is_file():
            return False
        if path.suffix.lower() in SUSPICIOUS_BINARY_EXTS:
            return False
        try:
            if path.stat().st_size > 400_000:
                return False
        except OSError:
            return False
        return True

    def _mask_line(self, line: str, pattern: re.Pattern[str] | None = None) -> str:
        masked = line
        if pattern is not None:
            masked = pattern.sub(lambda match: self._replace_sensitive_match(match), masked)
        masked = re.sub(r"([A-Za-z0-9_\-]{4})[A-Za-z0-9_\-+/=]{6,}([A-Za-z0-9_\-]{2})", r"\1…\2", masked)
        return masked[:240]

    def _replace_sensitive_match(self, match: re.Match[str]) -> str:
        groups = match.groups()
        if len(groups) >= 2:
            value = groups[1]
        else:
            value = match.group(0)
        if len(value) <= 8:
            return f"{match.group(1)}=<masked>"
        return f"{match.group(1)}={value[:4]}…{value[-4:]}"

    def _first_matching_line(self, text: str, pattern: re.Pattern[str]) -> str:
        for line in text.splitlines():
            if pattern.search(line):
                return line
        return text.splitlines()[0] if text.splitlines() else ""

    def _summarise(self, findings: Sequence[SecurityFinding]) -> Dict[str, int]:
        counts: Dict[str, int] = {}
        for finding in findings:
            counts[finding.severity] = counts.get(finding.severity, 0) + 1
        return dict(sorted(counts.items()))

    def _risk_level(self, summary: Dict[str, int]) -> str:
        if summary.get("high", 0) >= 3:
            return "high"
        if summary.get("high", 0) >= 1 or summary.get("medium", 0) >= 4:
            return "medium"
        if summary:
            return "low"
        return "minimal"
