import type { RegistryRecord } from '../types';
export function createAuditEvent(event: RegistryRecord): RegistryRecord { return { event_id: event.event_id ?? `audit_${Date.now()}`, timestamp: new Date().toISOString(), ...event }; }
