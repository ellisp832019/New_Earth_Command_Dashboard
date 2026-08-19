import 'engineering_repository.dart';
import '../domain/engineering_models.dart';

class LocalEngineeringSnapshotReader extends EngineeringSnapshotReader {
  LocalEngineeringSnapshotReader(this._repository);

  final EngineeringSnapshotReader _repository;

  @override
  Future<EngineeringSnapshot> loadSnapshot() {
    return _repository.loadSnapshot();
  }
}
