class FolderBootstrapCreationResult {
  const FolderBootstrapCreationResult({
    required this.createdFolders,
    required this.createdFiles,
  });

  final List<String> createdFolders;
  final List<String> createdFiles;
}
