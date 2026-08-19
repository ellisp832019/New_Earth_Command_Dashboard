import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_snapshot_envelope.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/neos_engineering_snapshot_reader.dart';

class FakeNeosEngineeringSnapshotReader
    implements NeosEngineeringSnapshotReader {
  FakeNeosEngineeringSnapshotReader({required this.envelope, this.error});

  final EngineeringSnapshotEnvelope envelope;
  final Object? error;

  String? lastProjectScope;
  int loadEngineeringSnapshotCalls = 0;

  @override
  Future<EngineeringSnapshotEnvelope> loadEngineeringSnapshot({
    String? projectScope,
  }) async {
    loadEngineeringSnapshotCalls++;
    lastProjectScope = projectScope;
    if (error != null) {
      throw error!;
    }
    return envelope;
  }
}
