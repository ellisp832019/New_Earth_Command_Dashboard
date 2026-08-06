from __future__ import annotations

from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, Iterable, List, Tuple
import json


class GraphExporter:
    def __init__(self, scan: Dict[str, Any], analysis: Dict[str, Any]) -> None:
        self.scan = scan
        self.analysis = analysis

    def build_dependency_graph(self) -> Dict[str, Any]:
        repo_name = self.scan.get("repo_name", "repository")
        nodes: list[Dict[str, Any]] = [
            {"id": repo_name, "label": repo_name, "kind": "repository"}
        ]
        edges: list[Dict[str, Any]] = []
        node_ids = {repo_name}

        def add_node(node_id: str, label: str, kind: str) -> None:
            if node_id not in node_ids:
                node_ids.add(node_id)
                nodes.append({"id": node_id, "label": label, "kind": kind})

        for framework in self.scan.get("frameworks", []):
            name = str(framework.get("name", "")).strip()
            if not name:
                continue
            add_node(name, name, "framework")
            edges.append({"from": repo_name, "to": name, "kind": "framework"})

        for manifest in self.scan.get("dependency_summary", {}).get("manifests", []):
            manifest_path = str(manifest.get("path", "")).strip()
            if not manifest_path:
                continue
            manifest_id = f"manifest:{manifest_path}"
            add_node(manifest_id, manifest_path, "manifest")
            edges.append({"from": repo_name, "to": manifest_id, "kind": "manifest"})
            for dependency in manifest.get("dependencies", []):
                dep_name = str(dependency).strip()
                if not dep_name:
                    continue
                add_node(f"dep:{dep_name}", dep_name, "dependency")
                edges.append({"from": manifest_id, "to": f"dep:{dep_name}", "kind": "depends_on"})

        return {
            "graph_type": "dependency",
            "repo_name": repo_name,
            "nodes": nodes,
            "edges": edges,
            "summary": {
                "node_count": len(nodes),
                "edge_count": len(edges),
                "kind_counts": self._count_node_kinds(nodes),
            },
        }

    def build_architecture_graph(self) -> Dict[str, Any]:
        repo_name = self.scan.get("repo_name", "repository")
        nodes: list[Dict[str, Any]] = [
            {"id": repo_name, "label": repo_name, "kind": "repository"}
        ]
        edges: list[Dict[str, Any]] = []
        node_ids = {repo_name}

        def add_node(node_id: str, label: str, kind: str) -> None:
            if node_id not in node_ids:
                node_ids.add(node_id)
                nodes.append({"id": node_id, "label": label, "kind": kind})

        for category, count in (self.scan.get("category_counts") or {}).items():
            category_id = f"category:{category}"
            add_node(category_id, f"{category} ({count})", "category")
            edges.append({"from": repo_name, "to": category_id, "kind": "contains"})

        for language, count in (self.scan.get("language_counts") or {}).items():
            language_id = f"language:{language}"
            add_node(language_id, f"{language} ({count})", "language")
            edges.append({"from": repo_name, "to": language_id, "kind": "language"})

        for file_record in self._top_architecture_files():
            file_id = f"file:{file_record['path']}"
            add_node(file_id, file_record["path"], "file")
            edges.append({"from": repo_name, "to": file_id, "kind": "contains"})
            if file_record.get("directory"):
                dir_id = f"dir:{file_record['directory']}"
                add_node(dir_id, file_record["directory"], "directory")
                edges.append({"from": dir_id, "to": file_id, "kind": "contains"})

        for risk in (self.analysis.get("risk_flags") or [])[:20]:
            path = str(risk.get("path", "")).strip()
            if not path:
                continue
            risk_id = f"risk:{path}"
            add_node(risk_id, f"Risk: {path}", "risk")
            edges.append({"from": repo_name, "to": risk_id, "kind": "flagged"})

        return {
            "graph_type": "architecture",
            "repo_name": repo_name,
            "nodes": nodes,
            "edges": edges,
            "summary": {
                "node_count": len(nodes),
                "edge_count": len(edges),
                "kind_counts": self._count_node_kinds(nodes),
                "key_anchors": self._architecture_key_anchors(),
            },
        }

    def save_bundle(self, out_dir: str | Path) -> Dict[str, str]:
        output_dir = Path(out_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

        dependency_graph = self.build_dependency_graph()
        architecture_graph = self.build_architecture_graph()

        outputs = {
            "dependency_graph.json": dependency_graph,
            "architecture_graph.json": architecture_graph,
            "dependency_graph.md": self._render_graph_markdown("Dependency Graph", dependency_graph),
            "architecture_graph.md": self._render_graph_markdown("Architecture Graph", architecture_graph),
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

    def _top_architecture_files(self) -> List[Dict[str, Any]]:
        files = []
        for record in self.scan.get("files", [])[:50]:
            files.append(
                {
                    "path": record.get("path", ""),
                    "directory": record.get("directory", ""),
                    "category": record.get("category", ""),
                    "language": record.get("language", ""),
                }
            )
        return files

    def _architecture_key_anchors(self) -> List[Dict[str, Any]]:
        anchors: List[Dict[str, Any]] = []
        for record in self._top_architecture_files()[:12]:
            anchor_type = "file"
            if record.get("category") == "documentation":
                anchor_type = "documentation"
            elif record.get("category") == "configuration":
                anchor_type = "configuration"
            elif record.get("category") == "hardware_design":
                anchor_type = "hardware"
            elif record.get("category") == "firmware_or_code":
                anchor_type = "implementation"
            elif record.get("category") == "script":
                anchor_type = "script"
            anchors.append(
                {
                    "path": record.get("path", ""),
                    "anchor_type": anchor_type,
                    "category": record.get("category", ""),
                    "language": record.get("language", ""),
                    "note": f"{record.get('category', 'file')} anchor",
                }
            )
        return anchors

    def _render_graph_markdown(self, title: str, graph: Dict[str, Any]) -> str:
        lines = [
            f"# {title}",
            "",
            f"Nodes: **{graph.get('summary', {}).get('node_count', 0)}**",
            f"Edges: **{graph.get('summary', {}).get('edge_count', 0)}**",
            "",
        ]
        kind_counts = graph.get("summary", {}).get("kind_counts", {})
        if kind_counts:
            lines += ["", "## Node Groups"]
            for kind, count in sorted(kind_counts.items()):
                lines.append(f"- {kind}: {count}")

            anchors = graph.get("summary", {}).get("key_anchors", [])
            if anchors:
                lines += ["", "## Key Anchors"]
                for item in anchors[:12]:
                    lines.append(
                        f"- `{item.get('path')}` - {item.get('anchor_type')} - {item.get('note')}",
                    )

            lines.append("")
            lines.append("## Nodes")
            grouped: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
            for node in graph.get("nodes", []):
                grouped[str(node.get("kind", "unknown"))].append(node)
            for kind, nodes in sorted(grouped.items()):
                lines.append(f"### {kind}")
                for node in nodes[:12]:
                    lines.append(f"- `{node.get('id')}`")
                lines.append("")
        else:
            lines += ["", "## Nodes"]
            for node in graph.get("nodes", [])[:40]:
                lines.append(f"- `{node.get('id')}` - {node.get('kind')}")

        lines += ["", "## Edges"]
        edge_groups: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
        for edge in graph.get("edges", []):
            edge_groups[str(edge.get("kind", "unknown"))].append(edge)
        for kind, edges in sorted(edge_groups.items()):
            lines.append(f"### {kind}")
            for edge in edges[:20]:
                lines.append(f"- `{edge.get('from')}` -> `{edge.get('to')}`")
            lines.append("")
        return "\n".join(lines).rstrip() + "\n"

    def _count_node_kinds(self, nodes: Iterable[Dict[str, Any]]) -> Dict[str, int]:
        counts: Dict[str, int] = {}
        for node in nodes:
            kind = str(node.get("kind", "unknown"))
            counts[kind] = counts.get(kind, 0) + 1
        return dict(sorted(counts.items()))
