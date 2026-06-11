from __future__ import annotations

import datetime as dt
import os
import sqlite3
from pathlib import Path
from typing import Any, Dict, List, Optional


def dashboard_call_sqlite(
    command: str,
    slots: Dict[str, Any],
    config: Dict[str, Any],
) -> str:
    db_path = resolve_dashboard_db_path(config)
    if db_path is None:
        return (
            "The real dashboard adapter is not configured yet. "
            "Set NEW_EARTH_DASHBOARD_DB_PATH or dashboard.sqlite_db_path first."
        )

    if not db_path.exists():
        return (
            "The real dashboard database file could not be found. "
            "Check the configured dashboard SQLite path."
        )

    with sqlite3.connect(db_path) as connection:
        connection.row_factory = sqlite3.Row
        if command == "dashboard.summary.today":
            return _today_summary(connection)
        if command == "dashboard.project.status.read":
            return _project_status_summary(connection, slots)
        if command == "dashboard.tasks.next":
            return _next_tasks_summary(connection)

    return (
        "That read-only dashboard command is not wired into the real SQLite adapter yet."
    )


def resolve_dashboard_db_path(config: Dict[str, Any]) -> Optional[Path]:
    dashboard_config = config.get("dashboard", {})
    env_override = os.getenv("NEW_EARTH_DASHBOARD_DB_PATH")
    configured = env_override or dashboard_config.get("sqlite_db_path")
    if not configured:
        return None
    return Path(configured).expanduser()


def _today_summary(connection: sqlite3.Connection) -> str:
    plan = _today_plan(connection)
    top_tasks = _top_tasks(connection, plan)
    active_projects = _active_projects(connection, limit=3)

    focus = _clean_text(plan["main_focus"]) if plan else None
    project_count = _active_project_count(connection)

    parts: List[str] = []
    if focus:
        parts.append(f"Today's main focus is {focus}.")
    else:
        parts.append("Today's main focus is not set yet.")

    if top_tasks:
        task_titles = ", ".join(task["title"] for task in top_tasks[:3])
        parts.append(f"Your Top 3 tasks are {task_titles}.")
    else:
        parts.append("Your Top 3 tasks are not set yet.")

    if active_projects:
        lead_projects = ", ".join(project["name"] for project in active_projects)
        parts.append(
            f"You have {project_count} active projects. The leading projects are {lead_projects}."
        )
    else:
        parts.append("There are no active projects in the local dashboard right now.")

    return " ".join(parts)


def _project_status_summary(
    connection: sqlite3.Connection,
    slots: Dict[str, Any],
) -> str:
    project_name = _clean_text(slots.get("project"))
    projects = _active_projects(connection, limit=3, project_name=project_name)
    if not projects:
        if project_name:
            return f"I could not find an active project called {project_name} in the local dashboard."
        return "There are no active projects to report from the local dashboard right now."

    lines = []
    for project in projects:
        milestone = _clean_text(project["current_milestone"])
        next_action = _clean_text(project["next_action"])
        progress = project["progress_percentage"] or 0
        detail = next_action or milestone or "no next action is recorded yet"
        lines.append(
            f"{project['name']} is {project['status']} at {progress} percent, with {detail}."
        )

    if project_name:
        return lines[0]
    return " ".join(lines)


def _next_tasks_summary(connection: sqlite3.Connection) -> str:
    tasks = _top_tasks(connection, _today_plan(connection))
    if not tasks:
        return "There are no next tasks ready in the local dashboard right now."

    lines = []
    for task in tasks[:3]:
        project_name = _clean_text(task["project_name"])
        prefix = f"{task['title']}"
        if project_name:
            prefix = f"{prefix} for {project_name}"
        lines.append(f"{prefix} is {task['status']} with {task['priority']} priority.")

    return " ".join(lines)


def _today_plan(connection: sqlite3.Connection) -> Optional[sqlite3.Row]:
    now = dt.datetime.now()
    start_of_day = dt.datetime(now.year, now.month, now.day)
    timestamp = int(start_of_day.timestamp())
    return connection.execute(
        """
        SELECT *
        FROM daily_plans
        WHERE date = ?
        LIMIT 1
        """,
        (timestamp,),
    ).fetchone()


def _top_tasks(
    connection: sqlite3.Connection,
    plan: Optional[sqlite3.Row],
) -> List[sqlite3.Row]:
    task_ids = _plan_task_ids(plan)
    if task_ids:
        placeholders = ",".join("?" for _ in task_ids)
        rows = connection.execute(
            f"""
            SELECT
              tasks.task_id,
              tasks.title,
              tasks.status,
              tasks.priority,
              projects.name AS project_name
            FROM tasks
            LEFT JOIN projects ON projects.project_id = tasks.project_id
            WHERE tasks.task_id IN ({placeholders})
            """,
            tuple(task_ids),
        ).fetchall()
        rows_by_id = {row["task_id"]: row for row in rows}
        return [rows_by_id[task_id] for task_id in task_ids if task_id in rows_by_id]

    return connection.execute(
        """
        SELECT
          tasks.task_id,
          tasks.title,
          tasks.status,
          tasks.priority,
          projects.name AS project_name
        FROM tasks
        LEFT JOIN projects ON projects.project_id = tasks.project_id
        WHERE tasks.is_archived = 0
          AND tasks.is_top_three = 1
          AND tasks.status NOT IN ('Done', 'Parked')
        ORDER BY tasks.created_at ASC
        LIMIT 3
        """
    ).fetchall()


def _plan_task_ids(plan: Optional[sqlite3.Row]) -> List[str]:
    if plan is None:
        return []
    return [
        task_id
        for task_id in (
            plan["top_task_1_id"],
            plan["top_task_2_id"],
            plan["top_task_3_id"],
        )
        if task_id
    ]


def _active_project_count(connection: sqlite3.Connection) -> int:
    row = connection.execute(
        """
        SELECT COUNT(*) AS project_count
        FROM projects
        WHERE is_archived = 0
        """
    ).fetchone()
    return int(row["project_count"]) if row else 0


def _active_projects(
    connection: sqlite3.Connection,
    limit: int,
    project_name: Optional[str] = None,
) -> List[sqlite3.Row]:
    params: List[Any] = []
    project_filter = ""
    if project_name:
        project_filter = " AND lower(name) LIKE ?"
        params.append(f"%{project_name.lower()}%")

    params.append(limit)

    return connection.execute(
        f"""
        SELECT
          project_id,
          name,
          status,
          progress_percentage,
          current_milestone,
          next_action,
          priority
        FROM projects
        WHERE is_archived = 0
        {project_filter}
        ORDER BY
          CASE priority
            WHEN 'High' THEN 0
            WHEN 'Medium' THEN 1
            WHEN 'Low' THEN 2
            ELSE 3
          END,
          updated_at DESC
        LIMIT ?
        """,
        tuple(params),
    ).fetchall()


def _clean_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    text = str(value).strip()
    return text or None
