from pathlib import Path
import json
from datetime import datetime

CONFIG_PATH = Path(__file__).resolve().parents[1] / 'omega_os_bridge' / 'sync' / 'path_config.example.json'

def first_heading(text: str) -> str:
    for line in text.splitlines():
        if line.startswith('# '):
            return line[2:].strip()
    return 'Untitled Markdown File'

def main():
    config = json.loads(CONFIG_PATH.read_text(encoding='utf-8'))
    source = Path(config['companyOmegaPath'])
    output = Path(__file__).resolve().parents[1] / 'omega_os_bridge' / 'indexes' / 'company_index.generated.json'
    records = []
    if source.exists():
        for md in source.rglob('*.md'):
            text = md.read_text(encoding='utf-8', errors='ignore')
            records.append({'title': first_heading(text), 'relative_path': str(md.relative_to(source)), 'source_path': str(md), 'checkbox_count': text.count('- [ ]') + text.count('- [x]')})
    else:
        records.append({'title': 'Omega OS path not found on this machine', 'relative_path': '', 'source_path': str(source), 'checkbox_count': 0})
    output.write_text(json.dumps({'generated_at': datetime.now().isoformat(timespec='seconds'), 'source_path': str(source), 'records': records}, indent=2), encoding='utf-8')
    print(f'Wrote {output}')

if __name__ == '__main__':
    main()
