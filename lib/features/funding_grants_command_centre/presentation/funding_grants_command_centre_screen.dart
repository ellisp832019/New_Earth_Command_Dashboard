import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../data/funding_grants_repository.dart';
import '../models/grant_record.dart';
import '../models/grant_status.dart';
import '../models/readiness_score.dart';

class FundingGrantsCommandCentreScreen extends ConsumerStatefulWidget {
  const FundingGrantsCommandCentreScreen({super.key});

  @override
  ConsumerState<FundingGrantsCommandCentreScreen> createState() =>
      _FundingGrantsCommandCentreScreenState();
}

class _FundingGrantsCommandCentreScreenState
    extends ConsumerState<FundingGrantsCommandCentreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _grantNameController = TextEditingController();
  final _projectController = TextEditingController();
  final _fundingBodyController = TextEditingController();
  final _fundingTypeController = TextEditingController();
  final _amountRequestedController = TextEditingController();
  final _matchFundingController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _priorityController = TextEditingController();
  final _ownerController = TextEditingController();
  final _nextActionController = TextEditingController();
  final _riskLevelController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _submissionDateController = TextEditingController();
  final _decisionDateController = TextEditingController();
  final _projectSummaryController = TextEditingController();
  final _budgetController = TextEditingController();
  final _evidenceController = TextEditingController();
  final _partnerSupportController = TextEditingController();
  final _impactCaseController = TextEditingController();
  final _commercialPlanController = TextEditingController();
  final _riskManagementController = TextEditingController();

  List<GrantRecord> _grants = const <GrantRecord>[];
  String? _selectedGrantId;
  final List<String> _grantHistory = <String>[];
  int _grantHistoryIndex = -1;
  String _searchQuery = '';
  GrantStatusFilter _statusFilter = GrantStatusFilter.all;
  GrantSortMode _sortMode = GrantSortMode.deadlineSoonest;
  GrantStatus _draftStatus = GrantStatus.drafting;
  bool _loading = true;
  bool _saving = false;
  bool _fileOpsBusy = false;
  String? _error;

  FundingGrantsRepository get _repository =>
      ref.read(fundingGrantsRepositoryProvider);

  GrantRecord? get _selectedGrant {
    for (final grant in _grants) {
      if (grant.id == _selectedGrantId) {
        return grant;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadGrants();
  }

  @override
  void dispose() {
    _grantNameController.dispose();
    _projectController.dispose();
    _fundingBodyController.dispose();
    _fundingTypeController.dispose();
    _amountRequestedController.dispose();
    _matchFundingController.dispose();
    _deadlineController.dispose();
    _priorityController.dispose();
    _ownerController.dispose();
    _nextActionController.dispose();
    _riskLevelController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _submissionDateController.dispose();
    _decisionDateController.dispose();
    _projectSummaryController.dispose();
    _budgetController.dispose();
    _evidenceController.dispose();
    _partnerSupportController.dispose();
    _impactCaseController.dispose();
    _commercialPlanController.dispose();
    _riskManagementController.dispose();
    super.dispose();
  }

  Future<void> _loadGrants({String? selectGrantId}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final grants = await _repository.loadGrants();
      final selectedId = _resolveSelectedId(grants, selectGrantId);
      setState(() {
        _grants = grants;
        _selectedGrantId = selectedId;
        _draftStatus = _selectedGrant?.status ?? GrantStatus.drafting;
        _loading = false;
      });
      _syncFormFromSelection();
      _recordGrantHistory(selectedId);
    } catch (error) {
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  String? _resolveSelectedId(List<GrantRecord> grants, String? requestedId) {
    if (requestedId != null && grants.any((grant) => grant.id == requestedId)) {
      return requestedId;
    }
    if (_selectedGrantId != null &&
        grants.any((grant) => grant.id == _selectedGrantId)) {
      return _selectedGrantId;
    }
    return grants.isEmpty ? null : grants.first.id;
  }

  void _syncFormFromSelection() {
    final grant = _selectedGrant;
    if (grant == null) {
      _clearFormForNewGrant();
      return;
    }

    _grantNameController.text = grant.grantName;
    _projectController.text = grant.project;
    _fundingBodyController.text = grant.fundingBody;
    _fundingTypeController.text = grant.fundingType;
    _amountRequestedController.text = grant.amountRequested.toStringAsFixed(0);
    _matchFundingController.text = grant.matchFundingRequired;
    _deadlineController.text = grant.deadline;
    _priorityController.text = grant.priority;
    _ownerController.text = grant.owner;
    _nextActionController.text = grant.nextAction;
    _riskLevelController.text = grant.riskLevel;
    _notesController.text = grant.notes;
    _tagsController.text = grant.tags.join(', ');
    _submissionDateController.text = grant.submissionDate ?? '';
    _decisionDateController.text = grant.decisionDate ?? '';
    _projectSummaryController.text = grant.readinessScore.projectSummary.toString();
    _budgetController.text = grant.readinessScore.budget.toString();
    _evidenceController.text = grant.readinessScore.evidence.toString();
    _partnerSupportController.text = grant.readinessScore.partnerSupport.toString();
    _impactCaseController.text = grant.readinessScore.impactCase.toString();
    _commercialPlanController.text = grant.readinessScore.commercialPlan.toString();
    _riskManagementController.text = grant.readinessScore.riskManagement.toString();
    _draftStatus = grant.status;
  }

  void _recordGrantHistory(String? grantId) {
    if (grantId == null || grantId.isEmpty) {
      return;
    }

    if (_grantHistoryIndex >= 0 &&
        _grantHistoryIndex < _grantHistory.length &&
        _grantHistory[_grantHistoryIndex] == grantId) {
      return;
    }

    if (_grantHistoryIndex < _grantHistory.length - 1) {
      _grantHistory.removeRange(_grantHistoryIndex + 1, _grantHistory.length);
    }

    _grantHistory.add(grantId);
    _grantHistoryIndex = _grantHistory.length - 1;
  }

  bool get _canGoToPreviousGrant {
    if (_selectedGrantId == null) {
      return _grantHistory.isNotEmpty && _grantHistoryIndex >= 0;
    }
    return _grantHistoryIndex > 0;
  }

  bool get _canGoToNextGrant {
    if (_selectedGrantId == null) {
      return false;
    }
    return _grantHistoryIndex >= 0 &&
        _grantHistoryIndex < _grantHistory.length - 1;
  }

  void _goToPreviousGrant() {
    if (!_canGoToPreviousGrant) {
      return;
    }

    final targetIndex = _selectedGrantId == null
        ? _grantHistoryIndex
        : _grantHistoryIndex - 1;
    if (targetIndex < 0 || targetIndex >= _grantHistory.length) {
      return;
    }

    _selectGrantById(_grantHistory[targetIndex]);
  }

  void _goToNextGrant() {
    if (!_canGoToNextGrant) {
      return;
    }

    final targetIndex = _grantHistoryIndex + 1;
    if (targetIndex < 0 || targetIndex >= _grantHistory.length) {
      return;
    }

    _selectGrantById(_grantHistory[targetIndex]);
  }

  void _selectGrantById(String grantId) {
    final grantIndex = _grants.indexWhere((item) => item.id == grantId);
    if (grantIndex == -1) {
      return;
    }
    final grant = _grants[grantIndex];
    setState(() {
      _selectedGrantId = grant.id;
      _draftStatus = grant.status;
    });
    _syncFormFromSelection();
    _recordGrantHistory(grant.id);
  }

  void _clearFormForNewGrant() {
    _grantNameController.clear();
    _projectController.clear();
    _fundingBodyController.clear();
    _fundingTypeController.clear();
    _amountRequestedController.clear();
    _matchFundingController.text = 'TBC';
    _deadlineController.text = 'TBC';
    _priorityController.text = 'Medium';
    _ownerController.text = 'Peter Ellis';
    _nextActionController.clear();
    _riskLevelController.text = 'Medium';
    _notesController.clear();
    _tagsController.clear();
    _submissionDateController.clear();
    _decisionDateController.clear();
    _projectSummaryController.text = '0';
    _budgetController.text = '0';
    _evidenceController.text = '0';
    _partnerSupportController.text = '0';
    _impactCaseController.text = '0';
    _commercialPlanController.text = '0';
    _riskManagementController.text = '0';
    _draftStatus = GrantStatus.drafting;
  }

  GrantRecord _draftFromForm({String? id}) {
    return GrantRecord(
      id: id ?? '',
      grantName: _grantNameController.text.trim(),
      project: _projectController.text.trim(),
      fundingBody: _fundingBodyController.text.trim(),
      fundingType: _fundingTypeController.text.trim(),
      amountRequested: double.tryParse(_amountRequestedController.text.trim()) ?? 0,
      matchFundingRequired: _matchFundingController.text.trim(),
      status: _draftStatus,
      deadline: _deadlineController.text.trim().isEmpty
          ? 'TBC'
          : _deadlineController.text.trim(),
      submissionDate: _optionalText(_submissionDateController.text),
      decisionDate: _optionalText(_decisionDateController.text),
      priority: _priorityController.text.trim().isEmpty
          ? 'Medium'
          : _priorityController.text.trim(),
      owner: _ownerController.text.trim().isEmpty
          ? 'Peter Ellis'
          : _ownerController.text.trim(),
      nextAction: _nextActionController.text.trim(),
      riskLevel: _riskLevelController.text.trim().isEmpty
          ? 'Medium'
          : _riskLevelController.text.trim(),
      readinessScore: ReadinessScore(
        projectSummary: _intValue(_projectSummaryController.text),
        budget: _intValue(_budgetController.text),
        evidence: _intValue(_evidenceController.text),
        partnerSupport: _intValue(_partnerSupportController.text),
        impactCase: _intValue(_impactCaseController.text),
        commercialPlan: _intValue(_commercialPlanController.text),
        riskManagement: _intValue(_riskManagementController.text),
      ),
      folderPath: _selectedGrant?.folderPath ?? '',
      notes: _notesController.text.trim(),
      tags: _readTags(_tagsController.text),
    );
  }

  Future<void> _saveGrant() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showSnackBar('Please fix the highlighted grant fields before saving.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final previous = _selectedGrant;
      final draft = _draftFromForm(id: previous?.id);
      final saved = previous == null
          ? await _repository.createGrant(draft)
          : await _repository.saveGrant(draft, previous: previous);
      await _loadGrants(selectGrantId: saved.id);
      _showSnackBar('Grant saved and tracker updated.');
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _newGrant() async {
    setState(() {
      _selectedGrantId = null;
      _clearFormForNewGrant();
    });
    _showSnackBar('Ready for a new grant draft.');
  }

  Future<void> _applyGrantStatus(GrantStatus status) async {
    setState(() {
      _draftStatus = status;
    });

    final selected = _selectedGrant;
    if (selected == null) {
      _showSnackBar('Draft status set to ${status.label}.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _repository.updateGrantStatus(selected, status);
      await _loadGrants(selectGrantId: selected.id);
      _showSnackBar('Moved ${selected.grantName} to ${status.label}.');
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _refreshFolder() async {
    final selected = _selectedGrant;
    if (selected == null) {
      return;
    }

    try {
      await _repository.saveGrant(selected, previous: selected);
      await _loadGrants(selectGrantId: selected.id);
      _showSnackBar('Grant folder checked and refreshed.');
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    }
  }

  Future<void> _openFolder() async {
    final selected = _selectedGrant;
    if (selected == null) {
      return;
    }

    final folderPath = selected.folderPath.trim();
    final folderExists =
        folderPath.isNotEmpty && await Directory(folderPath).exists();
    if (folderExists) {
      await Process.start('explorer', [folderPath]);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showSnackBar('Fix the grant fields before creating the folder.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final draft = _draftFromForm(id: selected.id);
      final saved = await _repository.saveGrant(draft, previous: selected);
      await _loadGrants(selectGrantId: saved.id);
      await Process.start('explorer', [saved.folderPath]);
      _showSnackBar('Grant folder created and opened.');
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _copyFolderPath() async {
    final selected = _selectedGrant;
    if (selected == null) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: selected.folderPath));
    _showSnackBar('Folder path copied.');
  }

  Future<void> _exportTracker() async {
    setState(() {
      _fileOpsBusy = true;
    });

    try {
      final exportsDir = await _repository.exportTrackerSnapshot();
      _showSnackBar('Tracker exported to ${exportsDir.path}.');
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _fileOpsBusy = false;
        });
      }
    }
  }

  Future<void> _importTracker() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json', 'csv'],
      dialogTitle: 'Import grant tracker file',
    );
    if (result == null || result.files.isEmpty) {
      return;
    }

    final filePath = result.files.single.path;
    if (filePath == null || filePath.isEmpty) {
      return;
    }

    setState(() {
      _fileOpsBusy = true;
    });

    try {
      await _repository.importTrackerFile(filePath);
      await _loadGrants();
      _showSnackBar('Tracker imported from ${path.basename(filePath)}.');
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _fileOpsBusy = false;
        });
      }
    }
  }

  void _selectGrant(GrantRecord grant) {
    setState(() {
      _selectedGrantId = grant.id;
      _draftStatus = grant.status;
    });
    _syncFormFromSelection();
    _recordGrantHistory(grant.id);
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = _summaryFor(_grants);
    final selectedGrant = _selectedGrant;
    final visibleGrants = _filteredGrants(_grants);
    final wide = MediaQuery.sizeOf(context).width >= 1180;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeaderCard(
              summary: summary,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteNames.dashboard);
                }
              },
              onNewGrant: _newGrant,
              onRefresh: () => _loadGrants(selectGrantId: _selectedGrantId),
              onExport: _fileOpsBusy ? null : _exportTracker,
              onImport: _fileOpsBusy ? null : _importTracker,
            ),
            const SizedBox(height: 16),
            _CompactStatusPanel(summary: summary, selectedGrant: selectedGrant),
            const SizedBox(height: 16),
            if (_error != null) ...[
              _ErrorBanner(message: _error!),
              const SizedBox(height: 16),
            ],
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _GrantListPanel(
                      grants: visibleGrants,
                      selectedGrantId: _selectedGrantId,
                      onSelectGrant: _selectGrant,
                      searchQuery: _searchQuery,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      statusFilter: _statusFilter,
                      onStatusFilterChanged: (value) {
                        setState(() {
                          _statusFilter = value;
                        });
                      },
                      sortMode: _sortMode,
                      onSortModeChanged: (value) {
                        setState(() {
                          _sortMode = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 7,
                    child: _GrantEditorPanel(
                      formKey: _formKey,
                      selectedGrant: selectedGrant,
                      saving: _saving,
                      draftStatus: _draftStatus,
                      onStatusChanged: (value) {
                        setState(() {
                          _draftStatus = value;
                        });
                      },
                      grantNameController: _grantNameController,
                      projectController: _projectController,
                      fundingBodyController: _fundingBodyController,
                      fundingTypeController: _fundingTypeController,
                      amountRequestedController: _amountRequestedController,
                      matchFundingController: _matchFundingController,
                      deadlineController: _deadlineController,
                      priorityController: _priorityController,
                      ownerController: _ownerController,
                      nextActionController: _nextActionController,
                      riskLevelController: _riskLevelController,
                      notesController: _notesController,
                      tagsController: _tagsController,
                      submissionDateController: _submissionDateController,
                      decisionDateController: _decisionDateController,
                      projectSummaryController: _projectSummaryController,
                      budgetController: _budgetController,
                      evidenceController: _evidenceController,
                      partnerSupportController: _partnerSupportController,
                      impactCaseController: _impactCaseController,
                      commercialPlanController: _commercialPlanController,
                      riskManagementController: _riskManagementController,
                      onSave: _saveGrant,
                      onOpenFolder: _openFolder,
                      onCopyFolderPath: _copyFolderPath,
                      onRefreshFolder: _refreshFolder,
                      onExport: _fileOpsBusy ? null : _exportTracker,
                      onImport: _fileOpsBusy ? null : _importTracker,
                      onStatusAction: _applyGrantStatus,
                      onPreviousGrant: _canGoToPreviousGrant ? _goToPreviousGrant : null,
                      onNextGrant: _canGoToNextGrant ? _goToNextGrant : null,
                    ),
                  ),
                ],
              )
            else ...[
              _GrantListPanel(
                grants: visibleGrants,
                selectedGrantId: _selectedGrantId,
                onSelectGrant: _selectGrant,
                searchQuery: _searchQuery,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                statusFilter: _statusFilter,
                onStatusFilterChanged: (value) {
                  setState(() {
                    _statusFilter = value;
                  });
                },
                sortMode: _sortMode,
                onSortModeChanged: (value) {
                  setState(() {
                    _sortMode = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _GrantEditorPanel(
                formKey: _formKey,
                selectedGrant: selectedGrant,
                saving: _saving,
                draftStatus: _draftStatus,
                onStatusChanged: (value) {
                  setState(() {
                    _draftStatus = value;
                  });
                },
                grantNameController: _grantNameController,
                projectController: _projectController,
                fundingBodyController: _fundingBodyController,
                fundingTypeController: _fundingTypeController,
                amountRequestedController: _amountRequestedController,
                matchFundingController: _matchFundingController,
                deadlineController: _deadlineController,
                priorityController: _priorityController,
                ownerController: _ownerController,
                nextActionController: _nextActionController,
                riskLevelController: _riskLevelController,
                notesController: _notesController,
                tagsController: _tagsController,
                submissionDateController: _submissionDateController,
                decisionDateController: _decisionDateController,
                projectSummaryController: _projectSummaryController,
                budgetController: _budgetController,
                evidenceController: _evidenceController,
                partnerSupportController: _partnerSupportController,
                impactCaseController: _impactCaseController,
                commercialPlanController: _commercialPlanController,
                riskManagementController: _riskManagementController,
                onSave: _saveGrant,
                onOpenFolder: _openFolder,
                onCopyFolderPath: _copyFolderPath,
                onRefreshFolder: _refreshFolder,
                onExport: _fileOpsBusy ? null : _exportTracker,
                onImport: _fileOpsBusy ? null : _importTracker,
                onStatusAction: _applyGrantStatus,
                onPreviousGrant: _canGoToPreviousGrant ? _goToPreviousGrant : null,
                onNextGrant: _canGoToNextGrant ? _goToNextGrant : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  FundingGrantsSummary _summaryFor(List<GrantRecord> grants) {
    final totalRequested = grants.fold<double>(
      0,
      (sum, grant) => sum + grant.amountRequested,
    );
    final readyCount =
        grants.where((grant) => grant.status == GrantStatus.readyToSubmit).length;
    final submittedCount = grants
        .where(
          (grant) =>
              grant.status == GrantStatus.submitted ||
              grant.status == GrantStatus.underReview,
        )
        .length;
    final approvedCount = grants
        .where(
          (grant) =>
              grant.status == GrantStatus.approved ||
              grant.status == GrantStatus.reportingPhase ||
              grant.status == GrantStatus.closed,
        )
        .length;
    final pausedCount = grants
        .where(
          (grant) =>
              grant.status == GrantStatus.paused ||
              grant.status == GrantStatus.rejected,
        )
        .length;
    final missingNextActionsCount =
        grants.where((grant) => grant.nextAction.trim().isEmpty).length;
    final dueSoonCount = _dueSoonCount(grants);
    final readinessAverage = grants.isEmpty
        ? 0
        : (grants.fold<int>(0, (sum, grant) => sum + grant.readinessScore.total) /
                grants.length)
            .round();

    return FundingGrantsSummary(
      totalGrants: grants.length,
      totalRequested: totalRequested,
      readyCount: readyCount,
      submittedCount: submittedCount,
      approvedCount: approvedCount,
      pausedCount: pausedCount,
      dueSoonCount: dueSoonCount,
      missingNextActionsCount: missingNextActionsCount,
      readinessAverage: readinessAverage,
    );
  }

  int _dueSoonCount(List<GrantRecord> grants) {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30));
    return grants.where((grant) {
      final deadline = grant.deadlineDate;
      return deadline != null &&
          deadline.isAfter(now.subtract(const Duration(days: 1))) &&
          deadline.isBefore(threshold);
    }).length;
  }

  int _intValue(String value) => int.tryParse(value.trim()) ?? 0;

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<String> _readTags(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<GrantRecord> _filteredGrants(List<GrantRecord> grants) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = grants.where((grant) {
      if (!_matchesStatusFilter(grant, _statusFilter)) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final haystack = [
        grant.id,
        grant.grantName,
        grant.project,
        grant.fundingBody,
        grant.fundingType,
        grant.status.label,
        grant.priority,
        grant.owner,
        grant.nextAction,
        grant.riskLevel,
        grant.notes,
        grant.folderPath,
        ...grant.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();

    filtered.sort((a, b) => _compareGrants(a, b, _sortMode));
    return filtered;
  }

  bool _matchesStatusFilter(GrantRecord grant, GrantStatusFilter filter) {
    switch (filter) {
      case GrantStatusFilter.all:
        return true;
      case GrantStatusFilter.drafting:
        return grant.status == GrantStatus.drafting ||
            grant.status == GrantStatus.idea ||
            grant.status == GrantStatus.researching;
      case GrantStatusFilter.attention:
        return grant.status == GrantStatus.needsEvidence ||
            grant.status == GrantStatus.needsBudget ||
            grant.status == GrantStatus.needsPartner ||
            grant.status == GrantStatus.eligible;
      case GrantStatusFilter.ready:
        return grant.status == GrantStatus.readyToSubmit;
      case GrantStatusFilter.submitted:
        return grant.status == GrantStatus.submitted ||
            grant.status == GrantStatus.underReview;
      case GrantStatusFilter.approved:
        return grant.status == GrantStatus.approved ||
            grant.status == GrantStatus.reportingPhase ||
            grant.status == GrantStatus.closed;
      case GrantStatusFilter.paused:
        return grant.status == GrantStatus.paused ||
            grant.status == GrantStatus.rejected;
    }
  }

  int _compareGrants(GrantRecord a, GrantRecord b, GrantSortMode sortMode) {
    switch (sortMode) {
      case GrantSortMode.deadlineSoonest:
        return _compareByDeadline(a, b);
      case GrantSortMode.readinessHighest:
        return b.readinessScore.total.compareTo(a.readinessScore.total);
      case GrantSortMode.name:
        return a.grantName.toLowerCase().compareTo(b.grantName.toLowerCase());
    }
  }

  int _compareByDeadline(GrantRecord a, GrantRecord b) {
    final aDate = a.deadlineDate ?? DateTime(9999);
    final bDate = b.deadlineDate ?? DateTime(9999);
    final dateCompare = aDate.compareTo(bDate);
    if (dateCompare != 0) {
      return dateCompare;
    }
    return a.grantName.toLowerCase().compareTo(b.grantName.toLowerCase());
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.summary,
    required this.onBack,
    required this.onNewGrant,
    required this.onRefresh,
    this.onExport,
    this.onImport,
  });

  final FundingGrantsSummary summary;
  final VoidCallback onBack;
  final VoidCallback onNewGrant;
  final VoidCallback onRefresh;
  final VoidCallback? onExport;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
              ),
              const Icon(
                Icons.campaign_outlined,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Funding & Grants Command Centre',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onNewGrant,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('New Grant'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onExport,
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Export'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Import'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Local-first grant tracking, folder packing, readiness scoring, and Omega OS tracker sync.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(
                label: 'Total grants',
                value: '${summary.totalGrants}',
              ),
              _MetricChip(
                label: 'Requested',
                value: _money(summary.totalRequested),
              ),
              _MetricChip(label: 'Ready', value: '${summary.readyCount}'),
              _MetricChip(
                label: 'Submitted',
                value: '${summary.submittedCount}',
              ),
              _MetricChip(
                label: 'Approved',
                value: '${summary.approvedCount}',
              ),
              _MetricChip(
                label: 'Paused / rejected',
                value: '${summary.pausedCount}',
              ),
              _MetricChip(label: 'Due soon', value: '${summary.dueSoonCount}'),
              _MetricChip(
                label: 'Missing next action',
                value: '${summary.missingNextActionsCount}',
              ),
              _MetricChip(
                label: 'Avg readiness',
                value: '${summary.readinessAverage}/70',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactStatusPanel extends StatelessWidget {
  const _CompactStatusPanel({
    required this.summary,
    required this.selectedGrant,
  });

  final FundingGrantsSummary summary;
  final GrantRecord? selectedGrant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedLabel = selectedGrant == null
        ? 'No grant selected'
        : '${selectedGrant!.grantName} • ${selectedGrant!.status.label}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_outlined,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Workflow snapshot',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                selectedLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CompactStatTile(label: 'Ready', value: '${summary.readyCount}'),
              _CompactStatTile(
                label: 'Due soon',
                value: '${summary.dueSoonCount}',
              ),
              _CompactStatTile(
                label: 'Parked',
                value: '${summary.pausedCount}',
              ),
              _CompactStatTile(
                label: 'Missing next step',
                value: '${summary.missingNextActionsCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary.readyCount > 0
                ? 'There is at least one grant ready to move forward.'
                : 'Keep one grant moving and park the rest until the next useful step is clear.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrantListPanel extends StatelessWidget {
  const _GrantListPanel({
    required this.grants,
    required this.selectedGrantId,
    required this.onSelectGrant,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.sortMode,
    required this.onSortModeChanged,
  });

  final List<GrantRecord> grants;
  final String? selectedGrantId;
  final ValueChanged<GrantRecord> onSelectGrant;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final GrantStatusFilter statusFilter;
  final ValueChanged<GrantStatusFilter> onStatusFilterChanged;
  final GrantSortMode sortMode;
  final ValueChanged<GrantSortMode> onSortModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.view_list_outlined,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Grant pipeline',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColours.darkText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              labelText: 'Search grants',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'All',
                selected: statusFilter == GrantStatusFilter.all,
                onSelected: () => onStatusFilterChanged(GrantStatusFilter.all),
              ),
              _FilterChip(
                label: 'Drafting',
                selected: statusFilter == GrantStatusFilter.drafting,
                onSelected: () =>
                    onStatusFilterChanged(GrantStatusFilter.drafting),
              ),
              _FilterChip(
                label: 'Attention',
                selected: statusFilter == GrantStatusFilter.attention,
                onSelected: () =>
                    onStatusFilterChanged(GrantStatusFilter.attention),
              ),
              _FilterChip(
                label: 'Ready',
                selected: statusFilter == GrantStatusFilter.ready,
                onSelected: () => onStatusFilterChanged(GrantStatusFilter.ready),
              ),
              _FilterChip(
                label: 'Submitted',
                selected: statusFilter == GrantStatusFilter.submitted,
                onSelected: () =>
                    onStatusFilterChanged(GrantStatusFilter.submitted),
              ),
              _FilterChip(
                label: 'Approved',
                selected: statusFilter == GrantStatusFilter.approved,
                onSelected: () =>
                    onStatusFilterChanged(GrantStatusFilter.approved),
              ),
              _FilterChip(
                label: 'Paused',
                selected: statusFilter == GrantStatusFilter.paused,
                onSelected: () => onStatusFilterChanged(GrantStatusFilter.paused),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<GrantSortMode>(
            initialValue: sortMode,
            decoration: const InputDecoration(labelText: 'Sort by'),
            items: const [
              DropdownMenuItem(
                value: GrantSortMode.deadlineSoonest,
                child: Text('Deadline soonest'),
              ),
              DropdownMenuItem(
                value: GrantSortMode.readinessHighest,
                child: Text('Readiness highest'),
              ),
              DropdownMenuItem(
                value: GrantSortMode.name,
                child: Text('Name'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onSortModeChanged(value);
              }
            },
          ),
          const SizedBox(height: 12),
          Text(
            grants.isEmpty
                ? 'No grants match your current view.'
                : '${grants.length} grant${grants.length == 1 ? '' : 's'} in view',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
          ),
          if (grants.isEmpty)
            Text(
              searchQuery.trim().isEmpty
                  ? 'No grants found yet. Start a new draft to create the first tracker entry.'
                  : 'No grants matched “$searchQuery”. Try a broader search or clear the filters.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: grants.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final grant = grants[index];
                return _GrantListTile(
                  grant: grant,
                  selected: grant.id == selectedGrantId,
                  onTap: () => onSelectGrant(grant),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GrantEditorPanel extends StatelessWidget {
  const _GrantEditorPanel({
    required this.formKey,
    required this.selectedGrant,
    required this.saving,
    required this.draftStatus,
    required this.onStatusChanged,
    required this.grantNameController,
    required this.projectController,
    required this.fundingBodyController,
    required this.fundingTypeController,
    required this.amountRequestedController,
    required this.matchFundingController,
    required this.deadlineController,
    required this.priorityController,
    required this.ownerController,
    required this.nextActionController,
    required this.riskLevelController,
    required this.notesController,
    required this.tagsController,
    required this.submissionDateController,
    required this.decisionDateController,
    required this.projectSummaryController,
    required this.budgetController,
    required this.evidenceController,
    required this.partnerSupportController,
    required this.impactCaseController,
    required this.commercialPlanController,
    required this.riskManagementController,
    required this.onSave,
    required this.onOpenFolder,
    required this.onCopyFolderPath,
    required this.onRefreshFolder,
    required this.onExport,
    required this.onImport,
    required this.onStatusAction,
    required this.onPreviousGrant,
    required this.onNextGrant,
  });

  final GlobalKey<FormState> formKey;
  final GrantRecord? selectedGrant;
  final bool saving;
  final GrantStatus draftStatus;
  final ValueChanged<GrantStatus> onStatusChanged;
  final TextEditingController grantNameController;
  final TextEditingController projectController;
  final TextEditingController fundingBodyController;
  final TextEditingController fundingTypeController;
  final TextEditingController amountRequestedController;
  final TextEditingController matchFundingController;
  final TextEditingController deadlineController;
  final TextEditingController priorityController;
  final TextEditingController ownerController;
  final TextEditingController nextActionController;
  final TextEditingController riskLevelController;
  final TextEditingController notesController;
  final TextEditingController tagsController;
  final TextEditingController submissionDateController;
  final TextEditingController decisionDateController;
  final TextEditingController projectSummaryController;
  final TextEditingController budgetController;
  final TextEditingController evidenceController;
  final TextEditingController partnerSupportController;
  final TextEditingController impactCaseController;
  final TextEditingController commercialPlanController;
  final TextEditingController riskManagementController;
  final VoidCallback onSave;
  final VoidCallback onOpenFolder;
  final VoidCallback onCopyFolderPath;
  final VoidCallback onRefreshFolder;
  final VoidCallback? onExport;
  final VoidCallback? onImport;
  final Future<void> Function(GrantStatus status) onStatusAction;
  final VoidCallback? onPreviousGrant;
  final VoidCallback? onNextGrant;

  @override
  Widget build(BuildContext context) {
    final selected = selectedGrant;
    final readiness = selected?.readinessScore ?? const ReadinessScore(
      projectSummary: 0,
      budget: 0,
      evidence: 0,
      partnerSupport: 0,
      impactCase: 0,
      commercialPlan: 0,
      riskManagement: 0,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.edit_note_outlined,
                  color: AppColours.darkSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selected == null ? 'New grant draft' : 'Grant details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColours.darkText,
                        ),
                  ),
                ),
                if (selected != null) _StatusTag(status: selected.status),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Previous grant',
                  onPressed: onPreviousGrant,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Next grant',
                  onPressed: onNextGrant,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (selected != null) ...[
              _DetailRow(label: 'Folder', value: selected.folderPath),
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Readiness',
                value: '${readiness.total}/${readiness.max} - ${readiness.band}',
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(saving ? 'Saving...' : 'Save'),
                ),
                TextButton.icon(
                  onPressed: saving ? null : onOpenFolder,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Open / repair folder'),
                ),
                TextButton.icon(
                  onPressed: saving ? null : onCopyFolderPath,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy path'),
                ),
                TextButton.icon(
                  onPressed: saving ? null : onRefreshFolder,
                  icon: const Icon(Icons.sync_outlined),
                  label: const Text('Refresh folder'),
                ),
                TextButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.upload_outlined),
                  label: const Text('Export'),
                ),
                TextButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Import'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sectionTitle(context, 'Move status'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusActionButton(
                  label: 'Drafting',
                  onPressed: saving
                      ? null
                      : () => onStatusAction(GrantStatus.drafting),
                ),
                _StatusActionButton(
                  label: 'Researching',
                  onPressed: saving
                      ? null
                      : () => onStatusAction(GrantStatus.researching),
                ),
                _StatusActionButton(
                  label: 'Needs Partner',
                  onPressed: saving
                      ? null
                      : () => onStatusAction(GrantStatus.needsPartner),
                ),
                _StatusActionButton(
                  label: 'Ready',
                  onPressed: saving
                      ? null
                      : () => onStatusAction(GrantStatus.readyToSubmit),
                ),
                _StatusActionButton(
                  label: 'Submitted',
                  onPressed: saving
                      ? null
                      : () => onStatusAction(GrantStatus.submitted),
                ),
                _StatusActionButton(
                  label: 'Approved',
                  onPressed: saving
                      ? null
                      : () => onStatusAction(GrantStatus.approved),
                ),
                _StatusActionButton(
                  label: 'Paused',
                  onPressed: saving
                      ? null
                      : () => onStatusAction(GrantStatus.paused),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle(context, 'Core details'),
            const SizedBox(height: 10),
            _textField('Grant name', grantNameController, validator: _required),
            _textField('Project', projectController, validator: _required),
            _textField('Funding body', fundingBodyController),
            _textField('Funding type', fundingTypeController),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    'Amount requested',
                    amountRequestedController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _amountRequestedValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _textField('Match funding', matchFundingController)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<GrantStatus>(
                    initialValue: draftStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: GrantStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onStatusChanged(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _textField('Deadline', deadlineController)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _textField('Priority', priorityController)),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField('Owner', ownerController, validator: _required),
                ),
              ],
            ),
            _textField('Next action', nextActionController, maxLines: 3),
            _textField('Risk level', riskLevelController),
            _textField('Notes', notesController, maxLines: 4),
            _textField('Tags, comma separated', tagsController),
            Row(
              children: [
                Expanded(child: _textField('Submission date', submissionDateController)),
                const SizedBox(width: 12),
                Expanded(child: _textField('Decision date', decisionDateController)),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle(context, 'Readiness score'),
            const SizedBox(height: 10),
            _scoreGrid(),
            const SizedBox(height: 18),
            _sectionTitle(context, 'Status notes'),
            const SizedBox(height: 10),
            Text(
              selected == null
                  ? 'Create a new draft, then save it to generate the grant folder, tracker entry, and standard template pack.'
                  : 'Saving will keep the tracker updated and move the grant folder to the right Omega OS status area when needed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = [
          _scoreField('Project summary', projectSummaryController),
          _scoreField('Budget', budgetController),
          _scoreField('Evidence', evidenceController),
          _scoreField('Partner support', partnerSupportController),
          _scoreField('Impact case', impactCaseController),
          _scoreField('Commercial plan', commercialPlanController),
          _scoreField('Risk management', riskManagementController),
        ];

        if (constraints.maxWidth < 860) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                fields[index],
                if (index != fields.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: fields,
        );
      },
    );
  }

  Widget _scoreField(String label, TextEditingController controller) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: _readinessScoreValidator,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColours.darkText,
          ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _amountRequestedValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an amount';
    }

    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount should be greater than zero';
    }
    return null;
  }

  String? _readinessScoreValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final score = int.tryParse(value.trim());
    if (score == null) {
      return 'Use a whole number';
    }
    if (score < 0 || score > 10) {
      return 'Score must be 0 to 10';
    }
    return null;
  }
}

class _GrantListTile extends StatelessWidget {
  const _GrantListTile({
    required this.grant,
    required this.selected,
    required this.onTap,
  });

  final GrantRecord grant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final readiness = grant.readinessScore;
    final accent = _statusColor(grant.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColours.darkSurfaceRaised
              : AppColours.darkSurfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColours.darkSecondary : AppColours.darkOutline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    grant.grantName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColours.darkText,
                        ),
                  ),
                ),
                _StatusTag(status: grant.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              grant.project,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniTag(label: grant.priority),
                _MiniTag(label: _money(grant.amountRequested)),
                _MiniTag(label: '${readiness.total}/70'),
                if (grant.hasDeadline) _MiniTag(label: grant.deadline),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              grant.nextAction.isEmpty ? 'No next action yet.' : grant.nextAction,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkText,
                  ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: readiness.total / readiness.max,
                backgroundColor: AppColours.darkOutline,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final GrantStatus status;

  @override
  Widget build(BuildContext context) {
    final accent = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColours.darkText,
            ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? AppColours.darkBackground : AppColours.darkText,
            fontWeight: FontWeight.w700,
          ),
      selectedColor: AppColours.darkPrimary,
      backgroundColor: AppColours.darkSurfaceAlt,
      side: BorderSide(
        color: selected ? AppColours.darkPrimary : AppColours.darkOutline,
      ),
    );
  }
}

class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _CompactStatTile extends StatelessWidget {
  const _CompactStatTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Not set' : value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade200,
            ),
      ),
    );
  }
}

class FundingGrantsSummary {
  const FundingGrantsSummary({
    required this.totalGrants,
    required this.totalRequested,
    required this.readyCount,
    required this.submittedCount,
    required this.approvedCount,
    required this.pausedCount,
    required this.dueSoonCount,
    required this.missingNextActionsCount,
    required this.readinessAverage,
  });

  final int totalGrants;
  final double totalRequested;
  final int readyCount;
  final int submittedCount;
  final int approvedCount;
  final int pausedCount;
  final int dueSoonCount;
  final int missingNextActionsCount;
  final int readinessAverage;
}

enum GrantStatusFilter {
  all,
  drafting,
  attention,
  ready,
  submitted,
  approved,
  paused,
}

enum GrantSortMode {
  deadlineSoonest,
  readinessHighest,
  name,
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

Color _statusColor(GrantStatus status) {
  switch (status) {
    case GrantStatus.approved:
    case GrantStatus.reportingPhase:
    case GrantStatus.closed:
      return AppColours.darkSuccess;
    case GrantStatus.submitted:
    case GrantStatus.underReview:
      return AppColours.darkSecondary;
    case GrantStatus.rejected:
    case GrantStatus.paused:
      return Colors.redAccent;
    case GrantStatus.readyToSubmit:
      return AppColours.darkPrimary;
    case GrantStatus.needsBudget:
    case GrantStatus.needsEvidence:
    case GrantStatus.needsPartner:
      return AppColours.darkAmber;
    default:
      return AppColours.darkMutedText;
  }
}

String _money(double value) {
  return NumberFormat.currency(
    locale: 'en_GB',
    symbol: '\u00A3',
    decimalDigits: 0,
  ).format(value);
}
