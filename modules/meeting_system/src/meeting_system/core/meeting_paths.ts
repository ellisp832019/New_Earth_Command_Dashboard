export function slugify(input: string): string {
  return input
    .trim()
    .replace(/[^a-zA-Z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .toUpperCase();
}

export function monthFolder(dateIso: string): string {
  const date = new Date(dateIso + 'T00:00:00');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const names = [
    'JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
    'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'
  ];
  return `${month}_${names[date.getMonth()]}`;
}

export function buildMeetingFolderName(dateIso: string, project: string, personOrTopic: string): string {
  return `${dateIso}_${slugify(project)}_${slugify(personOrTopic)}`;
}

export function buildMeetingId(dateIso: string, project: string, personOrTopic: string): string {
  return `meet_${dateIso.replace(/-/g, '_')}_${slugify(project).toLowerCase()}_${slugify(personOrTopic).toLowerCase()}`;
}
