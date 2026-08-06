import type { RegistryRecord } from '../types';
export function checkDeviceTrust(device: RegistryRecord | undefined, requiredTrustLevel: number): boolean { if (!device) return false; const level = Number(device.trust_level ?? 0); return level >= requiredTrustLevel; }
export function setDeviceTrust(device: RegistryRecord, trustLevel: number): RegistryRecord { return { ...device, trust_level: trustLevel, updated_at: new Date().toISOString() }; }
