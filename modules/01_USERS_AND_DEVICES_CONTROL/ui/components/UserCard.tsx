type Props = { label?: string; value?: string | number | boolean };
export function UserCard({ label = 'UserCard', value = '' }: Props) {
  return <div className="omega-card"><strong>{label}</strong>{value !== '' && <span>{String(value)}</span>}</div>;
}
