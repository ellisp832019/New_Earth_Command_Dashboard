"""Starter tool mapping for GAIA dashboard actions."""

ALLOWED_STARTER_ACTIONS = {
    "open_microgrow": {"intent": "open_module", "module": "microgrow", "action": "view_status"},
    "open_obsidian": {"intent": "open_module", "module": "obsidian", "action": "open"},
    "show_today": {"intent": "dashboard_query", "module": "dashboard", "action": "today_overview"},
    "open_assets": {"intent": "open_module", "module": "asset_intelligence", "action": "open"},
}


def map_phrase_to_action(text: str) -> dict | None:
    t = text.lower().strip()
    if "microgrow" in t:
        return ALLOWED_STARTER_ACTIONS["open_microgrow"]
    if "obsidian" in t or "vault" in t:
        return ALLOWED_STARTER_ACTIONS["open_obsidian"]
    if "today" in t:
        return ALLOWED_STARTER_ACTIONS["show_today"]
    if "asset" in t or "equipment" in t:
        return ALLOWED_STARTER_ACTIONS["open_assets"]
    return None
