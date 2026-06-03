#!/usr/bin/env python3
"""
Rebuild meeting_index.json by scanning meeting folders.
"""
from pathlib import Path
import argparse, json, re, datetime

DATE_RE = re.compile(r'^(\d{4}-\d{2}-\d{2})_(.+)$')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--omega-root', required=True)
    args = ap.parse_args()
    base = Path(args.omega_root)/'21_PROJECTS_AND_PROGRAMMES'
    meetings = base/'00_MEETINGS_AND_CALLS'
    records = []
    for folder in meetings.rglob('*'):
        if not folder.is_dir():
            continue
        m = DATE_RE.match(folder.name)
        if not m:
            continue
        date = m.group(1)
        rest = m.group(2)
        parts = rest.split('_')
        project = parts[0] if parts else 'UNKNOWN'
        person = ' '.join(parts[1:]) if len(parts) > 1 else ''
        records.append({
            'id': f"meet_{date.replace('-', '_')}_{rest.lower()}",
            'date': date,
            'project': project,
            'title': folder.name,
            'person_or_group': person,
            'meeting_type': '',
            'status': 'open',
            'folder_path': str(folder).replace('\\','/'),
            'created_at': '',
            'updated_at': datetime.datetime.now().isoformat(timespec='seconds'),
            'tags': []
        })
    outdir = base/'01_MASTER_INDEXES'
    outdir.mkdir(parents=True, exist_ok=True)
    out = outdir/'meeting_index.json'
    out.write_text(json.dumps(sorted(records, key=lambda x: x['date'], reverse=True), indent=2), encoding='utf-8')
    print(f"Wrote {len(records)} records to {out}")

if __name__ == '__main__':
    main()
