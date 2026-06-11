from __future__ import annotations

from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import Any, Dict
import uvicorn

app = FastAPI(title="Mock New Earth Dashboard API", version="0.1.0")


class CommandRequest(BaseModel):
    command: str
    slots: Dict[str, Any] = Field(default_factory=dict)


@app.get("/health")
def health():
    return {"ok": True, "service": "mock-dashboard"}


@app.post("/voice/command")
def voice_command(req: CommandRequest):
    command = req.command
    slots = req.slots

    if command == "dashboard.summary.today":
        return {"speech": "Today you are focused on New Earth Dashboard, MicroGrow, and the Alexa voice gateway module."}

    if command == "dashboard.project.status.read":
        return {"speech": "Project status mock: your current project work is on track, read-only, and safely reported through the gateway."}

    if command == "microgrow.status.read":
        return {"speech": "MicroGrow mock status: node online, temperature 23.4 degrees, humidity 51 percent, relays unchanged."}

    if command == "dashboard.note.add":
        note = slots.get("note", "empty note")
        return {"speech": f"I added this dashboard note: {note}"}

    if command == "dashboard.task.add":
        task = slots.get("task", "new task")
        return {"speech": f"I added this task to your dashboard inbox: {task}"}

    if command == "dashboard.focus.start":
        return {"speech": "Focus mode started. I have logged a protected build session."}

    if command == "dashboard.tasks.next":
        return {"speech": "Your next tasks are: test the gateway, connect the Alexa skill, then wire the real dashboard adapter."}

    if command == "gateway.health.read":
        return {"speech": "The voice gateway and mock dashboard are responding."}

    return {"speech": "The mock dashboard received the command but does not have a handler for it yet."}


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8099)
