import type { RegistryRecord } from '../types';
export function assignRole(user: RegistryRecord, role: string): RegistryRecord { return { ...user, role, updated_at: new Date().toISOString() }; }
export function getRolePermissions(roles: RegistryRecord[], roleName: string): string[] { const role = roles.find((item) => item.role === roleName); return Array.isArray(role?.permissions) ? role.permissions as string[] : []; }
