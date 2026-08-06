type Props = { label?: string; value?: string | number | boolean };
export function ApprovalRequestCard({ label = 'ApprovalRequestCard', value = '' }: Props) {
  return <div className="omega-card"><strong>{label}</strong>{value !== '' && <span>{String(value)}</span>}</div>;
}
