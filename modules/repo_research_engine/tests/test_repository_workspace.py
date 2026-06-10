from __future__ import annotations

import json
import subprocess
from pathlib import Path

from sources import RepositoryCloneRequest, RepositoryWorkspaceManager


def _git(*args: str, cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=str(cwd),
        check=True,
        capture_output=True,
        text=True,
    )


def test_clone_repository_into_structured_workspace(tmp_path):
    source_repo = tmp_path / "seed_repo"
    source_repo.mkdir()

    _git("init", cwd=source_repo)
    _git("config", "user.email", "test@example.com", cwd=source_repo)
    _git("config", "user.name", "Test User", cwd=source_repo)
    _git("remote", "add", "origin", "https://github.com/NewEarth/StructuredClone.git", cwd=source_repo)
    (source_repo / "README.md").write_text("# Seed Repo\n", encoding="utf-8")
    _git("add", "README.md", cwd=source_repo)
    _git("commit", "-m", "Initial commit", cwd=source_repo)

    workspace_root = tmp_path / "workspace"
    result = RepositoryWorkspaceManager().clone_repository(
        RepositoryCloneRequest(
            source=str(source_repo),
            workspace_root=str(workspace_root),
        )
    )

    assert result.success is True
    assert result.provider == "github.com"
    assert result.owner_path == "NewEarth"
    assert result.repo_name == "StructuredClone"

    source_root = Path(result.source_root)
    assert source_root.exists()
    assert (source_root / "README.md").exists()

    repository_root = Path(result.repository_root)
    assert (repository_root / "analysis").exists()
    assert (repository_root / "reports").exists()
    assert (repository_root / "exports").exists()
    assert (repository_root / "prompts").exists()
    assert (repository_root / "metadata").exists()

    manifest = json.loads((repository_root / "clone_manifest.json").read_text(encoding="utf-8"))
    assert manifest["source"] == str(source_repo)
    assert manifest["repository_root"] == str(repository_root)
    assert manifest["source_root"] == str(source_root)


def test_workspace_manager_rejects_empty_source(tmp_path):
    manager = RepositoryWorkspaceManager()
    try:
        manager.clone_repository(
            RepositoryCloneRequest(
                source="",
                workspace_root=str(tmp_path / "workspace"),
            ),
        )
    except ValueError as error:
        assert "required" in str(error)
    else:
        raise AssertionError("Expected clone_repository to reject an empty source")
