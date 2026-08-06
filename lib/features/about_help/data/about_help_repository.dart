import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

enum AboutHelpResourceKind { file, folder }

class AboutHelpSection {
  const AboutHelpSection({
    required this.id,
    required this.title,
    required this.description,
    required this.relativePath,
    required this.kind,
    required this.badge,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final String relativePath;
  final AboutHelpResourceKind kind;
  final String badge;
  final IconData icon;

  bool get isFolder => kind == AboutHelpResourceKind.folder;
}

class AboutHelpFolderEntry {
  const AboutHelpFolderEntry({
    required this.title,
    required this.relativePath,
    required this.isDirectory,
    required this.badge,
    required this.detail,
  });

  final String title;
  final String relativePath;
  final bool isDirectory;
  final String badge;
  final String detail;

  bool get isMarkdown =>
      !isDirectory && relativePath.toLowerCase().endsWith('.md');
}

class AboutHelpResourceSnapshot {
  const AboutHelpResourceSnapshot._({
    required this.section,
    required this.resolvedPath,
    required this.exists,
    required this.invalidPath,
    required this.markdown,
    required this.entries,
    required this.errorMessage,
  });

  factory AboutHelpResourceSnapshot.file({
    required AboutHelpSection section,
    required String resolvedPath,
    required bool exists,
    String? markdown,
    String? errorMessage,
  }) {
    return AboutHelpResourceSnapshot._(
      section: section,
      resolvedPath: resolvedPath,
      exists: exists,
      invalidPath: false,
      markdown: markdown,
      entries: const <AboutHelpFolderEntry>[],
      errorMessage: errorMessage,
    );
  }

  factory AboutHelpResourceSnapshot.folder({
    required AboutHelpSection section,
    required String resolvedPath,
    required bool exists,
    required List<AboutHelpFolderEntry> entries,
    String? errorMessage,
  }) {
    return AboutHelpResourceSnapshot._(
      section: section,
      resolvedPath: resolvedPath,
      exists: exists,
      invalidPath: false,
      markdown: null,
      entries: List<AboutHelpFolderEntry>.unmodifiable(entries),
      errorMessage: errorMessage,
    );
  }

  factory AboutHelpResourceSnapshot.invalid({
    required AboutHelpSection section,
    required String requestedPath,
    required String message,
  }) {
    return AboutHelpResourceSnapshot._(
      section: section,
      resolvedPath: requestedPath,
      exists: false,
      invalidPath: true,
      markdown: null,
      entries: const <AboutHelpFolderEntry>[],
      errorMessage: message,
    );
  }

  final AboutHelpSection section;
  final String resolvedPath;
  final bool exists;
  final bool invalidPath;
  final String? markdown;
  final List<AboutHelpFolderEntry> entries;
  final String? errorMessage;

  bool get isFolder => section.isFolder;
  bool get hasMarkdown => markdown?.trim().isNotEmpty == true;
  bool get isEmptyFolder => isFolder && entries.isEmpty;
  bool get hasEntries => entries.isNotEmpty;
}

class AboutHelpRepository {
  AboutHelpRepository({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current;

  final Directory _workingDirectory;

  List<AboutHelpSection> loadSections() =>
      List<AboutHelpSection>.unmodifiable(_sections);

  AboutHelpSection? sectionById(String id) {
    for (final section in _sections) {
      if (section.id == id) {
        return section;
      }
    }
    return null;
  }

  AboutHelpSection? sectionForRelativePath(String relativePath) {
    final normalized = _normalizeRelativePath(relativePath);
    if (normalized.isEmpty) {
      return null;
    }

    for (final section in _sections) {
      final sectionPath = _normalizeRelativePath(section.relativePath);
      if (sectionPath == normalized) {
        return section;
      }

      if (section.isFolder && normalized.startsWith('$sectionPath/')) {
        return section;
      }
    }

    return null;
  }

  String titleForRelativePath(String relativePath) {
    final normalized = _normalizeRelativePath(relativePath);
    final fileName = normalized.split('/').last;
    final stem = fileName.replaceAll(
      RegExp(r'\.(md|markdown)$', caseSensitive: false),
      '',
    );
    return stem
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  Future<AboutHelpResourceSnapshot> loadSectionSnapshot(
    AboutHelpSection section,
  ) async {
    final resolvedPath = _resolvePath(section.relativePath);
    if (resolvedPath == null) {
      return AboutHelpResourceSnapshot.invalid(
        section: section,
        requestedPath: section.relativePath,
        message: 'Invalid path: ${section.relativePath}',
      );
    }

    if (section.isFolder) {
      final directory = Directory(resolvedPath);
      if (!await directory.exists()) {
        return AboutHelpResourceSnapshot.folder(
          section: section,
          resolvedPath: resolvedPath,
          exists: false,
          entries: const <AboutHelpFolderEntry>[],
          errorMessage: 'Folder missing: ${section.relativePath}',
        );
      }

      final entries = await _loadFolderEntries(directory);
      return AboutHelpResourceSnapshot.folder(
        section: section,
        resolvedPath: resolvedPath,
        exists: true,
        entries: entries,
      );
    }

    final file = File(resolvedPath);
    if (!await file.exists()) {
      return AboutHelpResourceSnapshot.file(
        section: section,
        resolvedPath: resolvedPath,
        exists: false,
        errorMessage: 'Document missing: ${section.relativePath}',
      );
    }

    try {
      final markdown = await file.readAsString();
      return AboutHelpResourceSnapshot.file(
        section: section,
        resolvedPath: resolvedPath,
        exists: true,
        markdown: markdown,
      );
    } catch (error) {
      return AboutHelpResourceSnapshot.file(
        section: section,
        resolvedPath: resolvedPath,
        exists: true,
        errorMessage: 'Markdown not loaded: $error',
      );
    }
  }

  Future<List<AboutHelpFolderEntry>> loadFolderEntries(
    String relativePath,
  ) async {
    final resolvedPath = _resolvePath(relativePath);
    if (resolvedPath == null) {
      return const <AboutHelpFolderEntry>[];
    }

    final directory = Directory(resolvedPath);
    if (!await directory.exists()) {
      return const <AboutHelpFolderEntry>[];
    }

    return _loadFolderEntries(directory);
  }

  Directory aboutHelpRootDirectory() {
    return Directory(path.join(repoRootDirectory().path, 'ABOUT_AND_HELP'));
  }

  Directory repoRootDirectory() {
    var current = _workingDirectory;
    while (true) {
      final candidate = Directory(path.join(current.path, 'ABOUT_AND_HELP'));
      if (candidate.existsSync()) {
        return current;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        break;
      }
      current = parent;
    }

    return _workingDirectory;
  }

  List<AboutHelpSection> get _sections => const [
    AboutHelpSection(
      id: 'overview',
      title: 'About the Dashboard',
      description: 'Purpose, principles, and the connected local systems.',
      relativePath: 'ABOUT_AND_HELP/00_OVERVIEW.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Overview',
      icon: Icons.dashboard_outlined,
    ),
    AboutHelpSection(
      id: 'getting-started',
      title: 'Getting Started',
      description: 'First-time orientation and a calm starting path.',
      relativePath: 'ABOUT_AND_HELP/01_GETTING_STARTED.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Guide',
      icon: Icons.rocket_launch_outlined,
    ),
    AboutHelpSection(
      id: 'quick-start-paths',
      title: 'Quick Start Paths',
      description: 'Fast routes for common user goals.',
      relativePath: 'ABOUT_AND_HELP/02_QUICK_START_PATHS.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Guide',
      icon: Icons.bolt_outlined,
    ),
    AboutHelpSection(
      id: 'user-guides',
      title: 'User Guides',
      description: 'Practical guides for the Dashboard and modules.',
      relativePath: 'ABOUT_AND_HELP/03_USER_GUIDES/00_USER_GUIDES_INDEX.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Index',
      icon: Icons.menu_book_outlined,
    ),
    AboutHelpSection(
      id: 'module-directory',
      title: 'Module Directory',
      description: 'Browse module profile markdown files in one place.',
      relativePath: 'ABOUT_AND_HELP/04_MODULE_DIRECTORY/',
      kind: AboutHelpResourceKind.folder,
      badge: 'Directory',
      icon: Icons.view_list_outlined,
    ),
    AboutHelpSection(
      id: 'system-maps',
      title: 'System Maps',
      description: 'Visual and structural maps for the Dashboard ecosystem.',
      relativePath: 'ABOUT_AND_HELP/05_SYSTEM_MAPS/00_SYSTEM_MAPS_INDEX.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Maps',
      icon: Icons.schema_outlined,
    ),
    AboutHelpSection(
      id: 'security',
      title: 'Security & Privacy',
      description: 'Local-first safety rules and access boundaries.',
      relativePath:
          'ABOUT_AND_HELP/06_SECURITY_AND_PRIVACY/00_SECURITY_INDEX.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Policy',
      icon: Icons.shield_outlined,
    ),
    AboutHelpSection(
      id: 'troubleshooting',
      title: 'Troubleshooting',
      description: 'Calm recovery steps for common issues.',
      relativePath:
          'ABOUT_AND_HELP/07_TROUBLESHOOTING/00_TROUBLESHOOTING_INDEX.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Help',
      icon: Icons.build_circle_outlined,
    ),
    AboutHelpSection(
      id: 'setup',
      title: 'Setup & Installation',
      description:
          'Windows, Linux, VS Code, Git, Obsidian, and Omega OS setup.',
      relativePath:
          'ABOUT_AND_HELP/08_SETUP_AND_INSTALLATION/00_SETUP_INDEX.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Setup',
      icon: Icons.construction_outlined,
    ),
    AboutHelpSection(
      id: 'changelog',
      title: 'Changelog',
      description: 'A small record of updates to the help centre.',
      relativePath: 'ABOUT_AND_HELP/09_CHANGELOG/CHANGELOG.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Log',
      icon: Icons.update_outlined,
    ),
    AboutHelpSection(
      id: 'roadmap',
      title: 'Roadmap',
      description:
          'What is coming next for the help centre and dashboard docs.',
      relativePath: 'ABOUT_AND_HELP/10_ROADMAP/ROADMAP.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Plan',
      icon: Icons.map_outlined,
    ),
    AboutHelpSection(
      id: 'glossary',
      title: 'Glossary',
      description: 'Short definitions for the terms used across the Dashboard.',
      relativePath: 'ABOUT_AND_HELP/11_GLOSSARY/GLOSSARY.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Glossary',
      icon: Icons.text_fields_outlined,
    ),
    AboutHelpSection(
      id: 'support',
      title: 'Support & Feedback',
      description: 'Bug reports, module ideas, and support entry points.',
      relativePath:
          'ABOUT_AND_HELP/12_SUPPORT_AND_FEEDBACK/00_SUPPORT_INDEX.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Support',
      icon: Icons.support_agent_outlined,
    ),
    AboutHelpSection(
      id: 'templates',
      title: 'Templates',
      description: 'Reusable starter documents and calm writing scaffolds.',
      relativePath: 'ABOUT_AND_HELP/13_TEMPLATES/',
      kind: AboutHelpResourceKind.folder,
      badge: 'Folder',
      icon: Icons.folder_copy_outlined,
    ),
    AboutHelpSection(
      id: 'where-does-this-belong',
      title: 'Where Does This Belong?',
      description:
          'A decision helper for repo, Omega OS, Obsidian, or archive.',
      relativePath: 'ABOUT_AND_HELP/99_INDEX/WHERE_DOES_THIS_BELONG.md',
      kind: AboutHelpResourceKind.file,
      badge: 'Helper',
      icon: Icons.question_mark_outlined,
    ),
  ];

  Future<List<AboutHelpFolderEntry>> _loadFolderEntries(
    Directory directory,
  ) async {
    final entries = <AboutHelpFolderEntry>[];
    await for (final entity in directory.list(followLinks: false)) {
      final name = path.basename(entity.path);
      if (name.startsWith('.')) {
        continue;
      }

      if (entity is Directory) {
        entries.add(
          AboutHelpFolderEntry(
            title: _displayTitleForName(name),
            relativePath: _relativePathFor(entity.path),
            isDirectory: true,
            badge: 'Folder',
            detail: 'Folder',
          ),
        );
        continue;
      }

      if (entity is File && name.toLowerCase().endsWith('.md')) {
        final content = await _safeReadMarkdown(entity);
        entries.add(
          AboutHelpFolderEntry(
            title: _titleFromMarkdown(content) ?? _displayTitleForName(name),
            relativePath: _relativePathFor(entity.path),
            isDirectory: false,
            badge: name == '00_MODULE_DIRECTORY_INDEX.md'
                ? 'Index'
                : 'Markdown',
            detail: _previewSummary(content),
          ),
        );
      }
    }

    entries.sort((a, b) {
      final aKey = a.isDirectory ? '0_${a.title}' : '1_${a.title}';
      final bKey = b.isDirectory ? '0_${b.title}' : '1_${b.title}';
      return aKey.toLowerCase().compareTo(bKey.toLowerCase());
    });
    return entries;
  }

  Future<String> _safeReadMarkdown(File file) async {
    try {
      return await file.readAsString();
    } catch (_) {
      return '';
    }
  }

  String? _titleFromMarkdown(String markdown) {
    for (final line in markdown.replaceAll('\r\n', '\n').split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#')) {
        return trimmed.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      }
    }
    return null;
  }

  String _previewSummary(String markdown) {
    final lines = markdown.replaceAll('\r\n', '\n').split('\n');
    final previewLines = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      previewLines.add(trimmed);
      if (previewLines.length == 2) {
        break;
      }
    }

    if (previewLines.isEmpty) {
      return 'Markdown document';
    }

    return previewLines.join(' ');
  }

  String _displayTitleForName(String name) {
    final stem = name.replaceAll(
      RegExp(r'\.(md|markdown)$', caseSensitive: false),
      '',
    );
    final clean = stem.replaceAll(RegExp(r'^\d+_?'), '');
    return clean
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  String _relativePathFor(String absolutePath) {
    final root = aboutHelpRootDirectory().path;
    final normalized = path.normalize(absolutePath);
    return path.relative(normalized, from: root);
  }

  String? _resolvePath(String relativePath) {
    if (relativePath.trim().isEmpty) {
      return null;
    }

    final root = repoRootDirectory().path;
    final resolved = path.normalize(path.join(root, relativePath));
    if (!path.isWithin(root, resolved) && resolved != root) {
      return null;
    }
    return resolved;
  }

  String _normalizeRelativePath(String relativePath) {
    return relativePath
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll(RegExp(r'/+$'), '');
  }
}
