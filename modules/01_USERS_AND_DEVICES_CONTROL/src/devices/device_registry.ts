import type { RegistryRecord } from '../types';
export function registerDevice(device: RegistryRecord): RegistryRecord { return { ...device, created_at: new Date().toISOString(), status: device.status ?? 'registered' }; }
export function getDeviceById(devices: RegistryRecord[], deviceId: string): RegistryRecord | undefined { return devices.find((device) => device.id === deviceId); }
