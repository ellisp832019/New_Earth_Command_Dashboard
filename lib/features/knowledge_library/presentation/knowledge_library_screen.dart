import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../data/knowledge_library_repository.dart';

enum KnowledgeLibraryFilter {
  all,
  extractable,
  ocrNeeded,
  textIndexed,
  audioReady,
}

extension KnowledgeLibraryFilterLabel on KnowledgeLibraryFilter {
  String get label {
    switch (this) {
      case KnowledgeLibraryFilter.all:
        return 'All';
      case KnowledgeLibraryFilter.extractable:
        return 'Extractable';
      case KnowledgeLibraryFilter.ocrNeeded:
        return 'OCR Needed';
      case KnowledgeLibraryFilter.textIndexed:
        return 'Text Indexed';
      case KnowledgeLibraryFilter.audioReady:
        return 'Audio Ready';
    }
  }

  bool matches(KnowledgeLibraryItem item) {
    switch (this) {
      case KnowledgeLibraryFilter.all:
        return true;
      case KnowledgeLibraryFilter.extractable:
        return item.textExtractable && !item.ocrRequired;
      case KnowledgeLibraryFilter.ocrNeeded:
        return item.ocrRequired;
      case KnowledgeLibraryFilter.textIndexed:
        return item.hasExtractedText;
      case KnowledgeLibraryFilter.audioReady:
        return item.audioStatus == 'generated';
    }
  }
}

class KnowledgeLibraryScreen extends StatefulWidget {
  const KnowledgeLibraryScreen({super.key});

  @override
  State<KnowledgeLibraryScreen> createState() => _KnowledgeLibraryScreenState();
}

class _KnowledgeLibraryScreenState extends State<KnowledgeLibraryScreen> {
  static const int _pageSize = 100;

  final KnowledgeLibraryRepository _repository = KnowledgeLibraryRepository();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  int _requestSerial = 0;
  KnowledgeLibraryPage? _page;
  KnowledgeLibrarySearchResult? _searchResult;
  KnowledgeLibraryStats? _stats;
  KnowledgeLibraryItem? _selectedItem;
  KnowledgeLibraryFilter _filter = KnowledgeLibraryFilter.all;
  String? _sourceSectionFilter;
  String _query = '';
  String _status = 'Loading the Omega OS library catalogue...';
  bool _isLoadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _repository.dispose();
    super.dispose();
  }

  List<KnowledgeLibraryItem> get _items =>
      _currentItems.where(_filter.matches).toList(growable: false);

  List<KnowledgeLibraryItem> get _visibleItems =>
      _items.where(_matchesSourceSection).toList(growable: false);

  List<KnowledgeLibraryItem> get _currentItems =>
      _searchResult?.items ?? _page?.items ?? const [];

  int get _displayedTotal => _searchResult?.totalMatches ?? _page?.total ?? 0;

  bool get _isSearchMode => _query.trim().isNotEmpty;

  bool get _canLoadMore =>
      !_isSearchMode && (_page?.hasMore ?? false) && !_isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final selectedItem = _selectedItem;
    final visibleItems = _visibleItems;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1200;
    final hasActiveFilters =
        _query.trim().isNotEmpty ||
        _filter != KnowledgeLibraryFilter.all ||
        _sourceSectionFilter != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                onBackToDashboard: () => context.go(RouteNames.dashboard),
                onBackToMore: () => context.go(RouteNames.more),
              ),
              const SizedBox(height: 14),
              _HeaderCard(
                status: _status,
                onRefresh: _refreshAll,
                onLoadMore: _canLoadMore ? _loadMore : null,
              ),
              const SizedBox(height: 14),
              _SearchBar(
                controller: _searchController,
                onChanged: _scheduleSearch,
                onSubmitted: _runSearchImmediately,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 14),
              _FilterStrip(
                selected: _filter,
                onSelected: (value) {
                  setState(() {
                    _filter = value;
                    _ensureSelectionStillVisible();
                  });
                },
              ),
              const SizedBox(height: 14),
              if (stats != null)
                _SourceSectionStrip(
                  sections: stats.bySourceSection,
                  selected: _sourceSectionFilter,
                  onSelected: (value) {
                    setState(() {
                      _sourceSectionFilter = value;
                      _ensureSelectionStillVisible();
                    });
                  },
                  onClear: _sourceSectionFilter == null
                      ? null
                      : () {
                          setState(() {
                            _sourceSectionFilter = null;
                            _ensureSelectionStillVisible();
                          });
                        },
                ),
              if (stats != null) const SizedBox(height: 14),
              if (hasActiveFilters)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _clearAllFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Clear all filters'),
                  ),
                ),
              if (hasActiveFilters) const SizedBox(height: 10),
              if (stats != null) _StatsGrid(stats: stats),
              if (stats != null) const SizedBox(height: 16),
              Expanded(
                child: _error != null
                    ? _ErrorPanel(error: _error!, onRetry: _refreshAll)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final useWideLayout =
                              isWide &&
                              constraints.maxWidth >= 1100 &&
                              visibleItems.isNotEmpty;

                          final libraryPanel = _LibraryPanel(
                            title: _isSearchMode
                                ? 'Search results'
                                : 'Catalogue',
                            subtitle: _isSearchMode
                                ? 'Showing ${visibleItems.length} of $_displayedTotal matches for "$_query".'
                                : 'Showing ${visibleItems.length} loaded PDFs from the current catalogue slice.',
                            items: visibleItems,
                            selectedItemId: selectedItem?.id,
                            onSelect: _selectItem,
                            onOpenOriginal: _openOriginal,
                            onCopyPath: _copyOriginalPath,
                          );

                          final detailPanel = _DetailPanel(
                            item: selectedItem,
                            onOpenOriginal: _openOriginal,
                            onOpenContainingFolder: _openContainingFolder,
                            onOpenExtractedTextFolder: _openExtractedTextFolder,
                            onCopyPath: _copyOriginalPath,
                            onCopyExtractedPath: _copyExtractedPath,
                            onCopyManifestPath: _copyManifestPath,
                            onOpenManifest: _openManifest,
                            onOpenExtractedText: _openExtractedText,
                            onRefresh: _refreshAll,
                          );

                          if (useWideLayout) {
                            return Row(
                              children: [
                                Expanded(flex: 3, child: libraryPanel),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: detailPanel),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              Expanded(flex: 3, child: libraryPanel),
                              const SizedBox(height: 16),
                              Expanded(flex: 2, child: detailPanel),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshAll() async {
    _searchDebounce?.cancel();
    final query = _query.trim();
    final serial = ++_requestSerial;

    setState(() {
      _error = null;
      _status = query.isEmpty
          ? 'Refreshing the catalogue from the local API...'
          : 'Refreshing search results for "$query"...';
    });

    try {
      final stats = await _repository.loadStats();
      if (!mounted || serial != _requestSerial) {
        return;
      }

      if (query.isEmpty) {
        final page = await _repository.loadPage(limit: _pageSize, offset: 0);
        if (!mounted || serial != _requestSerial) {
          return;
        }

        setState(() {
          _stats = stats;
          _page = page;
          _searchResult = null;
          _status =
              'Loaded ${page.items.length} PDFs from the local catalogue.';
          _selectDefaultItem(page.items);
        });
        return;
      }

      final searchResult = await _repository.search(query: query);
      if (!mounted || serial != _requestSerial) {
        return;
      }

      setState(() {
        _stats = stats;
        _searchResult = searchResult;
        _page = null;
        _status =
            'Found ${searchResult.totalMatches} result${searchResult.totalMatches == 1 ? '' : 's'} for "$query".';
        _selectDefaultItem(searchResult.items);
      });
    } catch (error) {
      if (!mounted || serial != _requestSerial) {
        return;
      }

      setState(() {
        _error = error;
        _status = 'Knowledge Library could not connect to the local API.';
      });
    }
  }

  Future<void> _loadMore() async {
    final page = _page;
    if (page == null || !page.hasMore || _isLoadingMore || _isSearchMode) {
      return;
    }

    final serial = ++_requestSerial;
    setState(() {
      _isLoadingMore = true;
      _status = 'Loading more catalogue entries...';
    });

    try {
      final nextPage = await _repository.loadPage(
        limit: _pageSize,
        offset: page.offset + page.items.length,
      );
      if (!mounted || serial != _requestSerial) {
        return;
      }

      final combinedItems = <KnowledgeLibraryItem>[
        ...page.items,
        ...nextPage.items,
      ];

      setState(() {
        _page = KnowledgeLibraryPage(
          total: nextPage.total,
          limit: nextPage.limit,
          offset: 0,
          items: combinedItems,
        );
        _isLoadingMore = false;
        _status = 'Loaded ${combinedItems.length} of ${nextPage.total} PDFs.';
        _ensureSelectionStillVisible();
      });
    } catch (error) {
      if (!mounted || serial != _requestSerial) {
        return;
      }

      setState(() {
        _isLoadingMore = false;
        _status = 'Could not load more items right now.';
        _error = error;
      });
    }
  }

  void _scheduleSearch(String value) {
    _query = value;
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }

      unawaited(_runSearch());
    });
  }

  Future<void> _runSearchImmediately(String value) async {
    _query = value;
    _searchDebounce?.cancel();
    await _runSearch();
  }

  Future<void> _runSearch() async {
    final query = _query.trim();
    final serial = ++_requestSerial;

    if (query.isEmpty) {
      await _refreshAll();
      return;
    }

    setState(() {
      _error = null;
      _status = 'Searching the local catalogue for "$query"...';
    });

    try {
      final stats = await _repository.loadStats();
      final searchResult = await _repository.search(query: query);
      if (!mounted || serial != _requestSerial) {
        return;
      }

      setState(() {
        _stats = stats;
        _searchResult = searchResult;
        _page = null;
        _status =
            'Found ${searchResult.totalMatches} result${searchResult.totalMatches == 1 ? '' : 's'} for "$query".';
        _selectDefaultItem(searchResult.items);
      });
    } catch (error) {
      if (!mounted || serial != _requestSerial) {
        return;
      }

      setState(() {
        _error = error;
        _status = 'Search could not reach the local API.';
      });
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _query = '';
    unawaited(_refreshAll());
  }

  void _clearAllFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = KnowledgeLibraryFilter.all;
      _sourceSectionFilter = null;
    });
    unawaited(_refreshAll());
  }

  void _selectItem(KnowledgeLibraryItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  void _selectDefaultItem(List<KnowledgeLibraryItem> items) {
    if (items.isEmpty) {
      _selectedItem = null;
      return;
    }

    final current = _selectedItem;
    if (current != null) {
      final match = _findItemById(items, current.id);
      if (match != null) {
        _selectedItem = match;
        return;
      }
    }

    _selectedItem = items.first;
  }

  void _ensureSelectionStillVisible() {
    final selected = _selectedItem;
    if (selected == null) {
      _selectedItem = _visibleItems.isEmpty ? null : _visibleItems.first;
      return;
    }

    final match = _findItemById(_visibleItems, selected.id);
    _selectedItem =
        match ?? (_visibleItems.isEmpty ? null : _visibleItems.first);
  }

  bool _matchesSourceSection(KnowledgeLibraryItem item) {
    final filter = _sourceSectionFilter;
    if (filter == null || filter.trim().isEmpty) {
      return true;
    }

    return item.sourceSection == filter;
  }

  KnowledgeLibraryItem? _findItemById(
    List<KnowledgeLibraryItem> items,
    String id,
  ) {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Future<void> _openOriginal(KnowledgeLibraryItem item) async {
    try {
      await _repository.openInDefaultApp(item.fullPath);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Opened ${item.filename}.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the original PDF: $error')),
      );
    }
  }

  Future<void> _openExtractedText(KnowledgeLibraryItem item) async {
    final extracted = item.extractedTextPath;
    if (extracted == null || extracted.trim().isEmpty) {
      return;
    }

    try {
      await _repository.openInDefaultApp(extracted);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opened the extracted text for ${item.filename}.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the extracted text: $error')),
      );
    }
  }

  Future<void> _copyOriginalPath(KnowledgeLibraryItem item) async {
    await Clipboard.setData(ClipboardData(text: item.fullPath));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied path for ${item.filename}.')),
    );
  }

  Future<void> _copyExtractedPath(KnowledgeLibraryItem item) async {
    final extracted = item.extractedTextPath;
    if (extracted == null || extracted.trim().isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: extracted));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied extracted text path for ${item.filename}.'),
      ),
    );
  }

  Future<void> _copyManifestPath(KnowledgeLibraryItem item) async {
    final manifest = item.audioManifestPath;
    if (manifest == null || manifest.trim().isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: manifest));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied manifest path for ${item.filename}.')),
    );
  }

  Future<void> _openManifest(KnowledgeLibraryItem item) async {
    final manifest = item.audioManifestPath;
    if (manifest == null || manifest.trim().isEmpty) {
      return;
    }

    try {
      await _repository.openInDefaultApp(manifest);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opened the manifest for ${item.filename}.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the manifest: $error')),
      );
    }
  }

  Future<void> _openContainingFolder(KnowledgeLibraryItem item) async {
    try {
      await _repository.openContainingFolder(item.fullPath);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opened the folder for ${item.filename}.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the folder: $error')),
      );
    }
  }

  Future<void> _openExtractedTextFolder(KnowledgeLibraryItem item) async {
    final extracted = item.extractedTextPath;
    if (extracted == null || extracted.trim().isEmpty) {
      return;
    }

    try {
      await _repository.openExtractedTextFolder(extracted);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Opened the extracted text folder for ${item.filename}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the extracted text folder: $error'),
        ),
      );
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBackToDashboard, required this.onBackToMore});

  final VoidCallback onBackToDashboard;
  final VoidCallback onBackToMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onBackToDashboard,
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to Dashboard'),
        ),
        const SizedBox(width: 10),
        TextButton.icon(
          onPressed: onBackToMore,
          icon: const Icon(Icons.menu_open_rounded),
          label: const Text('Back to More'),
        ),
        const Spacer(),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.status,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final String status;
  final VoidCallback onRefresh;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 960;

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Knowledge Library',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Text(
                  'Scan, search, and review the Omega OS PDF archive from the Dashboard without moving the source files.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _HeaderPill(
                    label: 'Local API',
                    icon: Icons.cloud_off_outlined,
                  ),
                  _HeaderPill(
                    label: 'Source of truth: Omega OS',
                    icon: Icons.folder_open_outlined,
                  ),
                  _HeaderPill(label: 'No file moves', icon: Icons.lock_outline),
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
              TextButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more_rounded),
                label: const Text('Load more'),
              ),
            ],
          );

          final statusRow = Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                size: 12,
                color: AppColours.darkSuccess.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ),
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 14),
                statusRow,
                const SizedBox(height: 14),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 18),
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [actions, const SizedBox(height: 14), statusRow],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColours.darkSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search title, filename, folder, tags, or extracted text...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(Icons.clear_rounded),
              ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final KnowledgeLibraryStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.totalPdfs;
    final extractable = stats.textExtractable;
    final ocrNeeded = stats.ocrRequired;
    final audioReady = stats.audioGenerated;
    final extractableRatio = total == 0 ? 0.0 : extractable / total;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatCard(
          label: 'Total PDFs',
          value: '$total',
          detail: 'Across all configured Omega OS library folders',
          icon: Icons.library_books_outlined,
          accent: AppColours.darkSecondary,
        ),
        _StatCard(
          label: 'Extractable',
          value: '$extractable',
          detail: '${(extractableRatio * 100).round()}% of the current library',
          icon: Icons.description_outlined,
          accent: AppColours.darkSuccess,
        ),
        _StatCard(
          label: 'OCR Needed',
          value: '$ocrNeeded',
          detail: 'Likely scanned or image-only PDFs',
          icon: Icons.document_scanner_outlined,
          accent: AppColours.darkAmber,
        ),
        _StatCard(
          label: 'Audio Ready',
          value: '$audioReady',
          detail: 'Future MP3 pipeline can pick these up',
          icon: Icons.graphic_eq_outlined,
          accent: AppColours.darkPurple,
        ),
      ],
    );
  }
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({required this.selected, required this.onSelected});

  final KnowledgeLibraryFilter selected;
  final ValueChanged<KnowledgeLibraryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: KnowledgeLibraryFilter.values
          .map(
            (filter) => ChoiceChip(
              selected: filter == selected,
              label: Text(filter.label),
              onSelected: (_) => onSelected(filter),
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: filter == selected
                    ? AppColours.darkBackground
                    : AppColours.darkText,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColours.darkSecondary,
              backgroundColor: AppColours.darkSurfaceAlt.withValues(alpha: 0.9),
              side: BorderSide(
                color: filter == selected
                    ? AppColours.darkSecondary
                    : AppColours.darkOutline,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SourceSectionStrip extends StatelessWidget {
  const _SourceSectionStrip({
    required this.sections,
    required this.selected,
    required this.onSelected,
    this.onClear,
  });

  final Map<String, int> sections;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final entries = sections.entries.toList()
      ..sort((left, right) {
        final countCompare = right.value.compareTo(left.value);
        if (countCompare != 0) {
          return countCompare;
        }

        return left.key.toLowerCase().compareTo(right.key.toLowerCase());
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Source section',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColours.darkText),
            ),
            const Spacer(),
            if (onClear != null)
              TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              selected: selected == null,
              label: const Text('All sections'),
              onSelected: (_) => onSelected(null),
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected == null
                    ? AppColours.darkBackground
                    : AppColours.darkText,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColours.darkPrimary,
              backgroundColor: AppColours.darkSurfaceAlt.withValues(alpha: 0.9),
              side: BorderSide(
                color: selected == null
                    ? AppColours.darkPrimary
                    : AppColours.darkOutline,
              ),
            ),
            ...entries.map(
              (entry) => ChoiceChip(
                selected: entry.key == selected,
                label: Text('${entry.key} (${entry.value})'),
                onSelected: (_) => onSelected(entry.key),
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: entry.key == selected
                      ? AppColours.darkBackground
                      : AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: AppColours.darkSecondary,
                backgroundColor: AppColours.darkSurfaceAlt.withValues(
                  alpha: 0.9,
                ),
                side: BorderSide(
                  color: entry.key == selected
                      ? AppColours.darkSecondary
                      : AppColours.darkOutline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryPanel extends StatelessWidget {
  const _LibraryPanel({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.selectedItemId,
    required this.onSelect,
    required this.onOpenOriginal,
    required this.onCopyPath,
  });

  final String title;
  final String subtitle;
  final List<KnowledgeLibraryItem> items;
  final String? selectedItemId;
  final ValueChanged<KnowledgeLibraryItem> onSelect;
  final Future<void> Function(KnowledgeLibraryItem item) onOpenOriginal;
  final Future<void> Function(KnowledgeLibraryItem item) onCopyPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.view_list_rounded, color: AppColours.darkSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ),
              Text(
                '${items.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: items.isEmpty
                ? _EmptyListState(
                    title: 'No library items to show yet.',
                    subtitle:
                        'Try a different search or refresh the catalogue.',
                  )
                : Scrollbar(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final selected = item.id == selectedItemId;
                        return _LibraryItemCard(
                          item: item,
                          selected: selected,
                          onTap: () => onSelect(item),
                          onOpenOriginal: () => onOpenOriginal(item),
                          onCopyPath: () => onCopyPath(item),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LibraryItemCard extends StatelessWidget {
  const _LibraryItemCard({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onOpenOriginal,
    required this.onCopyPath,
  });

  final KnowledgeLibraryItem item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpenOriginal;
  final VoidCallback onCopyPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColours.darkSurfaceRaised.withValues(alpha: 0.98)
              : AppColours.darkSurfaceAlt.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColours.darkSecondary.withValues(alpha: 0.45)
                : AppColours.darkOutline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title.isNotEmpty ? item.title : item.filename,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (item.textExtractable)
                  const _MiniBadge(
                    label: 'Text',
                    accent: AppColours.darkSuccess,
                  ),
                if (item.ocrRequired) ...[
                  const SizedBox(width: 6),
                  const _MiniBadge(label: 'OCR', accent: AppColours.darkAmber),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.filename,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.relativePath,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(
                  label: item.sourceSection,
                  accent: AppColours.darkSecondary,
                ),
                _MiniBadge(
                  label: item.category,
                  accent: AppColours.darkSurfaceRaised,
                  foreground: AppColours.darkText,
                ),
                _MiniBadge(
                  label: item.audioStatus,
                  accent: item.audioStatus == 'generated'
                      ? AppColours.darkSuccess
                      : AppColours.darkPurple,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatBytes(item.fileSizeBytes)}'
                    '${item.pageCount == null ? '' : ' • ${item.pageCount} pages'}'
                    '${item.modifiedAt == null ? '' : ' • ${DateFormat('d MMM y').format(item.modifiedAt!)}'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Open original file',
                  onPressed: onOpenOriginal,
                  icon: const Icon(Icons.open_in_new_rounded),
                ),
                IconButton(
                  tooltip: 'Copy path',
                  onPressed: onCopyPath,
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.label,
    required this.accent,
    this.foreground,
  });

  final String label;
  final Color accent;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foreground ?? accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.item,
    required this.onOpenOriginal,
    required this.onOpenContainingFolder,
    required this.onOpenExtractedTextFolder,
    required this.onCopyPath,
    required this.onCopyExtractedPath,
    required this.onCopyManifestPath,
    required this.onOpenManifest,
    required this.onOpenExtractedText,
    required this.onRefresh,
  });

  final KnowledgeLibraryItem? item;
  final Future<void> Function(KnowledgeLibraryItem item) onOpenOriginal;
  final Future<void> Function(KnowledgeLibraryItem item) onOpenContainingFolder;
  final Future<void> Function(KnowledgeLibraryItem item)
  onOpenExtractedTextFolder;
  final Future<void> Function(KnowledgeLibraryItem item) onCopyPath;
  final Future<void> Function(KnowledgeLibraryItem item) onCopyExtractedPath;
  final Future<void> Function(KnowledgeLibraryItem item) onCopyManifestPath;
  final Future<void> Function(KnowledgeLibraryItem item) onOpenManifest;
  final Future<void> Function(KnowledgeLibraryItem item) onOpenExtractedText;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = item;

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(16),
      child: current == null
          ? _EmptyListState(
              title: 'Select a PDF to see details.',
              subtitle:
                  'The detail panel will show the original path, extraction status, and future audio status.',
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          current.title.isNotEmpty
                              ? current.title
                              : current.filename,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColours.darkText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh catalogue',
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    current.filename,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniBadge(
                        label: current.sourceSection,
                        accent: AppColours.darkSecondary,
                      ),
                      _MiniBadge(
                        label: current.category,
                        accent: AppColours.darkSurfaceRaised,
                        foreground: AppColours.darkText,
                      ),
                      _MiniBadge(
                        label: current.summaryStatus,
                        accent: AppColours.darkPurple,
                      ),
                      _MiniBadge(
                        label: current.audioStatus,
                        accent: current.audioStatus == 'generated'
                            ? AppColours.darkSuccess
                            : AppColours.darkPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'File size',
                    value: formatBytes(current.fileSizeBytes),
                  ),
                  _DetailRow(
                    label: 'Pages',
                    value: current.pageCount?.toString() ?? 'Unknown',
                  ),
                  _DetailRow(
                    label: 'Created',
                    value: formatDate(current.createdAt),
                  ),
                  _DetailRow(
                    label: 'Modified',
                    value: formatDate(current.modifiedAt),
                  ),
                  _DetailRow(
                    label: 'Text extractable',
                    value: current.textExtractable ? 'Yes' : 'No',
                  ),
                  _DetailRow(
                    label: 'OCR required',
                    value: current.ocrRequired ? 'Yes' : 'No',
                  ),
                  const SizedBox(height: 14),
                  _PathBlock(title: 'Original file', value: current.fullPath),
                  if (current.extractedTextPath != null &&
                      current.extractedTextPath!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PathBlock(
                      title: 'Extracted text',
                      value: current.extractedTextPath!,
                    ),
                  ],
                  if (current.notesPath != null &&
                      current.notesPath!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PathBlock(title: 'Notes path', value: current.notesPath!),
                  ],
                  if (current.audioManifestPath != null &&
                      current.audioManifestPath!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PathBlock(
                      title: 'Audio manifest',
                      value: current.audioManifestPath!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    'Tags',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColours.darkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: current.tags.isEmpty
                        ? const [
                            _MiniBadge(
                              label: 'No tags yet',
                              accent: AppColours.darkMutedText,
                            ),
                          ]
                        : current.tags
                              .map(
                                (tag) => _MiniBadge(
                                  label: tag,
                                  accent: AppColours.darkSecondary,
                                ),
                              )
                              .toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => onOpenOriginal(current),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Open original'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => onOpenContainingFolder(current),
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text('Open folder'),
                      ),
                      if (current.hasExtractedText)
                        OutlinedButton.icon(
                          onPressed: () => onOpenExtractedTextFolder(current),
                          icon: const Icon(Icons.folder_copy_outlined),
                          label: const Text('Text folder'),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => onCopyPath(current),
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy path'),
                      ),
                      if (current.hasExtractedText) ...[
                        OutlinedButton.icon(
                          onPressed: () => onCopyExtractedPath(current),
                          icon: const Icon(Icons.content_copy_rounded),
                          label: const Text('Copy text path'),
                        ),
                        TextButton.icon(
                          onPressed: () => onOpenExtractedText(current),
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('Open text'),
                        ),
                      ],
                      if (current.audioManifestPath != null &&
                          current.audioManifestPath!.trim().isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: () => onCopyManifestPath(current),
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copy manifest path'),
                        ),
                        TextButton.icon(
                          onPressed: () => onOpenManifest(current),
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Open manifest'),
                        ),
                      ],
                    ],
                  ),
                  if (current.hasExtractedText) ...[
                    const SizedBox(height: 8),
                    Text(
                      'The text path action only appears when extracted text exists.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'The Knowledge Engine never moves the source PDF. It only reads Omega OS and writes generated outputs into the reserved local folders.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PathBlock extends StatelessWidget {
  const _PathBlock({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 148,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkText),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyListState extends StatelessWidget {
  const _EmptyListState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.library_books_outlined,
              size: 42,
              color: AppColours.darkSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 44,
                color: AppColours.darkAmber,
              ),
              const SizedBox(height: 12),
              Text(
                'Knowledge Library could not reach the local API.',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Start the module with `uvicorn api.main:app --reload --port 8787`, then press Refresh.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
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

String formatBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }

  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var index = 0;
  while (value >= 1024 && index < suffixes.length - 1) {
    value /= 1024;
    index += 1;
  }

  final formatted = value >= 10 || value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
  return '$formatted ${suffixes[index]}';
}

String formatDate(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Unknown';
  }

  return DateFormat('d MMM y').format(dateTime);
}
