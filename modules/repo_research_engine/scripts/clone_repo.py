from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

MODULE_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(MODULE_ROOT))

from sources import (
    RepositoryCloneRequest,
    RepositoryWorkspaceRuntime,
)


def main() -> None:
    parser = argparse.ArgumentParser(description="Clone a repository into a structured workspace")
    parser.add_argument("--source", required=True, help="Local repository path or remote Git URL")
    parser.add_argument(
        "--workspace-root",
        required=True,
        help="Workspace root that will contain the structured clone folders",
    )
    parser.add_argument(
        "--branch",
        default="",
        help="Optional branch to clone when the source is remote or branch-capable",
    )
    args = parser.parse_args()

    runtime = RepositoryWorkspaceRuntime()
    manager = runtime.manager
    result = manager.clone_repository(
        RepositoryCloneRequest(
            source=args.source,
            workspace_root=args.workspace_root,
            branch=args.branch,
        )
    )
    print(json.dumps(result.as_dict(), indent=2))


if __name__ == "__main__":
    main()
