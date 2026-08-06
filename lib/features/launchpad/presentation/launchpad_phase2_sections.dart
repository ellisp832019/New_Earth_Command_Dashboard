import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../application/launchpad_controller.dart';
import '../data/launchpad_calculator.dart';
import '../data/launchpad_models.dart';
import '../data/launchpad_phase2_models.dart';

class LaunchpadPhase2SectionView extends ConsumerWidget {
  const LaunchpadPhase2SectionView({
    required this.campaign,
    required this.workspace,
    required this.section,
    super.key,
  });

  final LaunchpadCampaignRecord campaign;
  final LaunchpadWorkspace workspace;
  final String section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (section == 'analytics') {
      return _LaunchpadAnalyticsPanel(
        campaign: campaign,
        workspace: workspace,
      );
    }

    if (section == 'launch-checklist') {
      return _LaunchChecklistPanel(campaign: campaign);
    }

    if (section == 'backer-updates') {
      return _BackerUpdatesPanel(campaign: campaign);
    }

    if (section == 'fulfilment-tracker') {
      return _FulfilmentTrackerPanel(campaign: campaign);
    }

    if (section == 'impact-tracker') {
      return _ImpactTrackerPanel(campaign: campaign);
    }

    final spec = _sectionSpec(section);
    final records = campaign.phase2Records
        .where((record) => record.section == section)
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHero(
          spec: spec,
          count: records.length,
          onAdd: () async {
            final draft = await showDialog<LaunchpadPhase2Record>(
              context: context,
              builder: (dialogContext) => _Phase2RecordDialog(
                campaignId: campaign.id,
                section: section,
                record: null,
                spec: spec,
                nextOrder: records.isEmpty
                    ? 0
                    : records.map((record) => record.order).reduce(
                        (value, element) => value > element ? value : element,
                      ) +
                        1,
              ),
            );

            if (draft == null) {
              return;
            }

            final updatedRecords = [...campaign.phase2Records, draft];
            updatedRecords.sort((a, b) => a.order.compareTo(b.order));
            await ref.read(launchpadRepositoryProvider).savePhase2Records(
              campaign.id,
              updatedRecords,
            );
            ref.invalidate(launchpadWorkspaceProvider);
          },
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          _EmptyPhase2State(
            title: 'No ${spec.pluralLabel.toLowerCase()} yet',
            body:
                'Add the first ${spec.singularLabel.toLowerCase()} to keep the section moving.',
          )
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _Phase2RecordCard(
                record: record,
                onEdit: () async {
                  final draft = await showDialog<LaunchpadPhase2Record>(
                    context: context,
                    builder: (dialogContext) => _Phase2RecordDialog(
                      campaignId: campaign.id,
                      section: section,
                      record: record,
                      spec: spec,
                      nextOrder: record.order,
                    ),
                  );

                  if (draft == null) {
                    return;
                  }

                  final updatedRecords = campaign.phase2Records
                      .map((item) => item.id == draft.id ? draft : item)
                      .toList(growable: false)
                    ..sort((a, b) => a.order.compareTo(b.order));
                  await ref.read(launchpadRepositoryProvider).savePhase2Records(
                    campaign.id,
                    updatedRecords,
                  );
                  ref.invalidate(launchpadWorkspaceProvider);
                },
                onDelete: () async {
                  final updatedRecords = campaign.phase2Records
                      .where((item) => item.id != record.id)
                      .toList(growable: false);
                  await ref.read(launchpadRepositoryProvider).savePhase2Records(
                    campaign.id,
                    updatedRecords,
                  );
                  ref.invalidate(launchpadWorkspaceProvider);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _LaunchpadAnalyticsPanel extends StatelessWidget {
  const _LaunchpadAnalyticsPanel({
    required this.campaign,
    required this.workspace,
  });

  final LaunchpadCampaignRecord campaign;
  final LaunchpadWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final readiness = calculateLaunchpadReadinessSummary(
      campaign.readinessItems,
    );
    final finance = calculateLaunchpadFinancialSummary(campaign);
    final phase2Count = campaign.phase2Records.length;

    final counts = <String, int>{
      'Media': campaign.phase2Records
          .where((record) => record.section == 'media-studio')
          .length,
      'Grants': campaign.phase2Records
          .where((record) => record.section == 'grant-centre')
          .length,
      'Investors': campaign.phase2Records
          .where((record) => record.section == 'investor-crm')
          .length,
      'Partners': campaign.phase2Records
          .where((record) => record.section == 'partner-crm')
          .length,
      'Manufacturing': campaign.phase2Records
          .where((record) => record.section == 'manufacturing-planner')
          .length,
      'Community': campaign.phase2Records
          .where((record) => record.section == 'community-builder')
          .length,
      'Timeline': campaign.phase2Records
          .where((record) => record.section == 'timeline-planner')
          .length,
      'Checklist': campaign.phase2Records
          .where((record) => record.section == 'launch-checklist')
          .length,
      'Updates': campaign.phase2Records
          .where((record) => record.section == 'backer-updates')
          .length,
      'Fulfilment': campaign.phase2Records
          .where((record) => record.section == 'fulfilment-tracker')
          .length,
      'Impact': campaign.phase2Records
          .where((record) => record.section == 'impact-tracker')
          .length,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHero(
          spec: _sectionSpec('analytics'),
          count: phase2Count,
          onAdd: null,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(label: 'Readiness', value: '${readiness.overallPercent.toStringAsFixed(0)}%'),
            _StatCard(label: 'Net funds', value: '£${finance.netAvailableFundsGbp.toStringAsFixed(0)}'),
            _StatCard(label: 'Campaigns', value: '${workspace.campaigns.length}'),
            _StatCard(label: 'Phase 2 records', value: '$phase2Count'),
          ],
        ),
        const SizedBox(height: 16),
        _DetailPanel(
          title: 'Operational snapshot',
          body:
              'Analytics stays local-first and practical: read the readiness trend, sanity-check the finances, and keep the launch scope visible.',
          children: counts.entries
              .map(
                (entry) => _MiniTag(
                  label: entry.key,
                  value: '${entry.value}',
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _LaunchChecklistPanel extends ConsumerWidget {
  const _LaunchChecklistPanel({
    required this.campaign,
  });

  final LaunchpadCampaignRecord campaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spec = _sectionSpec('launch-checklist');
    final records = campaign.phase2Records
        .where((record) => record.section == 'launch-checklist')
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));

    final doneCount = records.where(_isChecklistDone).length;
    final overdueCount = records.where(_isChecklistOverdue).length;
    final dueSoonCount = records.where(_isDueSoon).length;
    final progressPercent = records.isEmpty
        ? 0
        : (doneCount / records.length) * 100;

    Future<void> saveRecords(List<LaunchpadPhase2Record> updatedRecords) async {
      await ref.read(launchpadRepositoryProvider).savePhase2Records(
            campaign.id,
            updatedRecords,
          );
      ref.invalidate(launchpadWorkspaceProvider);
    }

    Future<void> addRecord() async {
      final nextOrder = records.isEmpty
          ? 0
          : records.map((record) => record.order).reduce(
                (value, element) => value > element ? value : element,
              ) +
              1;
      final draft = await showDialog<LaunchpadPhase2Record>(
        context: context,
        builder: (dialogContext) => _Phase2RecordDialog(
          campaignId: campaign.id,
          section: 'launch-checklist',
          record: null,
          spec: spec,
          nextOrder: nextOrder,
        ),
      );

      if (draft == null) {
        return;
      }

      final updatedRecords = [...campaign.phase2Records, draft]
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    Future<void> editRecord(LaunchpadPhase2Record record) async {
      final draft = await showDialog<LaunchpadPhase2Record>(
        context: context,
        builder: (dialogContext) => _Phase2RecordDialog(
          campaignId: campaign.id,
          section: 'launch-checklist',
          record: record,
          spec: spec,
          nextOrder: record.order,
        ),
      );

      if (draft == null) {
        return;
      }

      final updatedRecords = campaign.phase2Records
          .map((item) => item.id == draft.id ? draft : item)
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    Future<void> deleteRecord(LaunchpadPhase2Record record) async {
      final updatedRecords = campaign.phase2Records
          .where((item) => item.id != record.id)
          .toList(growable: false);
      await saveRecords(updatedRecords);
    }

    Future<void> toggleDone(LaunchpadPhase2Record record, bool checked) async {
      final updatedRecords = campaign.phase2Records
          .map(
            (item) => item.id == record.id
                ? item.copyWith(status: checked ? 'Done' : 'Planned')
                : item,
          )
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHero(
          spec: spec,
          count: records.length,
          onAdd: addRecord,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(
              label: 'Progress',
              value: '${progressPercent.toStringAsFixed(0)}%',
            ),
            _StatCard(
              label: 'Done',
              value: '$doneCount',
            ),
            _StatCard(
              label: 'Due soon',
              value: '$dueSoonCount',
            ),
            _StatCard(
              label: 'Overdue',
              value: '$overdueCount',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailPanel(
          title: 'Why this matters',
          body:
              'Use the checklist to keep launch tasks visible, mark items complete as they clear, and spot overdue work before it slows the campaign down.',
          children: [
            _MiniTag(label: 'Launch ready', value: '$doneCount / ${records.length}'),
            _MiniTag(label: 'Due soon', value: '$dueSoonCount'),
            _MiniTag(label: 'Overdue', value: '$overdueCount'),
          ],
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          _EmptyPhase2State(
            title: 'No checklist items yet',
            body:
                'Add the first launch task to start tracking what needs to be ready before launch day.',
          )
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChecklistRecordCard(
                record: record,
                onToggleDone: (checked) => toggleDone(record, checked),
                onEdit: () => editRecord(record),
                onDelete: () => deleteRecord(record),
              ),
            ),
          ),
      ],
    );
  }
}

class _BackerUpdatesPanel extends ConsumerWidget {
  const _BackerUpdatesPanel({
    required this.campaign,
  });

  final LaunchpadCampaignRecord campaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spec = _sectionSpec('backer-updates');
    final records = campaign.phase2Records
        .where((record) => record.section == 'backer-updates')
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));

    final draftCount = records.where((record) => _backerUpdateState(record) == 'draft').length;
    final scheduledCount = records.where((record) => _backerUpdateState(record) == 'scheduled').length;
    final sentCount = records.where((record) => _backerUpdateState(record) == 'sent').length;
    final dueSoonCount = records.where(_isChecklistDueSoon).length;
    final progressPercent = records.isEmpty ? 0 : (sentCount / records.length) * 100;

    Future<void> saveRecords(List<LaunchpadPhase2Record> updatedRecords) async {
      await ref.read(launchpadRepositoryProvider).savePhase2Records(
            campaign.id,
            updatedRecords,
          );
      ref.invalidate(launchpadWorkspaceProvider);
    }

    Future<void> addRecord() async {
      final nextOrder = records.isEmpty
          ? 0
          : records.map((record) => record.order).reduce(
                (value, element) => value > element ? value : element,
              ) +
              1;
      final draft = await showDialog<LaunchpadPhase2Record>(
        context: context,
        builder: (dialogContext) => _Phase2RecordDialog(
          campaignId: campaign.id,
          section: 'backer-updates',
          record: null,
          spec: spec,
          nextOrder: nextOrder,
        ),
      );

      if (draft == null) {
        return;
      }

      final updatedRecords = [...campaign.phase2Records, draft]
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    Future<void> editRecord(LaunchpadPhase2Record record) async {
      final draft = await showDialog<LaunchpadPhase2Record>(
        context: context,
        builder: (dialogContext) => _Phase2RecordDialog(
          campaignId: campaign.id,
          section: 'backer-updates',
          record: record,
          spec: spec,
          nextOrder: record.order,
        ),
      );

      if (draft == null) {
        return;
      }

      final updatedRecords = campaign.phase2Records
          .map((item) => item.id == draft.id ? draft : item)
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    Future<void> deleteRecord(LaunchpadPhase2Record record) async {
      final updatedRecords = campaign.phase2Records
          .where((item) => item.id != record.id)
          .toList(growable: false);
      await saveRecords(updatedRecords);
    }

    Future<void> setStatus(LaunchpadPhase2Record record, String status) async {
      final updatedRecords = campaign.phase2Records
          .map(
            (item) => item.id == record.id
                ? item.copyWith(status: status)
                : item,
          )
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHero(
          spec: spec,
          count: records.length,
          onAdd: addRecord,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(label: 'Draft', value: '$draftCount'),
            _StatCard(label: 'Scheduled', value: '$scheduledCount'),
            _StatCard(label: 'Sent', value: '$sentCount'),
            _StatCard(label: 'Due soon', value: '$dueSoonCount'),
            _StatCard(
              label: 'Progress',
              value: '${progressPercent.toStringAsFixed(0)}%',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailPanel(
          title: 'Backer communication',
          body:
              'Use this space to draft calm, transparent updates before launch and during the campaign so supporters always know what is happening next.',
          children: [
            _MiniTag(label: 'Audience', value: 'Backers'),
            _MiniTag(label: 'Tone', value: 'Calm, clear'),
            _MiniTag(label: 'Status', value: '$sentCount sent'),
          ],
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          _EmptyPhase2State(
            title: 'No backer updates yet',
            body:
                'Add the first update draft so you can shape the launch story before the campaign opens.',
          )
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BackerUpdateCard(
                record: record,
                onEdit: () => editRecord(record),
                onDelete: () => deleteRecord(record),
                onSetDraft: () => setStatus(record, 'Draft'),
                onSetScheduled: () => setStatus(record, 'Scheduled'),
                onSetSent: () => setStatus(record, 'Sent'),
              ),
            ),
          ),
      ],
    );
  }
}

class _FulfilmentTrackerPanel extends ConsumerWidget {
  const _FulfilmentTrackerPanel({
    required this.campaign,
  });

  final LaunchpadCampaignRecord campaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spec = _sectionSpec('fulfilment-tracker');
    final records = campaign.phase2Records
        .where((record) => record.section == 'fulfilment-tracker')
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));

    final planningCount = records.where((record) => _fulfilmentState(record) == 'planning').length;
    final packedCount = records.where((record) => _fulfilmentState(record) == 'packed').length;
    final shippedCount = records.where((record) => _fulfilmentState(record) == 'shipped').length;
    final deliveredCount = records.where((record) => _fulfilmentState(record) == 'delivered').length;
    final overdueCount = records.where(_isOverdue).length;
    final progressPercent = records.isEmpty ? 0 : (deliveredCount / records.length) * 100;

    Future<void> saveRecords(List<LaunchpadPhase2Record> updatedRecords) async {
      await ref.read(launchpadRepositoryProvider).savePhase2Records(
            campaign.id,
            updatedRecords,
          );
      ref.invalidate(launchpadWorkspaceProvider);
    }

    Future<void> addRecord() async {
      final nextOrder = records.isEmpty
          ? 0
          : records.map((record) => record.order).reduce(
                (value, element) => value > element ? value : element,
              ) +
              1;
      final draft = await showDialog<LaunchpadPhase2Record>(
        context: context,
        builder: (dialogContext) => _Phase2RecordDialog(
          campaignId: campaign.id,
          section: 'fulfilment-tracker',
          record: null,
          spec: spec,
          nextOrder: nextOrder,
        ),
      );

      if (draft == null) {
        return;
      }

      final updatedRecords = [...campaign.phase2Records, draft]
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    Future<void> editRecord(LaunchpadPhase2Record record) async {
      final draft = await showDialog<LaunchpadPhase2Record>(
        context: context,
        builder: (dialogContext) => _Phase2RecordDialog(
          campaignId: campaign.id,
          section: 'fulfilment-tracker',
          record: record,
          spec: spec,
          nextOrder: record.order,
        ),
      );

      if (draft == null) {
        return;
      }

      final updatedRecords = campaign.phase2Records
          .map((item) => item.id == draft.id ? draft : item)
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    Future<void> deleteRecord(LaunchpadPhase2Record record) async {
      final updatedRecords = campaign.phase2Records
          .where((item) => item.id != record.id)
          .toList(growable: false);
      await saveRecords(updatedRecords);
    }

    Future<void> setStatus(LaunchpadPhase2Record record, String status) async {
      final updatedRecords = campaign.phase2Records
          .map(
            (item) => item.id == record.id
                ? item.copyWith(status: status)
                : item,
          )
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHero(
          spec: spec,
          count: records.length,
          onAdd: addRecord,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(label: 'Planning', value: '$planningCount'),
            _StatCard(label: 'Packed', value: '$packedCount'),
            _StatCard(label: 'Shipped', value: '$shippedCount'),
            _StatCard(label: 'Delivered', value: '$deliveredCount'),
            _StatCard(label: 'Overdue', value: '$overdueCount'),
            _StatCard(
              label: 'Progress',
              value: '${progressPercent.toStringAsFixed(0)}%',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailPanel(
          title: 'Fulfilment plan',
          body:
              'Map the first shipment wave carefully, keep the volume realistic, and make the delivery path visible before the campaign scales up.',
          children: [
            _MiniTag(label: 'Batch flow', value: 'Plan -> Pack -> Ship -> Deliver'),
            _MiniTag(label: 'Focus', value: 'Starter kits'),
            _MiniTag(label: 'Risk', value: '$overdueCount overdue'),
          ],
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          _EmptyPhase2State(
            title: 'No fulfilment batches yet',
            body:
                'Add the first batch record so the delivery plan stays grounded in the actual campaign scope.',
          )
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FulfilmentRecordCard(
                record: record,
                onEdit: () => editRecord(record),
                onDelete: () => deleteRecord(record),
                onSetPlanning: () => setStatus(record, 'Planning'),
                onSetPacked: () => setStatus(record, 'Packed'),
                onSetShipped: () => setStatus(record, 'Shipped'),
                onSetDelivered: () => setStatus(record, 'Delivered'),
              ),
            ),
          ),
      ],
    );
  }
}

class _ImpactTrackerPanel extends ConsumerWidget {
  const _ImpactTrackerPanel({
    required this.campaign,
  });

  final LaunchpadCampaignRecord campaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spec = _sectionSpec('impact-tracker');
    final records = campaign.phase2Records
        .where((record) => record.section == 'impact-tracker')
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));

    final draftCount = records.where((record) => _impactState(record) == 'draft').length;
    final trackedCount = records.where((record) => _impactState(record) == 'tracked').length;
    final validatedCount = records.where((record) => _impactState(record) == 'validated').length;
    final reportedCount = records.where((record) => _impactState(record) == 'reported').length;
    final progressPercent = records.isEmpty ? 0 : (reportedCount / records.length) * 100;

    Future<void> saveRecords(List<LaunchpadPhase2Record> updatedRecords) async {
      await ref.read(launchpadRepositoryProvider).savePhase2Records(
            campaign.id,
            updatedRecords,
          );
      ref.invalidate(launchpadWorkspaceProvider);
    }

    Future<void> addRecord() async {
      final nextOrder = records.isEmpty
          ? 0
          : records.map((record) => record.order).reduce(
                (value, element) => value > element ? value : element,
              ) +
              1;
      final draft = await showDialog<LaunchpadPhase2Record>(
        context: context,
        builder: (dialogContext) => _Phase2RecordDialog(
          campaignId: campaign.id,
          section: 'impact-tracker',
          record: null,
          spec: spec,
          nextOrder: nextOrder,
        ),
      );

      if (draft == null) {
        return;
      }

      final updatedRecords = [...campaign.phase2Records, draft]
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    Future<void> editRecord(LaunchpadPhase2Record record) async {
      final draft = await showDialog<LaunchpadPhase2Record>(
        context: context,
        builder: (dialogContext) => _Phase2RecordDialog(
          campaignId: campaign.id,
          section: 'impact-tracker',
          record: record,
          spec: spec,
          nextOrder: record.order,
        ),
      );

      if (draft == null) {
        return;
      }

      final updatedRecords = campaign.phase2Records
          .map((item) => item.id == draft.id ? draft : item)
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    Future<void> deleteRecord(LaunchpadPhase2Record record) async {
      final updatedRecords = campaign.phase2Records
          .where((item) => item.id != record.id)
          .toList(growable: false);
      await saveRecords(updatedRecords);
    }

    Future<void> setStatus(LaunchpadPhase2Record record, String status) async {
      final updatedRecords = campaign.phase2Records
          .map(
            (item) => item.id == record.id
                ? item.copyWith(status: status)
                : item,
          )
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));
      await saveRecords(updatedRecords);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHero(
          spec: spec,
          count: records.length,
          onAdd: addRecord,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(label: 'Draft', value: '$draftCount'),
            _StatCard(label: 'Tracked', value: '$trackedCount'),
            _StatCard(label: 'Validated', value: '$validatedCount'),
            _StatCard(label: 'Reported', value: '$reportedCount'),
            _StatCard(
              label: 'Progress',
              value: '${progressPercent.toStringAsFixed(0)}%',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailPanel(
          title: 'Impact baseline',
          body:
              'Keep the mission outcome visible so the campaign reports on what changed, not just what was delivered.',
          children: [
            _MiniTag(label: 'Measure', value: 'Community resilience'),
            _MiniTag(label: 'Review', value: 'Post-campaign'),
            _MiniTag(label: 'Focus', value: 'Local impact'),
          ],
        ),
        const SizedBox(height: 16),
        if (records.isEmpty)
          _EmptyPhase2State(
            title: 'No impact metrics yet',
            body:
                'Add the first impact baseline so the campaign can measure outcomes after delivery.',
          )
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ImpactRecordCard(
                record: record,
                onEdit: () => editRecord(record),
                onDelete: () => deleteRecord(record),
                onSetDraft: () => setStatus(record, 'Draft'),
                onSetTracked: () => setStatus(record, 'Tracked'),
                onSetValidated: () => setStatus(record, 'Validated'),
                onSetReported: () => setStatus(record, 'Reported'),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHero extends StatelessWidget {
  const _SectionHero({
    required this.spec,
    required this.count,
    required this.onAdd,
  });

  final _Phase2SectionSpec spec;
  final int count;
  final Future<void> Function()? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context, highlighted: true),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColours.darkPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(spec.icon, color: AppColours.darkPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  spec.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$count ${count == 1 ? spec.singularLabel : spec.pluralLabel} tracked',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onAdd != null)
            FilledButton.icon(
              onPressed: () => onAdd!.call(),
              icon: const Icon(Icons.add),
              label: Text('Add ${spec.singularLabel}'),
            ),
        ],
      ),
    );
  }
}

class _Phase2RecordCard extends StatelessWidget {
  const _Phase2RecordCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final LaunchpadPhase2Record record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dueDateLabel = record.dueDate == null
        ? 'No due date'
        : DateFormat('d MMM y').format(record.dueDate!.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _Chip(label: record.status, accent: AppColours.darkPrimary),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(label: '${record.primaryLabel}: ${record.primaryValue}'),
              _Chip(label: '${record.secondaryLabel}: ${record.secondaryValue}'),
              _Chip(label: dueDateLabel, accent: AppColours.darkSecondary),
            ],
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              record.notes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChecklistRecordCard extends StatelessWidget {
  const _ChecklistRecordCard({
    required this.record,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  final LaunchpadPhase2Record record;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDone = _isChecklistDone(record);
    final isOverdue = _isChecklistOverdue(record);
    final dueDateLabel = record.dueDate == null
        ? 'No due date'
        : DateFormat('d MMM y').format(record.dueDate!.toLocal());
    final accent = isDone
        ? AppColours.darkSuccess
        : isOverdue
            ? AppColours.darkAmber
            : AppColours.darkPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isDone,
                onChanged: (value) => onToggleDone(value ?? false),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _Chip(label: isDone ? 'Done' : 'Open', accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(label: '${record.primaryLabel}: ${record.primaryValue}'),
              _Chip(label: '${record.secondaryLabel}: ${record.secondaryValue}'),
              _Chip(label: dueDateLabel, accent: AppColours.darkSecondary),
              if (isOverdue)
                _Chip(label: 'Overdue', accent: AppColours.darkAmber),
            ],
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              record.notes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackerUpdateCard extends StatelessWidget {
  const _BackerUpdateCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDraft,
    required this.onSetScheduled,
    required this.onSetSent,
  });

  final LaunchpadPhase2Record record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDraft;
  final VoidCallback onSetScheduled;
  final VoidCallback onSetSent;

  @override
  Widget build(BuildContext context) {
    final state = _backerUpdateState(record);
    final dueDateLabel = record.dueDate == null
        ? 'No send date'
        : DateFormat('d MMM y').format(record.dueDate!.toLocal());
    final accent = state == 'sent'
        ? AppColours.darkSuccess
        : state == 'scheduled'
            ? AppColours.darkPrimary
            : AppColours.darkSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _Chip(label: _titleCase(state), accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(label: '${record.primaryLabel}: ${record.primaryValue}'),
              _Chip(label: '${record.secondaryLabel}: ${record.secondaryValue}'),
              _Chip(label: dueDateLabel, accent: AppColours.darkSecondary),
            ],
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              record.notes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton(
                onPressed: onSetDraft,
                child: const Text('Draft'),
              ),
              OutlinedButton(
                onPressed: onSetScheduled,
                child: const Text('Scheduled'),
              ),
              FilledButton.tonal(
                onPressed: onSetSent,
                child: const Text('Mark Sent'),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FulfilmentRecordCard extends StatelessWidget {
  const _FulfilmentRecordCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPlanning,
    required this.onSetPacked,
    required this.onSetShipped,
    required this.onSetDelivered,
  });

  final LaunchpadPhase2Record record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPlanning;
  final VoidCallback onSetPacked;
  final VoidCallback onSetShipped;
  final VoidCallback onSetDelivered;

  @override
  Widget build(BuildContext context) {
    final state = _fulfilmentState(record);
    final dueDateLabel = record.dueDate == null
        ? 'No target date'
        : DateFormat('d MMM y').format(record.dueDate!.toLocal());
    final accent = state == 'delivered'
        ? AppColours.darkSuccess
        : state == 'shipped'
            ? AppColours.darkPrimary
            : state == 'packed'
                ? AppColours.darkSecondary
                : AppColours.darkAmber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _Chip(label: _titleCase(state), accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(label: '${record.primaryLabel}: ${record.primaryValue}'),
              _Chip(label: '${record.secondaryLabel}: ${record.secondaryValue}'),
              _Chip(label: dueDateLabel, accent: AppColours.darkSecondary),
              if (_isOverdue(record))
                _Chip(label: 'Overdue', accent: AppColours.darkAmber),
            ],
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              record.notes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton(
                onPressed: onSetPlanning,
                child: const Text('Planning'),
              ),
              OutlinedButton(
                onPressed: onSetPacked,
                child: const Text('Packed'),
              ),
              OutlinedButton(
                onPressed: onSetShipped,
                child: const Text('Shipped'),
              ),
              FilledButton.tonal(
                onPressed: onSetDelivered,
                child: const Text('Delivered'),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactRecordCard extends StatelessWidget {
  const _ImpactRecordCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDraft,
    required this.onSetTracked,
    required this.onSetValidated,
    required this.onSetReported,
  });

  final LaunchpadPhase2Record record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDraft;
  final VoidCallback onSetTracked;
  final VoidCallback onSetValidated;
  final VoidCallback onSetReported;

  @override
  Widget build(BuildContext context) {
    final state = _impactState(record);
    final dueDateLabel = record.dueDate == null
        ? 'No review date'
        : DateFormat('d MMM y').format(record.dueDate!.toLocal());
    final accent = state == 'reported'
        ? AppColours.darkSuccess
        : state == 'validated'
            ? AppColours.darkPrimary
            : state == 'tracked'
                ? AppColours.darkSecondary
                : AppColours.darkAmber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _Chip(label: _titleCase(state), accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(label: '${record.primaryLabel}: ${record.primaryValue}'),
              _Chip(label: '${record.secondaryLabel}: ${record.secondaryValue}'),
              _Chip(label: dueDateLabel, accent: AppColours.darkSecondary),
            ],
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              record.notes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton(
                onPressed: onSetDraft,
                child: const Text('Draft'),
              ),
              OutlinedButton(
                onPressed: onSetTracked,
                child: const Text('Tracked'),
              ),
              OutlinedButton(
                onPressed: onSetValidated,
                child: const Text('Validated'),
              ),
              FilledButton.tonal(
                onPressed: onSetReported,
                child: const Text('Reported'),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPhase2State extends StatelessWidget {
  const _EmptyPhase2State({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _Phase2RecordDialog extends StatefulWidget {
  const _Phase2RecordDialog({
    required this.campaignId,
    required this.section,
    required this.record,
    required this.spec,
    required this.nextOrder,
  });

  final String campaignId;
  final String section;
  final LaunchpadPhase2Record? record;
  final _Phase2SectionSpec spec;
  final int nextOrder;

  @override
  State<_Phase2RecordDialog> createState() => _Phase2RecordDialogState();
}

class _Phase2RecordDialogState extends State<_Phase2RecordDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _statusController;
  late final TextEditingController _primaryLabelController;
  late final TextEditingController _primaryValueController;
  late final TextEditingController _secondaryLabelController;
  late final TextEditingController _secondaryValueController;
  late final TextEditingController _notesController;
  late final TextEditingController _dueDateController;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _titleController = TextEditingController(text: record?.title ?? '');
    _statusController = TextEditingController(text: record?.status ?? 'Draft');
    _primaryLabelController = TextEditingController(
      text: record?.primaryLabel ?? widget.spec.primaryLabel,
    );
    _primaryValueController = TextEditingController(
      text: record?.primaryValue ?? '',
    );
    _secondaryLabelController = TextEditingController(
      text: record?.secondaryLabel ?? widget.spec.secondaryLabel,
    );
    _secondaryValueController = TextEditingController(
      text: record?.secondaryValue ?? '',
    );
    _notesController = TextEditingController(text: record?.notes ?? '');
    _dueDateController = TextEditingController(
      text: record?.dueDate == null
          ? ''
          : DateFormat('yyyy-MM-dd').format(record!.dueDate!.toLocal()),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _statusController.dispose();
    _primaryLabelController.dispose();
    _primaryValueController.dispose();
    _secondaryLabelController.dispose();
    _secondaryValueController.dispose();
    _notesController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit ${widget.spec.singularLabel}' : 'Add ${widget.spec.singularLabel}'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _primaryLabelController,
                decoration: const InputDecoration(labelText: 'Primary label'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _primaryValueController,
                decoration: const InputDecoration(labelText: 'Primary value'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _secondaryLabelController,
                decoration: const InputDecoration(labelText: 'Secondary label'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _secondaryValueController,
                decoration: const InputDecoration(labelText: 'Secondary value'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due date (yyyy-MM-dd)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final record = LaunchpadPhase2Record(
              id: widget.record?.id ??
                  'phase2-${widget.section}-${DateTime.now().millisecondsSinceEpoch}',
              campaignId: widget.record?.campaignId ?? widget.campaignId,
              section: widget.section,
              title: _titleController.text.trim(),
              status: _statusController.text.trim().isEmpty
                  ? 'Draft'
                  : _statusController.text.trim(),
              primaryLabel: _primaryLabelController.text.trim().isEmpty
                  ? widget.spec.primaryLabel
                  : _primaryLabelController.text.trim(),
              primaryValue: _primaryValueController.text.trim(),
              secondaryLabel: _secondaryLabelController.text.trim().isEmpty
                  ? widget.spec.secondaryLabel
                  : _secondaryLabelController.text.trim(),
              secondaryValue: _secondaryValueController.text.trim(),
              notes: _notesController.text.trim(),
              order: widget.record?.order ?? widget.nextOrder,
              dueDate: _parseDate(_dueDateController.text),
            );
            Navigator.of(context).pop(record);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

bool _isChecklistDone(LaunchpadPhase2Record record) {
  return record.status.trim().toLowerCase() == 'done';
}

bool _isOverdue(LaunchpadPhase2Record record) {
  if (_isChecklistDone(record) || record.dueDate == null) {
    return false;
  }

  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  final dueDate = DateTime(
    record.dueDate!.year,
    record.dueDate!.month,
    record.dueDate!.day,
  );

  return dueDate.isBefore(startOfToday);
}

bool _isDueSoon(LaunchpadPhase2Record record) {
  if (_isChecklistDone(record) || record.dueDate == null) {
    return false;
  }

  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  final dueDate = DateTime(
    record.dueDate!.year,
    record.dueDate!.month,
    record.dueDate!.day,
  );
  final difference = dueDate.difference(startOfToday).inDays;

  return difference >= 0 && difference <= 7;
}

bool _isChecklistOverdue(LaunchpadPhase2Record record) => _isOverdue(record);

bool _isChecklistDueSoon(LaunchpadPhase2Record record) => _isDueSoon(record);

String _backerUpdateState(LaunchpadPhase2Record record) {
  final status = record.status.trim().toLowerCase();
  if (status.contains('sent') || status.contains('published') || status.contains('live')) {
    return 'sent';
  }
  if (status.contains('sched') || status.contains('ready')) {
    return 'scheduled';
  }
  return 'draft';
}

String _fulfilmentState(LaunchpadPhase2Record record) {
  final status = record.status.trim().toLowerCase();
  if (status.contains('deliver') || status.contains('complete')) {
    return 'delivered';
  }
  if (status.contains('ship') || status.contains('sent') || status.contains('dispatch')) {
    return 'shipped';
  }
  if (status.contains('pack') || status.contains('ready')) {
    return 'packed';
  }
  return 'planning';
}

String _impactState(LaunchpadPhase2Record record) {
  final status = record.status.trim().toLowerCase();
  if (status.contains('report') || status.contains('published') || status.contains('done')) {
    return 'reported';
  }
  if (status.contains('validat') || status.contains('reviewed')) {
    return 'validated';
  }
  if (status.contains('track') || status.contains('progress')) {
    return 'tracked';
  }
  return 'draft';
}

String _titleCase(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value[0].toUpperCase() + value.substring(1);
}

class _Phase2SectionSpec {
  const _Phase2SectionSpec({
    required this.title,
    required this.subtitle,
    required this.singularLabel,
    required this.pluralLabel,
    required this.icon,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final String title;
  final String subtitle;
  final String singularLabel;
  final String pluralLabel;
  final IconData icon;
  final String primaryLabel;
  final String secondaryLabel;
}

_Phase2SectionSpec _sectionSpec(String section) {
  switch (section) {
    case 'media-studio':
      return const _Phase2SectionSpec(
        title: 'Media Studio',
        subtitle: 'Track the proof assets that make the campaign feel real and honest.',
        singularLabel: 'Asset',
        pluralLabel: 'Assets',
        icon: Icons.perm_media,
        primaryLabel: 'Asset type',
        secondaryLabel: 'Source',
      );
    case 'manufacturing-planner':
      return const _Phase2SectionSpec(
        title: 'Manufacturing Planner',
        subtitle: 'Keep supplier quotes, lead times, and production notes in one calm place.',
        singularLabel: 'Quote',
        pluralLabel: 'Quotes',
        icon: Icons.precision_manufacturing,
        primaryLabel: 'Supplier',
        secondaryLabel: 'Lead time',
      );
    case 'community-builder':
      return const _Phase2SectionSpec(
        title: 'Community Builder',
        subtitle: 'Shape the supporters, channels, and early circles around the launch.',
        singularLabel: 'Entry',
        pluralLabel: 'Entries',
        icon: Icons.groups,
        primaryLabel: 'Channel',
        secondaryLabel: 'Audience',
      );
    case 'grant-centre':
      return const _Phase2SectionSpec(
        title: 'Grant Centre',
        subtitle: 'Keep grant opportunities visible, realistic, and easy to review.',
        singularLabel: 'Grant',
        pluralLabel: 'Grants',
        icon: Icons.request_page,
        primaryLabel: 'Funder',
        secondaryLabel: 'Deadline',
      );
    case 'investor-crm':
      return const _Phase2SectionSpec(
        title: 'Investor CRM',
        subtitle: 'Track conversations, interest, and next actions without the noise.',
        singularLabel: 'Contact',
        pluralLabel: 'Contacts',
        icon: Icons.people,
        primaryLabel: 'Organisation',
        secondaryLabel: 'Next step',
      );
    case 'partner-crm':
      return const _Phase2SectionSpec(
        title: 'Partner CRM',
        subtitle: 'Keep partner pilots and collaboration ideas open, practical, and clear.',
        singularLabel: 'Partner',
        pluralLabel: 'Partners',
        icon: Icons.handshake,
        primaryLabel: 'Partner type',
        secondaryLabel: 'Next step',
      );
    case 'timeline-planner':
      return const _Phase2SectionSpec(
        title: 'Timeline Planner',
        subtitle: 'Sequence the campaign work so launch day never feels chaotic.',
        singularLabel: 'Milestone',
        pluralLabel: 'Milestones',
        icon: Icons.timeline,
        primaryLabel: 'Phase',
        secondaryLabel: 'Target',
      );
    case 'analytics':
      return const _Phase2SectionSpec(
        title: 'Analytics',
        subtitle: 'Read the launch at a glance using local, mission-first signals.',
        singularLabel: 'Metric',
        pluralLabel: 'Metrics',
        icon: Icons.query_stats,
        primaryLabel: 'Metric',
        secondaryLabel: 'Trend',
      );
    case 'launch-checklist':
      return const _Phase2SectionSpec(
        title: 'Launch Checklist',
        subtitle: 'Keep the pre-launch tasks visible so nothing important is missed.',
        singularLabel: 'Task',
        pluralLabel: 'Tasks',
        icon: Icons.fact_check,
        primaryLabel: 'Area',
        secondaryLabel: 'Due',
      );
    case 'backer-updates':
      return const _Phase2SectionSpec(
        title: 'Backer Updates',
        subtitle: 'Draft the messages that keep supporters informed and confident.',
        singularLabel: 'Update',
        pluralLabel: 'Updates',
        icon: Icons.campaign,
        primaryLabel: 'Audience',
        secondaryLabel: 'Tone',
      );
    case 'fulfilment-tracker':
      return const _Phase2SectionSpec(
        title: 'Fulfilment Tracker',
        subtitle: 'Track batches, shipments, and the delivery path with care.',
        singularLabel: 'Batch',
        pluralLabel: 'Batches',
        icon: Icons.local_shipping,
        primaryLabel: 'Batch',
        secondaryLabel: 'Status',
      );
    case 'impact-tracker':
      return const _Phase2SectionSpec(
        title: 'Impact Tracker',
        subtitle: 'Hold the mission outcome in view after the campaign is delivered.',
        singularLabel: 'Metric',
        pluralLabel: 'Metrics',
        icon: Icons.insights,
        primaryLabel: 'Measure',
        secondaryLabel: 'Review',
      );
    default:
      return const _Phase2SectionSpec(
        title: 'Launchpad',
        subtitle: 'Phase 2 launch operations stay local-first and easy to review.',
        singularLabel: 'Item',
        pluralLabel: 'Items',
        icon: Icons.dashboard,
        primaryLabel: 'Label',
        secondaryLabel: 'Value',
      );
  }
}

BoxDecoration _panelDecoration(
  BuildContext context, {
  bool highlighted = false,
}) {
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

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: children),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
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

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColours.darkText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.accent = AppColours.darkSecondary,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

DateTime? _parseDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return DateTime.tryParse(trimmed);
}
