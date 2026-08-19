import 'engineering_snapshot_envelope.dart';

/// Future NEOS-side read contract for engineering snapshot delivery.
///
/// The dashboard should use this contract only for read-only snapshot
/// acquisition. It intentionally exposes no write operations and no transport
/// concepts.
abstract class NeosEngineeringSnapshotReader {
  Future<EngineeringSnapshotEnvelope> loadEngineeringSnapshot({
    String? projectScope,
  });
}
