export const DEVICE_TYPES = ['pc','phone','tablet','microgrow_node','esp32_device','voice_gateway','local_ai_runtime','knowledge_bridge','storage_device','printer','scanner','camera','local_hub','xr_device','unknown'] as const;
export type DeviceType = typeof DEVICE_TYPES[number];
