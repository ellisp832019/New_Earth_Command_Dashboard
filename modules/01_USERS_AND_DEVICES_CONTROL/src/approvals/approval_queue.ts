import type { RegistryRecord } from '../types';
export function createApprovalRequest(request: RegistryRecord): RegistryRecord { return { ...request, status: 'pending', created_at: new Date().toISOString() }; }
export function approveRequest(request: RegistryRecord, approvedBy: string): RegistryRecord { return { ...request, status: 'approved', approved_by: approvedBy, resolved_at: new Date().toISOString() }; }
export function denyRequest(request: RegistryRecord, deniedBy: string, reason = ''): RegistryRecord { return { ...request, status: 'denied', denied_by: deniedBy, denial_reason: reason, resolved_at: new Date().toISOString() }; }
