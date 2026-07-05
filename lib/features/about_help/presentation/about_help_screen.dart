import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../data/about_help_repository.dart';

class AboutHelpScreen extends StatefulWidget {
  const AboutHelpScreen({
    super.key,
    this.repository,
    this.initialSectionId,
    this.initialDocumentPath,
  });

  final AboutHelpRepository? repository;
  final String? initialSectionId;
  final String? initialDocumentPath;

  @override
  State<AboutHelpScreen> createState() => _AboutHelpScreenState();
}

class _AboutHelpScreenState extends State<AboutHelpScreen> {
  late final AboutHelpRepository _repository =
      widget.repository ?? AboutHelpRepository();
  late final List<AboutHelpSection> _sections = _repository.loadSections();
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  late AboutHelpSection _selectedSection = _resolveInitialSection();
  Future<AboutHelpResourceSnapshot>? _selectedSnapshotFuture;

  @override
  void initState() {
    super.initState();
    _selectedSnapshotFuture = _repository.loadSectionSnapshot(_selectedSection);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AboutHelpSection> get _filteredSections {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return _sections;
    }

    return _sections
        .where((section) {
          return section.title.toLowerCase().contains(query) ||
              section.description.toLowerCase().contains(query) ||
              section.relativePath.toLowerCase().contains(query) ||
              section.badge.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void _selectSection(AboutHelpSection section) {
    setState(() {
      _selectedSection = section;
      _selectedSnapshotFuture = _repository.loadSectionSnapshot(section);
    });
  }

  AboutHelpSection _resolveInitialSection() {
    final initialDocumentPath = widget.initialDocumentPath?.trim();
    if (initialDocumentPath != null && initialDocumentPath.isNotEmpty) {
      final normalized = _normalizeHelpPath(initialDocumentPath);
      final fileSection = _sections.firstWhere(
        (section) =>
            _normalizeHelpPath(section.relativePath) == normalized &&
            !section.isFolder,
        orElse: () => _createSyntheticFileSection(normalized),
      );
      return fileSection;
    }

    final initialSectionId = widget.initialSectionId?.trim();
    if (initialSectionId != null && initialSectionId.isNotEmpty) {
      return _sections.firstWhere(
        (section) => section.id == initialSectionId,
        orElse: () => _sections.first,
      );
    }

    return _sections.first;
  }

  AboutHelpSection _createSyntheticFileSection(String relativePath) {
    final normalized = _normalizeHelpPath(relativePath);
    final title = _repository.titleForRelativePath(normalized);
    return AboutHelpSection(
      id: normalized,
      title: title.isEmpty ? normalized.split('/').last : title,
      description: 'Direct document link for $normalized.',
      relativePath: normalized,
      kind: AboutHelpResourceKind.file,
      badge: 'Markdown',
      icon: Icons.description_outlined,
    );
  }

  void _openFolderEntry(AboutHelpFolderEntry entry) {
    if (entry.isDirectory) {
      final folderSection =
          _repository.sectionById(
            _folderSectionIdForPath(entry.relativePath),
          ) ??
          AboutHelpSection(
            id: entry.relativePath,
            title: entry.title,
            description: entry.detail,
            relativePath: entry.relativePath,
            kind: AboutHelpResourceKind.folder,
            badge: entry.badge,
            icon: Icons.folder_outlined,
          );
      _selectSection(folderSection);
      return;
    }

    _selectSection(_createSyntheticFileSection(entry.relativePath));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSections;
    final hasQuery = _query.trim().isNotEmpty;

    return WorkspaceShell(
      title: 'About & Help',
      subtitle: 'Guide centre and local reference library.',
      onBack: () => _goBack(context),
      trailingActions: [
        IconButton(
          tooltip: 'Reload current document',
          onPressed: () => _selectSection(_selectedSection),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeroCard(
            sectionCount: _sections.length,
            folderCount: _sections.where((section) => section.isFolder).length,
            onJumpToHelp: () => _selectSection(
              _sections.firstWhere(
                (section) => section.id == 'where-does-this-belong',
                orElse: () => _sections.last,
              ),
            ),
            onOpenModuleDirectory: () =>
                context.go(RouteNames.aboutHelpSection('module-directory')),
          ),
          const SizedBox(height: 16),
          _SearchCard(
            controller: _searchController,
            query: _query,
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            onClear: hasQuery
                ? () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                    });
                  }
                : null,
          ),
          const SizedBox(height: 16),
          _SectionSummaryRow(
            title: 'Help centre areas',
            summary:
                '${filtered.length} of ${_sections.length} sections match the current search.',
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const _EmptyState(
              title: 'No matching help sections',
              body: 'Try a shorter search term or clear the filter.',
              icon: Icons.search_off_outlined,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 980 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: crossAxisCount == 1 ? 2.8 : 2.5,
                  ),
                  itemBuilder: (context, index) {
                    final section = filtered[index];
                    final selected = section.id == _selectedSection.id;
                    return _SectionCard(
                      section: section,
                      selected: selected,
                      onTap: () => _selectSection(section),
                      onOpenDeepLink: () => context.go(
                        RouteNames.aboutHelpSection(
                          section.id,
                          documentPath: section.isFolder
                              ? null
                              : section.relativePath,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 18),
          _SectionSummaryRow(
            title: _selectedSection.title,
            summary: _selectedSection.relativePath,
          ),
          const SizedBox(height: 12),
          FutureBuilder<AboutHelpResourceSnapshot>(
            future: _selectedSnapshotFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingPanel();
              }

              if (snapshot.hasError) {
                return _EmptyState(
                  title: 'Markdown not loaded',
                  body: snapshot.error.toString(),
                  icon: Icons.description_outlined,
                );
              }

              final resource = snapshot.data;
              if (resource == null) {
                return const _EmptyState(
                  title: 'Markdown not loaded',
                  body: 'The selected help item could not be opened.',
                  icon: Icons.description_outlined,
                );
              }

              return _ResourcePanel(
                resource: resource,
                onOpenFolderEntry: _openFolderEntry,
                onOpenDeepLink: (relativePath) {
                  final sectionId = _sectionIdForDocumentPath(relativePath);
                  if (sectionId == null) {
                    return;
                  }

                  context.go(
                    RouteNames.aboutHelpSection(
                      sectionId,
                      documentPath: relativePath,
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          const _HelperFooter(),
        ],
      ),
    );
  }

  String? _sectionIdForDocumentPath(String relativePath) {
    final section = _repository.sectionForRelativePath(relativePath);
    return section?.id;
  }

  String _folderSectionIdForPath(String relativePath) {
    final section = _repository.sectionForRelativePath(relativePath);
    return section?.id ?? relativePath;
  }

  String _normalizeHelpPath(String value) {
    return value.replaceAll('\\', '/').replaceAll(RegExp(r'^/+'), '');
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.more);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.sectionCount,
    required this.folderCount,
    required this.onJumpToHelp,
    required this.onOpenModuleDirectory,
  });

  final int sectionCount;
  final int folderCount;
  final VoidCallback onJumpToHelp;
  final VoidCallback onOpenModuleDirectory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                label: '$sectionCount sections',
                accent: AppColours.darkSecondary,
              ),
              _StatusChip(
                label: '$folderCount folders',
                accent: AppColours.darkGlow,
              ),
              const _StatusChip(
                label: 'Local-first',
                accent: AppColours.darkSuccess,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'About & Help Centre',
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppColours.darkText,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A central guide, support, and orientation hub for the New Earth Dashboard.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onJumpToHelp,
                icon: const Icon(Icons.help_outline),
                label: const Text('Open helper card'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenModuleDirectory,
                icon: const Icon(Icons.link),
                label: const Text('Open module directory link'),
              ),
              const _StatusChip(
                label: 'Markdown previews included',
                accent: AppColours.darkMutedText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                labelText: 'Search guides, folders, and titles',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (query.trim().isNotEmpty) ...[
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionSummaryRow extends StatelessWidget {
  const _SectionSummaryRow({required this.title, required this.summary});

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.library_books_outlined, color: AppColours.darkSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            summary,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.selected,
    required this.onTap,
    required this.onOpenDeepLink,
  });

  final AboutHelpSection section;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpenDeepLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: _panelDecoration(highlighted: selected),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceRaised.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(section.icon, color: AppColours.darkSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            section.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColours.darkText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (selected)
                          const _StatusChip(
                            label: 'Selected',
                            accent: AppColours.darkSuccess,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(
                          label: section.badge,
                          accent: _badgeColour(section.badge),
                        ),
                        _StatusChip(
                          label: section.isFolder
                              ? 'Folder link'
                              : 'Markdown link',
                          accent: AppColours.darkMutedText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      section.relativePath,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onOpenDeepLink,
                        icon: const Icon(Icons.link, size: 18),
                        label: const Text('Open deep link'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourcePanel extends StatelessWidget {
  const _ResourcePanel({
    required this.resource,
    required this.onOpenFolderEntry,
    required this.onOpenDeepLink,
  });

  final AboutHelpResourceSnapshot resource;
  final ValueChanged<AboutHelpFolderEntry> onOpenFolderEntry;
  final ValueChanged<String> onOpenDeepLink;

  @override
  Widget build(BuildContext context) {
    if (resource.invalidPath) {
      return _EmptyState(
        title: 'Invalid path',
        body:
            resource.errorMessage ?? 'The selected path could not be resolved.',
        icon: Icons.report_outlined,
      );
    }

    if (resource.isFolder) {
      return _FolderPanel(
        resource: resource,
        onOpenFolderEntry: onOpenFolderEntry,
        onOpenDeepLink: onOpenDeepLink,
      );
    }

    return _FilePanel(resource: resource);
  }
}

class _FilePanel extends StatelessWidget {
  const _FilePanel({required this.resource});

  final AboutHelpResourceSnapshot resource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!resource.exists) {
      return _EmptyState(
        title: 'Document missing',
        body: resource.errorMessage ?? 'This markdown file could not be found.',
        icon: Icons.description_outlined,
      );
    }

    if (!resource.hasMarkdown) {
      return _EmptyState(
        title: 'Markdown not loaded',
        body:
            resource.errorMessage ??
            'This markdown file is empty or unreadable.',
        icon: Icons.description_outlined,
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                label: resource.section.badge,
                accent: _badgeColour(resource.section.badge),
              ),
              _StatusChip(
                label: '${resource.markdown!.length} chars',
                accent: AppColours.darkSecondary,
              ),
              _StatusChip(
                label: resource.exists ? 'Ready' : 'Missing',
                accent: resource.exists
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            resource.section.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            resource.resolvedPath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math
                  .max(MediaQuery.sizeOf(context).height * 0.55, 320)
                  .toDouble(),
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: _MarkdownView(markdown: resource.markdown!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderPanel extends StatelessWidget {
  const _FolderPanel({
    required this.resource,
    required this.onOpenFolderEntry,
    required this.onOpenDeepLink,
  });

  final AboutHelpResourceSnapshot resource;
  final ValueChanged<AboutHelpFolderEntry> onOpenFolderEntry;
  final ValueChanged<String> onOpenDeepLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!resource.exists) {
      return _EmptyState(
        title: 'Folder missing',
        body: resource.errorMessage ?? 'This folder could not be found.',
        icon: Icons.folder_off_outlined,
      );
    }

    if (resource.isEmptyFolder) {
      return _EmptyState(
        title: 'Folder empty',
        body: 'No markdown files were found in this folder yet.',
        icon: Icons.folder_open_outlined,
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                label: resource.section.badge,
                accent: _badgeColour(resource.section.badge),
              ),
              _StatusChip(
                label: '${resource.entries.length} items',
                accent: AppColours.darkSecondary,
              ),
              const _StatusChip(
                label: 'Folder view',
                accent: AppColours.darkGlow,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            resource.section.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            resource.resolvedPath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth >= 980;
              final cardWidth = useTwoColumns
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final entry in resource.entries)
                    SizedBox(
                      width: cardWidth,
                      child: _FolderEntryCard(
                        entry: entry,
                        onTap: () => onOpenFolderEntry(entry),
                        onOpenDeepLink: () =>
                            onOpenDeepLink(entry.relativePath),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FolderEntryCard extends StatelessWidget {
  const _FolderEntryCard({
    required this.entry,
    required this.onTap,
    required this.onOpenDeepLink,
  });

  final AboutHelpFolderEntry entry;
  final VoidCallback onTap;
  final VoidCallback onOpenDeepLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColours.darkSurfaceRaised.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColours.darkOutline.withValues(alpha: 0.9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    entry.isDirectory
                        ? Icons.folder_outlined
                        : Icons.description_outlined,
                    color: AppColours.darkSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusChip(
                    label: entry.badge,
                    accent: _badgeColour(entry.badge),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.detail.isEmpty ? 'Markdown file' : entry.detail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                entry.relativePath,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onOpenDeepLink,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Open deep link'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkdownView extends StatelessWidget {
  const _MarkdownView({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final lines = markdown.replaceAll("\r\n", "\n").split('\n');
    final widgets = <Widget>[];
    var inCodeBlock = false;
    var numberedListIndex = 0;

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      final trimmed = line.trim();

      if (trimmed.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        numberedListIndex = 0;
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.isEmpty) {
        numberedListIndex = 0;
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      if (inCodeBlock) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColours.darkSurfaceRaised.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColours.darkOutline.withValues(alpha: 0.8),
              ),
            ),
            child: SelectableText(
              line,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkText,
                fontFamily: 'monospace',
                height: 1.35,
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: SelectableText(
              trimmed.substring(4),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: SelectableText(
              trimmed.substring(3),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: SelectableText(
              trimmed.substring(2),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      final unordered = trimmed.startsWith('- ') || trimmed.startsWith('* ');
      final ordered = RegExp(r'^\d+\.\s').hasMatch(trimmed);
      if (unordered || ordered) {
        numberedListIndex += 1;
        final body = ordered
            ? trimmed.replaceFirst(RegExp(r'^\d+\.\s'), '')
            : trimmed.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    ordered ? '$numberedListIndex.' : '-',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MarkdownInlineText(
                    text: body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkText,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('>')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: AppColours.darkSurfaceRaised.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: AppColours.darkSecondary.withValues(alpha: 0.7),
                  width: 3,
                ),
              ),
            ),
            child: _MarkdownInlineText(
              text: trimmed.substring(1).trimLeft(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _MarkdownInlineText(
            text: line,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _MarkdownInlineText extends StatelessWidget {
  const _MarkdownInlineText({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(style: style, children: _buildMarkdownInlineSpans(text, style)),
    );
  }
}

List<InlineSpan> _buildMarkdownInlineSpans(String text, TextStyle? baseStyle) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(
    r'(\[([^\]]+)\]\(([^)]+)\))|(`[^`]+`)|(\*\*[^*]+\*\*)|(\*[^*]+\*)',
  );
  var index = 0;

  for (final match in pattern.allMatches(text)) {
    if (match.start > index) {
      spans.add(TextSpan(text: text.substring(index, match.start)));
    }

    final token = match.group(0) ?? '';
    if (match.group(2) != null && match.group(3) != null) {
      spans.add(
        TextSpan(
          text: match.group(2),
          style: baseStyle?.copyWith(
            color: AppColours.darkSecondary,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (token.startsWith('`') && token.endsWith('`')) {
      spans.add(
        TextSpan(
          text: token.substring(1, token.length - 1),
          style: baseStyle?.copyWith(
            fontFamily: 'monospace',
            color: AppColours.darkSecondary,
          ),
        ),
      );
    } else if (token.startsWith('**') && token.endsWith('**')) {
      spans.add(
        TextSpan(
          text: token.substring(2, token.length - 2),
          style: baseStyle?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
    } else if (token.startsWith('*') && token.endsWith('*')) {
      spans.add(
        TextSpan(
          text: token.substring(1, token.length - 1),
          style: baseStyle?.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }

    index = match.end;
  }

  if (index < text.length) {
    spans.add(TextSpan(text: text.substring(index)));
  }

  return spans;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColours.darkMutedText),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _HelperFooter extends StatelessWidget {
  const _HelperFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Text(
        'If a card feels out of place, use the "Where Does This Belong?" helper first. The goal is calm routing, clear ownership, and easy local browsing.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColours.darkMutedText,
          height: 1.45,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration({bool highlighted = false}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurface.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? AppColours.darkSecondary.withValues(alpha: 0.22)
          : AppColours.darkOutline.withValues(alpha: 0.9),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 26,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

Color _badgeColour(String badge) {
  switch (badge.toLowerCase()) {
    case 'overview':
    case 'guide':
      return AppColours.darkSecondary;
    case 'directory':
    case 'folder':
      return AppColours.darkGlow;
    case 'policy':
    case 'support':
      return AppColours.darkSuccess;
    case 'helper':
      return AppColours.darkAmber;
    case 'log':
    case 'plan':
      return AppColours.darkPrimary;
    default:
      return AppColours.darkMutedText;
  }
}
