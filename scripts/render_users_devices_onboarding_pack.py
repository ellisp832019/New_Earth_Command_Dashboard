from pathlib import Path

from reportlab.lib.colors import HexColor, white
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.utils import ImageReader
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "docs" / "user_guide_assets"
OUTPUT_DIR = ROOT / "output" / "pdf"
TMP_DIR = ROOT / "tmp" / "pdfs"


def draw_header(pdf: canvas.Canvas, title: str, subtitle: str) -> None:
    width, height = landscape(A4)
    pdf.setFillColor(HexColor("#07131b"))
    pdf.rect(0, 0, width, height, stroke=0, fill=1)

    pdf.setFillColor(HexColor("#b6df43"))
    pdf.setFont("Helvetica-Bold", 24)
    pdf.drawString(42, height - 46, title)

    pdf.setFillColor(white)
    pdf.setFont("Helvetica", 11)
    pdf.drawString(42, height - 66, subtitle)

    pdf.setStrokeColor(HexColor("#58d5cf"))
    pdf.setLineWidth(2)
    pdf.line(42, height - 82, width - 42, height - 82)


def draw_footer(pdf: canvas.Canvas, footer: str) -> None:
    width, _ = landscape(A4)
    pdf.setFillColor(HexColor("#8ea0ad"))
    pdf.setFont("Helvetica", 9)
    pdf.drawString(42, 22, footer)
    pdf.drawRightString(width - 42, 22, "New Earth Command Dashboard")


def place_image_page(
    pdf: canvas.Canvas,
    image_path: Path,
    title: str,
    subtitle: str,
    footer: str,
) -> None:
    width, height = landscape(A4)
    draw_header(pdf, title, subtitle)

    image = ImageReader(str(image_path))
    image_width, image_height = image.getSize()
    available_width = width - 84
    available_height = height - 150
    scale = min(available_width / image_width, available_height / image_height)
    draw_width = image_width * scale
    draw_height = image_height * scale
    x = (width - draw_width) / 2
    y = 42 + max(0, (available_height - draw_height) / 2)

    pdf.drawImage(
        image,
        x,
        y,
        width=draw_width,
        height=draw_height,
        preserveAspectRatio=True,
        mask="auto",
    )
    draw_footer(pdf, footer)
    pdf.showPage()


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    TMP_DIR.mkdir(parents=True, exist_ok=True)

    output_path = OUTPUT_DIR / "users_devices_onboarding_pack.pdf"
    pdf = canvas.Canvas(str(output_path), pagesize=landscape(A4))
    pdf.setTitle("Users & Devices Onboarding Pack")
    pdf.setAuthor("OpenAI Codex")
    pdf.setSubject("Printable onboarding readiness and handoff pack")

    place_image_page(
        pdf,
        ASSET_DIR / "users_devices_onboarding_rendered_map.png",
        "Users & Devices Onboarding Readiness Map",
        "Track role, PIN, trust, and audit checkpoints before unlock.",
        "Page 1 of 2 - Readiness map",
    )
    place_image_page(
        pdf,
        ASSET_DIR / "users_devices_onboarding_rendered_cheatsheet.png",
        "Users & Devices Handoff Cheat Sheet",
        "Use this quick reference for onboarding, unlock, and recovery support.",
        "Page 2 of 2 - Handoff cheat sheet",
    )

    pdf.save()
    print(output_path)


if __name__ == "__main__":
    main()
