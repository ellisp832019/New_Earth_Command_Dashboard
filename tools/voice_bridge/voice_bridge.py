"""
New Earth Dashboard Voice Bridge v0.1

This first version is deliberately safe:
- No live microphone access yet.
- No automatic Codex execution.
- User types or pastes a transcript.
- The bridge formats it into a Codex-safe prompt.
- The result is saved to logs/voice_commands.log.
"""

from datetime import datetime
from pathlib import Path


PROMPT_TEMPLATE = """You are working inside the New Earth Dashboard repo.

User voice command:
{transcript}

Rules:
- Make minimal, high-confidence changes.
- Explain what files you changed.
- Do not delete existing work.
- Do not make destructive changes.
- Ask for approval before major rewrites.
"""


def format_codex_prompt(transcript: str) -> str:
    return PROMPT_TEMPLATE.format(transcript=transcript.strip())


def save_log(transcript: str, output_text: str) -> Path:
    log_dir = Path(__file__).parent / "logs"
    log_dir.mkdir(exist_ok=True)

    log_path = log_dir / "voice_commands.log"
    timestamp = datetime.now().isoformat(timespec="seconds")

    with log_path.open("a", encoding="utf-8") as file:
      file.write("\n" + "=" * 70 + "\n")
      file.write(f"Timestamp: {timestamp}\n")
      file.write("Transcript:\n")
      file.write(transcript.strip() + "\n\n")
      file.write("Output:\n")
      file.write(output_text.strip() + "\n")

    return log_path


def main() -> None:
    print("New Earth Dashboard Voice Bridge v0.1")
    print("Text-input safety prototype")
    print("-" * 50)

    transcript = input("Paste or type your voice transcript: ").strip()

    if not transcript:
        print("No transcript entered. Exiting.")
        return

    print("\nTranscript preview:")
    print(transcript)

    choice = input("\nFormat this as a Codex prompt? (y/n): ").strip().lower()

    if choice == "y":
        output_text = format_codex_prompt(transcript)
        print("\nCodex-safe prompt:")
    else:
        output_text = transcript
        print("\nPlain transcript:")

    print("-" * 50)
    print(output_text)
    print("-" * 50)

    log_path = save_log(transcript, output_text)
    print(f"\nSaved to: {log_path}")
    print("\nReview this output before using it in Codex.")


if __name__ == "__main__":
    main()
