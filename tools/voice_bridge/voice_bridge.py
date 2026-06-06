"""
New Earth Dashboard Voice Bridge

This version can capture one desktop microphone utterance and transcribe it
locally when the optional speech dependencies are installed.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any


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


@dataclass
class CaptureResult:
    transcript: str
    model: str
    duration_seconds: int
    sampled_seconds: float
    segments: list[dict[str, Any]]


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


def _load_transcription_stack() -> tuple[Any, Any, Any]:
    _ensure_ffmpeg_on_path()
    try:
        import numpy as np  # type: ignore
        import sounddevice as sd  # type: ignore
        from faster_whisper import WhisperModel  # type: ignore
    except Exception as exc:  # pragma: no cover - runtime dependency loading
        raise RuntimeError(
            "Missing desktop speech dependencies. Install the packages in "
            "tools/voice_bridge/requirements.txt."
        ) from exc

    return np, sd, WhisperModel


def _ensure_ffmpeg_on_path() -> None:
    if shutil.which("ffmpeg") is not None:
        return

    candidates = [
        Path(os.environ.get("LOCALAPPDATA", ""))
        / "Microsoft"
        / "WinGet"
        / "Links"
        / "ffmpeg.exe",
        Path(os.environ.get("ProgramData", ""))
        / "chocolatey"
        / "bin"
        / "ffmpeg.exe",
        Path(os.environ.get("ProgramFiles", "")) / "ffmpeg" / "bin" / "ffmpeg.exe",
        Path(os.environ.get("ProgramFiles(x86)", ""))
        / "ffmpeg"
        / "bin"
        / "ffmpeg.exe",
    ]

    for candidate in candidates:
        if candidate.exists():
            os.environ["PATH"] = (
                str(candidate.parent) + os.pathsep + os.environ.get("PATH", "")
            )
            return


def _record_audio(duration_seconds: int, samplerate: int = 16000):
    np, sd, _ = _load_transcription_stack()
    frames = int(duration_seconds * samplerate)
    audio = sd.rec(
        frames,
        samplerate=samplerate,
        channels=1,
        dtype="float32",
    )
    sd.wait()
    return np.squeeze(audio)


def transcribe_once(
    *,
    duration_seconds: int = 8,
    model_name: str | None = None,
    language: str = "en",
) -> CaptureResult:
    np, _, WhisperModel = _load_transcription_stack()
    audio = _record_audio(duration_seconds)
    if audio is None or getattr(audio, "size", 0) == 0:
        return CaptureResult("", model_name or "unknown", duration_seconds, 0.0, [])

    normalized_audio = np.asarray(audio, dtype="float32")
    model_label = model_name or os.environ.get("VOICE_BRIDGE_MODEL", "base.en")
    model = WhisperModel(
        model_label,
        device=os.environ.get("VOICE_BRIDGE_DEVICE", "cpu"),
        compute_type=os.environ.get("VOICE_BRIDGE_COMPUTE_TYPE", "int8"),
    )
    segments, _info = model.transcribe(
        normalized_audio,
        language=language,
        vad_filter=True,
        beam_size=5,
    )

    transcript_parts = [segment.text.strip() for segment in segments if segment.text.strip()]
    transcript = " ".join(transcript_parts).strip()
    return CaptureResult(
        transcript=transcript,
        model=model_label,
        duration_seconds=duration_seconds,
        sampled_seconds=float(normalized_audio.shape[0]) / 16000.0,
        segments=[
            {
                "start": round(float(segment.start), 2),
                "end": round(float(segment.end), 2),
                "text": segment.text.strip(),
            }
            for segment in segments
            if segment.text.strip()
        ],
    )


def transcribe_file(
    source_path: str,
    *,
    model_name: str | None = None,
    language: str = "en",
    draft_output_path: str | None = None,
) -> CaptureResult:
    _, _, WhisperModel = _load_transcription_stack()
    media_path = Path(source_path)
    if not media_path.exists():
        raise FileNotFoundError(f"Source file not found: {source_path}")

    model_label = model_name or os.environ.get("VOICE_BRIDGE_MODEL", "base.en")
    model = WhisperModel(
        model_label,
        device=os.environ.get("VOICE_BRIDGE_DEVICE", "cpu"),
        compute_type=os.environ.get("VOICE_BRIDGE_COMPUTE_TYPE", "int8"),
    )
    draft_path = Path(draft_output_path).expanduser() if draft_output_path else None
    if draft_path is not None:
        draft_path.parent.mkdir(parents=True, exist_ok=True)
        if draft_path.exists():
            draft_path.unlink()
    segments, _info = model.transcribe(
        str(media_path),
        language=language,
        vad_filter=True,
        beam_size=5,
    )

    segment_payloads = []
    transcript_parts = []
    for segment in segments:
        text = segment.text.strip()
        if not text:
            continue
        transcript_parts.append(text)
        segment_payloads.append(
            {
                "start": round(float(segment.start), 2),
                "end": round(float(segment.end), 2),
                "text": text,
            }
        )
        if draft_path is not None:
            _write_draft_transcript(draft_path, segment_payloads)
    transcript = " ".join(transcript_parts).strip()
    return CaptureResult(
        transcript=transcript,
        model=model_label,
        duration_seconds=0,
        sampled_seconds=0.0,
        segments=segment_payloads,
    )


def _write_draft_transcript(draft_path: Path, segments: list[dict[str, Any]]) -> None:
    lines = ["# Draft Transcript", ""]
    for segment in segments:
        start = _format_timestamp_segment(segment["start"])
        end = _format_timestamp_segment(segment["end"])
        lines.append(f"[{start} - {end}] {segment['text']}")
    draft_path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")


def _format_timestamp_segment(seconds: Any) -> str:
    try:
        total_seconds = max(0, int(float(seconds)))
    except Exception:
        total_seconds = 0
    minutes = total_seconds // 60
    remaining_seconds = total_seconds % 60
    return f"{minutes:02d}:{remaining_seconds:02d}"


def _print_json(payload: dict[str, Any]) -> None:
    print(json.dumps(payload, ensure_ascii=False))


def main() -> int:
    parser = argparse.ArgumentParser(description="New Earth Dashboard Voice Bridge")
    subparsers = parser.add_subparsers(dest="command")

    listen_parser = subparsers.add_parser("listen-once", help="Record and transcribe one utterance")
    listen_parser.add_argument("--duration", type=int, default=8, help="Maximum capture length in seconds")
    listen_parser.add_argument("--model", type=str, default=None, help="Whisper model name")
    listen_parser.add_argument("--language", type=str, default="en", help="Language code")
    listen_parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON")

    file_parser = subparsers.add_parser(
        "transcribe-file",
        help="Transcribe a local audio or video file with Whisper",
    )
    file_parser.add_argument("source_path", help="Path to the audio or video file")
    file_parser.add_argument("--model", type=str, default=None, help="Whisper model name")
    file_parser.add_argument("--language", type=str, default="en", help="Language code")
    file_parser.add_argument(
        "--draft-output",
        type=str,
        default=None,
        help="Optional path to a draft transcript file that updates while Whisper runs",
    )
    file_parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON")

    prompt_parser = subparsers.add_parser("prompt", help="Format a transcript as a Codex prompt")
    prompt_parser.add_argument("transcript", nargs="?", default="", help="Transcript text")

    args = parser.parse_args()

    if args.command == "listen-once":
        try:
            capture = transcribe_once(
                duration_seconds=args.duration,
                model_name=args.model,
                language=args.language,
            )
        except Exception as exc:
            if args.json:
                _print_json({
                    "ok": False,
                    "error": str(exc),
                })
            else:
                print(f"Voice capture failed: {exc}", file=sys.stderr)
            return 1

        payload = {
            "ok": True,
            "transcript": capture.transcript,
            "model": capture.model,
            "duration_seconds": capture.duration_seconds,
            "sampled_seconds": round(capture.sampled_seconds, 2),
            "segments": capture.segments,
        }
        if args.json:
            _print_json(payload)
        else:
            print(capture.transcript)
        return 0

    if args.command == "prompt":
        transcript = args.transcript.strip()
        if not transcript:
            print("No transcript entered. Exiting.")
            return 0

        output_text = format_codex_prompt(transcript)
        print(output_text)
        save_log(transcript, output_text)
        return 0

    if args.command == "transcribe-file":
        try:
            capture = transcribe_file(
                args.source_path,
                model_name=args.model,
                language=args.language,
                draft_output_path=args.draft_output,
            )
        except Exception as exc:
            if args.json:
                _print_json({
                    "ok": False,
                    "error": str(exc),
                })
            else:
                print(f"File transcription failed: {exc}", file=sys.stderr)
            return 1

        payload = {
            "ok": True,
            "transcript": capture.transcript,
            "model": capture.model,
            "duration_seconds": capture.duration_seconds,
            "sampled_seconds": round(capture.sampled_seconds, 2),
            "segments": capture.segments,
        }
        if args.json:
            _print_json(payload)
        else:
            print(capture.transcript)
        return 0

    print("New Earth Dashboard Voice Bridge")
    print("Try: python tools/voice_bridge/voice_bridge.py listen-once --json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
