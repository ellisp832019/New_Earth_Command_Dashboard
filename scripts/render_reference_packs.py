from pathlib import Path

import fitz
from reportlab.lib.colors import Color, HexColor, white
from reportlab.lib.pagesizes import A4, landscape
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "output" / "pdf"
TREASURY_ASSET_DIR = ROOT / "docs" / "treasury_guide_assets"
COMPANY_ASSET_DIR = ROOT / "docs" / "company_command_centre_assets"
USER_GUIDE_ASSET_DIR = ROOT / "docs" / "user_guide_assets"


PAGE_SIZE = landscape(A4)
PAGE_WIDTH, PAGE_HEIGHT = PAGE_SIZE
BG = HexColor("#08131b")
CARD = HexColor("#0e2230")
LINE = HexColor("#53d5d0")
LIME = HexColor("#b6df43")
TEXT = white
MUTED = HexColor("#c9d3da")
BLUE = HexColor("#3ac7ff")
AMBER = HexColor("#ffc247")
GREEN = HexColor("#87d96c")
RED = HexColor("#ff7e72")


def ensure_dirs() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    TREASURY_ASSET_DIR.mkdir(parents=True, exist_ok=True)
    COMPANY_ASSET_DIR.mkdir(parents=True, exist_ok=True)
    USER_GUIDE_ASSET_DIR.mkdir(parents=True, exist_ok=True)


def start_page(pdf: canvas.Canvas, title: str, subtitle: str, page_label: str) -> None:
    pdf.setFillColor(BG)
    pdf.rect(0, 0, PAGE_WIDTH, PAGE_HEIGHT, fill=1, stroke=0)
    pdf.setFillColor(LIME)
    pdf.setFont("Helvetica-Bold", 24)
    pdf.drawString(42, PAGE_HEIGHT - 44, title)
    pdf.setFillColor(TEXT)
    pdf.setFont("Helvetica", 11)
    pdf.drawString(42, PAGE_HEIGHT - 64, subtitle)
    pdf.setStrokeColor(LINE)
    pdf.setLineWidth(2)
    pdf.line(42, PAGE_HEIGHT - 82, PAGE_WIDTH - 42, PAGE_HEIGHT - 82)
    pdf.setFont("Helvetica", 9)
    pdf.setFillColor(HexColor("#91a4b2"))
    pdf.drawString(42, 22, page_label)
    pdf.drawRightString(PAGE_WIDTH - 42, 22, "New Earth Command Dashboard")


def end_page(pdf: canvas.Canvas) -> None:
    pdf.showPage()


def draw_card(
    pdf: canvas.Canvas,
    x: float,
    y: float,
    w: float,
    h: float,
    title: str,
    accent: Color,
    bullets: list[str],
    footer: str | None = None,
) -> None:
    pdf.setFillColor(CARD)
    pdf.roundRect(x, y, w, h, 16, fill=1, stroke=0)
    pdf.setStrokeColor(accent)
    pdf.setLineWidth(1.2)
    pdf.roundRect(x, y, w, h, 16, fill=0, stroke=1)
    pdf.setFillColor(accent)
    pdf.circle(x + 32, y + h - 38, 16, fill=1, stroke=0)
    pdf.setFillColor(BG)
    pdf.setFont("Helvetica-Bold", 16)
    pdf.drawCentredString(x + 32, y + h - 44, title.split()[0][:1])
    pdf.setFillColor(TEXT)
    title_font_size = 18 if len(title) <= 18 else 16
    pdf.setFont("Helvetica-Bold", title_font_size)
    for index, line in enumerate(_wrap_text(title, 18 if title_font_size == 18 else 22)):
        pdf.drawString(x + 58, y + h - 45 - (index * 18), line)
    pdf.setStrokeColor(accent)
    pdf.line(x + 18, y + h - 70, x + w - 18, y + h - 70)
    pdf.setFillColor(MUTED)
    pdf.setFont("Helvetica", 11)
    bullet_y = y + h - 100
    for bullet in bullets:
        wrapped_lines = _wrap_text(bullet, 31)
        pdf.circle(x + 24, bullet_y + 4, 2.5, fill=1, stroke=0)
        for line_index, line in enumerate(wrapped_lines):
            pdf.drawString(x + 36, bullet_y - (line_index * 14), line)
        bullet_y -= max(24, 14 * len(wrapped_lines) + 10)
    if footer:
        pdf.setFillColor(accent)
        pdf.roundRect(x + 18, y + 12, w - 36, 32, 10, fill=0, stroke=1)
        pdf.setFont("Helvetica-Bold", 11)
        pdf.drawCentredString(x + (w / 2), y + 23, footer)


def draw_logic_strip(pdf: canvas.Canvas, title: str, items: list[tuple[str, str, Color]]) -> None:
    x = 60
    y = 86
    w = PAGE_WIDTH - 120
    h = 118
    pdf.setFillColor(HexColor("#0b1b28"))
    pdf.roundRect(x, y, w, h, 16, fill=1, stroke=0)
    pdf.setStrokeColor(HexColor("#28465b"))
    pdf.roundRect(x, y, w, h, 16, fill=0, stroke=1)
    pdf.setFillColor(LINE)
    pdf.setFont("Helvetica-Bold", 16)
    pdf.drawCentredString(PAGE_WIDTH / 2, y + h - 26, title)
    inner_y = y + 20
    box_w = (w - 60) / len(items)
    for index, (label, note, accent) in enumerate(items):
        box_x = x + 20 + (box_w * index)
        pdf.setStrokeColor(accent)
        pdf.roundRect(box_x, inner_y, box_w - 20, 58, 12, fill=0, stroke=1)
        pdf.setFillColor(accent)
        pdf.setFont("Helvetica-Bold", 15)
        pdf.drawCentredString(box_x + (box_w - 20) / 2, inner_y + 34, label)
        pdf.setFillColor(MUTED)
        pdf.setFont("Helvetica", 10)
        for line_index, line in enumerate(_wrap_text(note, 18)):
            pdf.drawCentredString(
                box_x + (box_w - 20) / 2,
                inner_y + 18 - (line_index * 10),
                line,
            )


def _wrap_text(text: str, max_chars: int) -> list[str]:
    words = text.split()
    if not words:
        return [text]

    lines: list[str] = []
    current = words[0]
    for word in words[1:]:
        candidate = f"{current} {word}"
        if len(candidate) <= max_chars:
            current = candidate
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return lines


def build_treasury_pack(pdf_path: Path) -> None:
    pdf = canvas.Canvas(str(pdf_path), pagesize=PAGE_SIZE)
    pdf.setTitle("Treasury Weekly Reference Pack")

    start_page(
        pdf,
        "Treasury Weekly Reference Pack",
        "A calm two-page finance pack for weekly review and decision language.",
        "Page 1 of 2 - Weekly rhythm",
    )
    draw_card(
        pdf,
        52,
        140,
        220,
        300,
        "1 Open Treasury",
        BLUE,
        [
            "Open Treasury from the More hub",
            "Check Safe, Watch, Pause, Decision",
            "Look at receipts waiting to be sorted",
            "Stay in the front end the whole time",
        ],
        "Start with one calm glance",
    )
    draw_card(
        pdf,
        292,
        140,
        220,
        300,
        "2 Weekly Ritual",
        LINE,
        [
            "Press Weekly Ritual",
            "Fill only the fields that matter now",
            "Use the low-energy path if needed",
            "Save a simple truthful picture",
        ],
        "Small reviews still count",
    )
    draw_card(
        pdf,
        532,
        140,
        220,
        300,
        "3 Tell Peter",
        LIME,
        [
            "Green means safe",
            "Yellow means watch",
            "Red means pause",
            "Blue means decision needed",
        ],
        "Simple truth beats finance fog",
    )
    draw_logic_strip(
        pdf,
        "Weekly loop",
        [
            ("Open", "Treasury home", BLUE),
            ("Review", "Safe / Watch / Pause", LINE),
            ("Save", "Weekly ritual", AMBER),
            ("Share", "Simple truth", LIME),
        ],
    )
    end_page(pdf)

    start_page(
        pdf,
        "Treasury Decision Language",
        "Use stable words so money review stays kind, clear, and non-dramatic.",
        "Page 2 of 2 - Money language",
    )
    draw_card(
        pdf,
        60,
        174,
        300,
        260,
        "Use",
        GREEN,
        [
            "Safe",
            "Watch",
            "Pause",
            "Needs decision",
            "Future investment",
            "Sorted / Done",
        ],
        "Language that protects clarity",
    )
    draw_card(
        pdf,
        396,
        174,
        300,
        260,
        "Avoid",
        RED,
        [
            "Panic",
            "Failure",
            "Bad",
            "Crisis",
            "You spent too much",
            "Blame",
        ],
        "Language that increases stress",
    )
    draw_logic_strip(
        pdf,
        "Shared rule",
        [
            ("Personal", "Protect peace", BLUE),
            ("Mission", "Build New Earth", LINE),
            ("Boundary", "Do not damage home", AMBER),
        ],
    )
    end_page(pdf)
    pdf.save()


def build_company_pack(pdf_path: Path) -> None:
    pdf = canvas.Canvas(str(pdf_path), pagesize=PAGE_SIZE)
    pdf.setTitle("Company Command Centre Founder Pack")

    start_page(
        pdf,
        "Company Command Centre Founder Pack",
        "Weekly founder ops reference for website, LinkedIn, evidence, and director actions.",
        "Page 1 of 2 - Founder ops map",
    )
    draw_card(
        pdf,
        52,
        140,
        220,
        300,
        "1 Review Board",
        BLUE,
        [
            "Open Director Action Board",
            "Check Today / This Week / This Month",
            "Keep only the clearest next actions",
            "Do not add noise for the sake of activity",
        ],
        "Reduce overwhelm first",
    )
    draw_card(
        pdf,
        292,
        140,
        220,
        300,
        "2 Public Presence",
        LINE,
        [
            "Open Website & Brand",
            "Open LinkedIn & Marketing",
            "Pull source-linked proof into copy",
            "Keep messaging aligned with real work",
        ],
        "Evidence-backed visibility",
    )
    draw_card(
        pdf,
        532,
        140,
        220,
        300,
        "3 Founder Hygiene",
        LIME,
        [
            "Check urgent compliance items",
            "Review finance summary at month end",
            "Capture evidence from meaningful work",
            "Back up before any future write-back",
        ],
        "Keep the record trustworthy",
    )
    draw_logic_strip(
        pdf,
        "Company weekly operating rhythm",
        [
            ("Board", "Choose what matters", BLUE),
            ("Proof", "Collect evidence", LINE),
            ("Publish", "Website + LinkedIn", AMBER),
            ("Review", "Monthly company state", LIME),
        ],
    )
    end_page(pdf)

    start_page(
        pdf,
        "Website And LinkedIn Workflow",
        "How the dashboard can enrich public presence without turning into another social platform.",
        "Page 2 of 2 - Website and LinkedIn",
    )
    draw_card(
        pdf,
        60,
        174,
        300,
        260,
        "Website flow",
        BLUE,
        [
            "Use Website board for page-level status",
            "Keep statuses Planned / Drafting / Ready",
            "Link each row to a source file",
            "Let website pages reflect real product proof",
        ],
        "Treat the site as structured evidence",
    )
    draw_card(
        pdf,
        396,
        174,
        300,
        260,
        "LinkedIn flow",
        LINE,
        [
            "Keep destination URL saved in Settings",
            "Use profile copy and content bank in the tab",
            "Convert evidence into weekly post ideas",
            "Open LinkedIn only when you are ready to publish",
        ],
        "Use the dashboard as the prep layer",
    )
    draw_logic_strip(
        pdf,
        "Simple content ladder",
        [
            ("Build", "Do the real work", BLUE),
            ("Capture", "Store proof locally", LINE),
            ("Refine", "Shape the story", AMBER),
            ("Publish", "Open website or LinkedIn", LIME),
        ],
    )
    end_page(pdf)
    pdf.save()


def build_users_recovery_pack(pdf_path: Path) -> None:
    pdf = canvas.Canvas(str(pdf_path), pagesize=PAGE_SIZE)
    pdf.setTitle("Users And Devices Recovery Drills Pack")

    start_page(
        pdf,
        "Users & Devices Recovery Drills",
        "A two-page drill pack for PIN recovery and device trust support.",
        "Page 1 of 2 - PIN recovery drill",
    )
    draw_card(
        pdf,
        52,
        140,
        220,
        300,
        "1 Pick User",
        BLUE,
        [
            "Open Users & Devices",
            "Open PIN Registry",
            "Choose the affected user",
            "Check current active and recovery status",
        ],
        "Confirm the right identity first",
    )
    draw_card(
        pdf,
        292,
        140,
        220,
        300,
        "2 Issue Recovery",
        AMBER,
        [
            "Issue a recovery PIN",
            "Share it through a safe local path",
            "Ask the user to unlock with it",
            "Confirm access and audit trail",
        ],
        "Temporary path back in",
    )
    draw_card(
        pdf,
        532,
        140,
        220,
        300,
        "3 Close The Loop",
        LIME,
        [
            "Set a fresh primary PIN",
            "Revoke the recovery PIN",
            "Retest Security Lock",
            "Check latest audit event",
        ],
        "Recovery PINs should not linger",
    )
    draw_logic_strip(
        pdf,
        "Recovery rule",
        [
            ("Temporary", "Recovery only", AMBER),
            ("Replace", "Fresh primary PIN", BLUE),
            ("Revoke", "Close old path", RED),
            ("Verify", "Audit + unlock", LIME),
        ],
    )
    end_page(pdf)

    start_page(
        pdf,
        "Users & Devices Trust Drill",
        "Walk a device from review state to trusted access without skipping the checks.",
        "Page 2 of 2 - Device trust drill",
    )
    draw_card(
        pdf,
        52,
        140,
        220,
        300,
        "1 Inspect Device",
        BLUE,
        [
            "Open Devices",
            "Check owner, trust level, and posture",
            "Look for Blocked or Needs review",
            "Confirm which user the device belongs to",
        ],
        "Trust starts with the record",
    )
    draw_card(
        pdf,
        292,
        140,
        220,
        300,
        "2 Onboard",
        LINE,
        [
            "Open Device Onboarding",
            "Complete the local review steps",
            "Link the device to the correct user",
            "Confirm trust posture improves",
        ],
        "High trust is earned, not assumed",
    )
    draw_card(
        pdf,
        532,
        140,
        220,
        300,
        "3 Verify Access",
        LIME,
        [
            "Open Security Lock",
            "Select the same user and device",
            "Unlock with the real primary PIN",
            "Check audit and module route access",
        ],
        "Trusted devices still need user proof",
    )
    draw_logic_strip(
        pdf,
        "Readiness logic",
        [
            ("Identity", "Correct local user", BLUE),
            ("PIN", "Primary unlock path", AMBER),
            ("Trust", "Device posture ready", LINE),
            ("Audit", "Decision recorded", LIME),
        ],
    )
    end_page(pdf)
    pdf.save()


def render_preview_pages(pdf_path: Path, output_dir: Path, prefix: str) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    pdf = fitz.open(pdf_path)
    for index, page in enumerate(pdf):
        pixmap = page.get_pixmap(matrix=fitz.Matrix(1.5, 1.5), alpha=False)
        pixmap.save(output_dir / f"{prefix}_page_{index + 1}.png")


def main() -> None:
    ensure_dirs()

    treasury_pdf = OUTPUT_DIR / "treasury_weekly_reference_pack.pdf"
    company_pdf = OUTPUT_DIR / "company_command_centre_founder_pack.pdf"
    users_pdf = OUTPUT_DIR / "users_devices_recovery_drills_pack.pdf"

    build_treasury_pack(treasury_pdf)
    build_company_pack(company_pdf)
    build_users_recovery_pack(users_pdf)

    render_preview_pages(
        treasury_pdf,
        TREASURY_ASSET_DIR,
        "treasury_weekly_reference_pack",
    )
    render_preview_pages(
        company_pdf,
        COMPANY_ASSET_DIR,
        "company_command_centre_founder_pack",
    )
    render_preview_pages(
        users_pdf,
        USER_GUIDE_ASSET_DIR,
        "users_devices_recovery_drills_pack",
    )

    print(treasury_pdf)
    print(company_pdf)
    print(users_pdf)


if __name__ == "__main__":
    main()
