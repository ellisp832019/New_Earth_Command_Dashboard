export type VoiceIntentName =
  | 'dashboard.note.create'
  | 'dashboard.task.create'
  | 'meeting.summary.create'
  | 'microgrow.status.read'
  | 'microgrow.relay.set'
  | 'unknown';

export interface RoutedIntent {
  intent: VoiceIntentName;
  confidence: number;
  requiresAction: boolean;
}

export function routeVoiceText(text: string): RoutedIntent {
  const normalized = text.toLowerCase();

  if (normalized.includes('temperature') || normalized.includes('humidity') || normalized.includes('microgrow status')) {
    return { intent: 'microgrow.status.read', confidence: 0.9, requiresAction: false };
  }

  if (normalized.includes('relay') || normalized.includes('mist')) {
    return { intent: 'microgrow.relay.set', confidence: 0.75, requiresAction: true };
  }

  if (normalized.includes('task')) {
    return { intent: 'dashboard.task.create', confidence: 0.8, requiresAction: true };
  }

  if (normalized.includes('meeting') || normalized.includes('summary')) {
    return { intent: 'meeting.summary.create', confidence: 0.8, requiresAction: true };
  }

  if (normalized.includes('note') || normalized.includes('log')) {
    return { intent: 'dashboard.note.create', confidence: 0.8, requiresAction: true };
  }

  return { intent: 'unknown', confidence: 0.2, requiresAction: false };
}
