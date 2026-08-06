import 'project_repo_bridge_models.dart';

class RepoSnapshotAdapter {
  const RepoSnapshotAdapter();

  // Adapter-specific: normalize repo-bridge snapshot JSON into the Dart model
  // without mutating the source files or the repository itself.
  RepoSnapshot fromJson(Map<String, dynamic> json) {
    return RepoSnapshot.fromJson(json);
  }

  Map<String, dynamic> toJson(RepoSnapshot snapshot) {
    return snapshot.toJson();
  }
}
