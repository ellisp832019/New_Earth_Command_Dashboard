import type { RegistryRecord } from '../types';
export function registerUser(user: RegistryRecord): RegistryRecord { return { ...user, created_at: new Date().toISOString(), status: user.status ?? 'active' }; }
export function getUserById(users: RegistryRecord[], userId: string): RegistryRecord | undefined { return users.find((user) => user.id === userId); }
