import type { RegistryRecord } from '../types';
export function checkPermission(actor: RegistryRecord | undefined, permission: string): boolean { if (!actor) return false; const permissions = Array.isArray(actor.permissions) ? actor.permissions as string[] : []; return permissions.includes('*') || permissions.includes(permission); }
