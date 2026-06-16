export function createPairingCode(): string { return Math.random().toString(36).slice(2, 8).toUpperCase(); }
export function validatePairingCode(input: string, expected: string): boolean { return input.trim().toUpperCase() === expected.trim().toUpperCase(); }
