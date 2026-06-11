export interface MicroGrowStatus {
  nodeOnline: boolean;
  temperatureC: number | null;
  humidityPercent: number | null;
  relays: Record<string, boolean>;
  warnings: string[];
}

export async function getMicroGrowStatusMock(): Promise<MicroGrowStatus> {
  return {
    nodeOnline: true,
    temperatureC: 23.4,
    humidityPercent: 51.2,
    relays: {
      ch1: false,
      ch2: false,
      ch3: true
    },
    warnings: []
  };
}

export function formatMicroGrowVoiceReply(status: MicroGrowStatus): string {
  if (!status.nodeOnline) {
    return 'MicroGrow is not currently online. Check the hub connection and node power.';
  }

  const temp = status.temperatureC ?? 'unknown';
  const humidity = status.humidityPercent ?? 'unknown';
  const warnings = status.warnings.length ? status.warnings.join(', ') : 'no warnings';

  return `MicroGrow is online. Temperature is ${temp} degrees Celsius, humidity is ${humidity} percent, and there are ${warnings}.`;
}
