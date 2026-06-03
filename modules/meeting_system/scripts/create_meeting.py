#!/usr/bin/env python3
"""
Create a meeting folder in Omega OS.

Example:
python scripts/create_meeting.py --omega-root "D:/NEW_EARTH_OMEGA_OS_PACK" --date 2026-06-03 --project BIOCALM --person "Sahil" --title "BioCalm Sahil Update" --type "Google Meet"
"""
from pathlib import Path
import argparse, json, re, datetime

MONTHS = [
    'JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
    'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'
]

def slug(s: str) -> str:
    return re.sub(r'[^A-Za-z0-9]+', '_', s.strip()).strip('_').upper()

def month_folder(date_iso: str) -> str:
    dt = datetime.date.fromisoformat(date_iso)
    return f"{dt.month:02d}_{MONTHS[dt.month-1]}"

def write(path: Path, content: str):
    path.write_text(content.strip()+"\n", encoding='utf-8')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--omega-root', required=True)
    ap.add_argument('--date', required=True)
    ap.add_argument('--project', required=True)
    ap.add_argument('--person', required=True)
    ap.add_argument('--title', required=True)
    ap.add_argument('--type', default='Meeting')
    args = ap.parse_args()

    omega = Path(args.omega_root)
    base = omega/'21_PROJECTS_AND_PROGRAMMES'
    year = args.date[:4]
    folder_name = f"{args.date}_{slug(args.project)}_{slug(args.person)}"
    meeting_dir = base/'00_MEETINGS_AND_CALLS'/year/month_folder(args.date)/folder_name
    meeting_dir.mkdir(parents=True, exist_ok=True)
    for sub in ['attachments','audio_or_transcripts','exports_pdf']:
        (meeting_dir/sub).mkdir(exist_ok=True)

    write(meeting_dir/'00_AGENDA.md', f"""
# Agenda — {args.title}

| Field | Details |
|---|---|
| Date | {args.date} |
| Project | {args.project} |
| Person / Group | {args.person} |
| Meeting Type | {args.type} |

## Purpose


## Questions

- 

## Documents to show

- 
""")
    write(meeting_dir/'01_MEETING_NOTES.md', f"""
# Meeting Notes — {args.title}

## Summary


## Key points

- 

## Actions

| Action | Owner | Due Date | Status |
|---|---|---|---|
|  | Peter |  | Open |

## Decisions

- 

## Follow-up needed

- 
""")
    write(meeting_dir/'02_ACTIONS.md', """
# Actions

| Action | Owner | Due Date | Status | Notes |
|---|---|---|---|---|
|  | Peter |  | Open |  |
""")
    write(meeting_dir/'03_DECISIONS.md', """
# Decisions

| Decision | Reason | Impact | Status |
|---|---|---|---|
|  |  |  | Proposed |
""")
    write(meeting_dir/'04_FOLLOW_UP.md', """
# Follow-up

## Message draft

Hi [Name],

Thank you for the meeting today.

The key points I took from it were:

- 

My next steps are:

1. 

Thanks,
Peter

## Status

| Sent | Date Sent | Response | Next Step |
|---|---|---|---|
| No |  |  |  |
""")

    index_dir = base/'01_MASTER_INDEXES'
    index_dir.mkdir(parents=True, exist_ok=True)
    index_path = index_dir/'meeting_index.json'
    if index_path.exists():
        try:
            data = json.loads(index_path.read_text(encoding='utf-8'))
        except Exception:
            data = []
    else:
        data = []

    rec = {
        'id': f"meet_{args.date.replace('-', '_')}_{slug(args.project).lower()}_{slug(args.person).lower()}",
        'date': args.date,
        'project': args.project,
        'title': args.title,
        'person_or_group': args.person,
        'meeting_type': args.type,
        'status': 'open',
        'folder_path': str(meeting_dir).replace('\\','/'),
        'created_at': datetime.datetime.now().isoformat(timespec='seconds'),
        'updated_at': datetime.datetime.now().isoformat(timespec='seconds'),
        'tags': []
    }
    data = [x for x in data if x.get('id') != rec['id']]
    data.append(rec)
    index_path.write_text(json.dumps(data, indent=2), encoding='utf-8')

    print(f"Created meeting folder: {meeting_dir}")
    print(f"Updated index: {index_path}")

if __name__ == '__main__':
    main()
