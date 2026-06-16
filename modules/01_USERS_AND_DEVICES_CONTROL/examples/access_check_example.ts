import { canPerformAction } from '../src/access/access_policy_engine';
const actor = { id: 'user_peter_owner', permissions: ['*'] };
const device = { id: 'device_new_earth_dev', trust_level: 4 };
const financeRule = { view_permission: 'finance.view', requires_trust_level: 4, requires_approval_for: ['export_data'] };
console.log(canPerformAction(actor, device, financeRule, 'export_data'));
