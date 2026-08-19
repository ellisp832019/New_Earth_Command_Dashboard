import 'engineering_models.dart';
import 'engineering_snapshot_metadata.dart';

/// Immutable read envelope for a future authoritative engineering snapshot.
///
/// The envelope keeps the payload and its metadata together so the dashboard
/// can distinguish live NEOS reads from cached, local, or fallback reads
/// without exposing transport, database, or sync details.
class EngineeringSnapshotEnvelope {
  const EngineeringSnapshotEnvelope({
    required this.snapshot,
    required this.metadata,
  });

  final EngineeringSnapshot snapshot;
  final EngineeringSnapshotMetadata metadata;

  bool get isLive => metadata.isLive;

  bool get isFallback => metadata.isFallback;

  Duration get age => metadata.age;

  @override
  bool operator ==(Object other) {
    return other is EngineeringSnapshotEnvelope &&
        other.snapshot == snapshot &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(snapshot, metadata);
}
