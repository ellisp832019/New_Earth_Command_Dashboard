import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/voice_module_providers.dart';
import '../application/voice_session_controller.dart';
import '../application/voice_thread_controller.dart';
import '../data/voice_assistant_service.dart';
import '../data/voice_audit_logger.dart';
import '../data/voice_models.dart';
import 'voice_thread_summary_strip.dart';
import '../../voice_assistant/application/voice_session_controller.dart'
    as legacy_session;

enum VoiceModuleSection {
  home,
  notes,
  meetings,
  assistant,
  microgrow,
  audit,
  settings,
}

extension VoiceModuleSectionX on VoiceModuleSection {
  String get title => switch (this) {
    VoiceModuleSection.home => 'Voice Home',
    VoiceModuleSection.notes => 'Voice Notes',
    VoiceModuleSection.meetings => 'Meeting Transcriber',
    VoiceModuleSection.assistant => 'Dashboard Assistant',
    VoiceModuleSection.microgrow => 'MicroGrow Voice Status',
    VoiceModuleSection.audit => 'Voice Audit Log',
    VoiceModuleSection.settings => 'Voice Settings',
  };

  String get route => switch (this) {
    VoiceModuleSection.home => RouteNames.voiceHome(),
    VoiceModuleSection.notes => RouteNames.voiceNotes,
    VoiceModuleSection.meetings => RouteNames.voiceMeetings,
    VoiceModuleSection.assistant => RouteNames.voiceDashboardAssistant,
    VoiceModuleSection.microgrow => RouteNames.voiceMicrogrow,
    VoiceModuleSection.audit => RouteNames.voiceAudit,
    VoiceModuleSection.settings => RouteNames.voiceSettings,
  };

  IconData get icon => switch (this) {
    VoiceModuleSection.home => Icons.home_outlined,
    VoiceModuleSection.notes => Icons.note_alt_outlined,
    VoiceModuleSection.meetings => Icons.meeting_room_outlined,
    VoiceModuleSection.assistant => Icons.smart_toy_outlined,
    VoiceModuleSection.microgrow => Icons.spa_outlined,
    VoiceModuleSection.audit => Icons.receipt_long_outlined,
    VoiceModuleSection.settings => Icons.settings_outlined,
  };
}

class VoiceModuleScreen extends ConsumerWidget {
  const VoiceModuleScreen({super.key, required this.section});

  final VoiceModuleSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(voiceSessionControllerProvider);
    final legacyVoiceSession = ref.watch(legacy_session.voiceSessionProvider);

    return WorkspaceShell(
      title: section.title,
      subtitle: 'Voice module workspace',
      onBack: () {
        if (context.canPop()) {
          context.pop();
          return;
        }

        context.go(
          section == VoiceModuleSection.home
              ? RouteNames.dashboard
              : RouteNames.voiceHome(),
        );
      },
      trailingActions: [
        TextButton.icon(
          onPressed: () => context.go(RouteNames.voiceConversation),
          icon: const Icon(Icons.forum_outlined),
          label: const Text('Conversation'),
        ),
      ],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModuleHero(section: section, session: session),
              const SizedBox(height: 16),
              VoiceThreadSummaryStrip(
                thread: ref.watch(voiceConversationThreadProvider),
              ),
              const SizedBox(height: 16),
              _SharedVoiceSessionBanner(
                session: legacyVoiceSession,
                thread: ref.watch(voiceConversationThreadProvider),
              ),
              const SizedBox(height: 16),
              if (session.recordingActive) ...[
                _RecordingBanner(session: session),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1120;
                    final navigation = _VoiceSectionNavigation(
                      section: section,
                      isWide: isWide,
                    );
                    final content = _VoiceSectionBody(section: section);

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 260, child: navigation),
                          const SizedBox(width: 16),
                          Expanded(child: content),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        navigation,
                        const SizedBox(height: 16),
                        Expanded(child: content),
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
}

class _ModuleHero extends StatelessWidget {
  const _ModuleHero({required this.section, required this.session});

  final VoiceModuleSection section;
  final VoiceSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = switch (section) {
      VoiceModuleSection.home =>
        'A local-first voice module with safe defaults, audit logging, and read-only MicroGrow status.',
      VoiceModuleSection.notes =>
        'Capture a note, review the transcript, and save it locally when it feels ready.',
      VoiceModuleSection.meetings =>
        'Paste a meeting transcript and shape it into decisions, actions, risks, and follow-ups.',
      VoiceModuleSection.assistant =>
        'Ask the dashboard a question and preview a safe response before any future AI wiring.',
      VoiceModuleSection.microgrow =>
        'Read MicroGrow status only. Hardware writes stay blocked by the safety gateway.',
      VoiceModuleSection.audit =>
        'Review the voice intents processed during this session.',
      VoiceModuleSection.settings =>
        'Adjust feature flags and provider mode without exposing secret keys in the app.',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout = constraints.maxWidth >= 760;

        final iconBlock = Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColours.darkSecondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColours.darkSecondary.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(section.icon, color: AppColours.darkSecondary),
        );

        final textBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColours.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              session.recordingActive
                  ? 'Recording is active.'
                  : 'Recording stays idle until you start it.',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.2,
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _panelDecoration(),
          child: useWideLayout
              ? Row(
                  children: [
                    iconBlock,
                    const SizedBox(width: 16),
                    Expanded(child: textBlock),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        iconBlock,
                        const SizedBox(width: 16),
                        Expanded(child: textBlock),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _RecordingBanner extends StatelessWidget {
  const _RecordingBanner({required this.session});

  final VoiceSessionState session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSuccess.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkSuccess.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fiber_manual_record,
            color: AppColours.darkSuccess,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              session.recordingLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedVoiceSessionBanner extends StatelessWidget {
  const _SharedVoiceSessionBanner({
    required this.session,
    required this.thread,
  });

  final legacy_session.VoiceSessionState session;
  final VoiceConversationThreadState thread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _legacySessionAccent(session);
    final isActive = session.isActive;

    final label = isActive
        ? '${session.owner.displayLabel} · ${session.phase.displayLabel}'
        : 'Shared voice session idle';
    final detail = isActive
        ? 'The same calm voice session now carries the dashboard conversation.'
        : thread.threadTitle == 'No thread yet'
        ? 'Open a voice page to start the shared thread.'
        : 'The shared thread is saved and ready to resume.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.graphic_eq_outlined : Icons.forum_outlined,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceSectionNavigation extends StatelessWidget {
  const _VoiceSectionNavigation({required this.section, required this.isWide});

  final VoiceModuleSection section;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final items = VoiceModuleSection.values
        .map(
          (candidate) => _VoiceNavButton(
            label: candidate.title,
            icon: candidate.icon,
            selected: candidate == section,
            onTap: () => context.go(candidate.route),
          ),
        )
        .toList(growable: false);

    if (!isWide) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              SizedBox(width: index == 0 ? 0 : 10),
              SizedBox(width: 210, child: items[index]),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Voice Module',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < items.length; index++) ...[
              items[index],
              if (index != items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _VoiceNavButton extends StatelessWidget {
  const _VoiceNavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected
        ? AppColours.darkSecondary
        : AppColours.darkMutedText;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColours.darkSurfaceRaised.withValues(alpha: 0.98)
                : AppColours.darkSurface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColours.darkSecondary.withValues(alpha: 0.32)
                  : AppColours.darkOutline,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceSectionBody extends StatelessWidget {
  const _VoiceSectionBody({required this.section});

  final VoiceModuleSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: _sectionBuilder(),
    );
  }

  Widget _sectionBuilder() {
    return switch (section) {
      VoiceModuleSection.home => const _VoiceHomePage(),
      VoiceModuleSection.notes => const _VoiceNotesPage(),
      VoiceModuleSection.meetings => const _VoiceMeetingTranscriberPage(),
      VoiceModuleSection.assistant => const _VoiceDashboardAssistantPage(),
      VoiceModuleSection.microgrow => const _VoiceMicroGrowStatusPage(),
      VoiceModuleSection.audit => const _VoiceAuditLogPage(),
      VoiceModuleSection.settings => const _VoiceSettingsPage(),
    };
  }
}

class _VoiceHomePage extends ConsumerWidget {
  const _VoiceHomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(voiceFeatureFlagsProvider);
    final loggerEntries = ref.watch(voiceAuditLoggerProvider);
    final session = ref.watch(voiceSessionControllerProvider);
    final thread = ref.watch(voiceConversationThreadProvider);

    return ListView(
      children: [
        _HomeConversationHero(
          thread: thread,
          onOpenConversation: () => context.go(RouteNames.voiceConversation),
          onOpenHomeSection: () => context.go(RouteNames.voiceHome()),
          onResetThread: () {
            ref.read(voiceConversationThreadProvider.notifier).startFresh();
            context.go(RouteNames.voiceHome());
          },
        ),
        const SizedBox(height: 16),
        _HomeFeatureSummary(
          flags: flags,
          loggerEntries: loggerEntries,
          session: session,
          thread: thread,
          onOpenConversation: () => context.go(RouteNames.voiceConversation),
        ),
        const SizedBox(height: 16),
        _HomeResumeCard(
          thread: thread,
          onContinueThread: () => context.go(RouteNames.voiceConversation),
          onStartFresh: () {
            ref.read(voiceConversationThreadProvider.notifier).startFresh();
            context.go(RouteNames.voiceHome());
          },
        ),
        const SizedBox(height: 16),
        _HomeThreadCard(
          thread: thread,
          savedEntryCount: loggerEntries.length,
          latestEntry: loggerEntries.isEmpty ? null : loggerEntries.first,
          onContinueThread: () => context.go(RouteNames.voiceConversation),
          onStartFresh: () {
            ref.read(voiceConversationThreadProvider.notifier).startFresh();
            context.go(RouteNames.voiceHome());
          },
          onCopySummary: () async {
            final summary = thread.summary.trim();
            if (summary.isEmpty) {
              return;
            }

            await Clipboard.setData(ClipboardData(text: summary));
            if (!context.mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied the current voice thread summary.'),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _moduleShortcut(
              context,
              'Voice Notes',
              Icons.note_alt_outlined,
              RouteNames.voiceNotes,
            ),
            _moduleShortcut(
              context,
              'Meetings',
              Icons.meeting_room_outlined,
              RouteNames.voiceMeetings,
            ),
            _moduleShortcut(
              context,
              'Assistant',
              Icons.smart_toy_outlined,
              RouteNames.voiceDashboardAssistant,
            ),
            _moduleShortcut(
              context,
              'MicroGrow',
              Icons.spa_outlined,
              RouteNames.voiceMicrogrow,
            ),
            _moduleShortcut(
              context,
              'Audit Log',
              Icons.receipt_long_outlined,
              RouteNames.voiceAudit,
            ),
            _moduleShortcut(
              context,
              'Settings',
              Icons.settings_outlined,
              RouteNames.voiceSettings,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _HomeCard(
          title: 'Safety first',
          body:
              'All hardware write commands are blocked by the Safety Command Gateway. MicroGrow V1 stays read-only.',
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 12),
        _HomeCard(
          title: 'Legacy bridge',
          body:
              'The older voice bridge still lives at Voice Assistant if you need to compare the new module with the existing flow.',
          icon: Icons.compare_arrows_outlined,
          actionLabel: 'Open legacy bridge',
          onAction: () => context.push(RouteNames.voiceAssistant),
        ),
        const SizedBox(height: 12),
        _HomeCard(
          title: 'Mock mode',
          body:
              'The module runs offline first. OpenAI is optional and the dashboard still loads if no API key is configured.',
          icon: Icons.cloud_off_outlined,
        ),
      ],
    );
  }

  Widget _moduleShortcut(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    return SizedBox(
      width: 210,
      child: _HomeCard(
        title: label,
        body: 'Open this section.',
        icon: icon,
        actionLabel: 'Open',
        onAction: () => context.go(route),
      ),
    );
  }
}

class _HomeFeatureSummary extends StatelessWidget {
  const _HomeFeatureSummary({
    required this.flags,
    required this.loggerEntries,
    required this.session,
    required this.thread,
    required this.onOpenConversation,
  });

  final VoiceFeatureFlags flags;
  final List<VoiceAuditEntry> loggerEntries;
  final VoiceSessionState session;
  final VoiceConversationThreadState thread;
  final VoidCallback onOpenConversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shared voice thread',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Speak once, review anywhere. The whole module stays calm, local-first, and threaded together.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          VoiceThreadSummaryStrip(thread: thread),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatusChip(
                label: 'Log entries: ${loggerEntries.length}',
                accent: AppColours.darkSecondary,
              ),
              _HeroStatusChip(
                label: session.recordingActive
                    ? 'Recording active'
                    : 'Recording idle',
                accent: session.recordingActive
                    ? AppColours.darkSuccess
                    : AppColours.darkMutedText,
              ),
              _HeroStatusChip(
                label: flags.voiceNotesEnabled
                    ? 'Voice notes on'
                    : 'Voice notes off',
                accent: flags.voiceNotesEnabled
                    ? AppColours.darkSuccess
                    : AppColours.darkMutedText,
              ),
              _HeroStatusChip(
                label: flags.microgrowReadOnlyEnabled
                    ? 'MicroGrow read-only'
                    : 'MicroGrow off',
                accent: flags.microgrowReadOnlyEnabled
                    ? AppColours.darkSuccess
                    : AppColours.darkMutedText,
              ),
              _HeroStatusChip(
                label: thread.isFresh ? 'Fresh thread' : 'Thread remembered',
                accent: thread.isFresh
                    ? AppColours.darkMutedText
                    : AppColours.darkSuccess,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onOpenConversation,
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Open conversation'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeConversationHero extends StatelessWidget {
  const _HomeConversationHero({
    required this.thread,
    required this.onOpenConversation,
    required this.onOpenHomeSection,
    required this.onResetThread,
  });

  final VoiceConversationThreadState thread;
  final VoidCallback onOpenConversation;
  final VoidCallback onOpenHomeSection;
  final VoidCallback onResetThread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColours.darkSurfaceRaised.withValues(alpha: 0.98),
            AppColours.darkSurfaceAlt.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColours.darkSecondary.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColours.darkSecondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  color: AppColours.darkSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversation first',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thread.threadTitle == 'No thread yet'
                          ? 'Start a calm thread and let the dashboard remember the shape of the discussion.'
                          : 'Continue ${thread.threadTitle.toLowerCase()} or move straight into the shared talk surface.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatusChip(
                label: 'Next: ${thread.nextStep}',
                accent: AppColours.darkSecondary,
              ),
              _HeroStatusChip(
                label: 'Review: ${thread.reviewPrompt}',
                accent: AppColours.darkMutedText,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                key: const Key('voiceHomeOpenConversationButton'),
                onPressed: onOpenConversation,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Open conversation'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenHomeSection,
                icon: const Icon(Icons.note_alt_outlined),
                label: const Text('Open voice notes'),
              ),
              TextButton.icon(
                onPressed: onResetThread,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset thread'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeResumeCard extends StatelessWidget {
  const _HomeResumeCard({
    required this.thread,
    required this.onContinueThread,
    required this.onStartFresh,
  });

  final VoiceConversationThreadState thread;
  final VoidCallback onContinueThread;
  final VoidCallback onStartFresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSavedThread =
        thread.threadTitle != 'No thread yet' ||
        thread.conversationEntries.isNotEmpty ||
        thread.lastThingYouSaid.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColours.darkSecondary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColours.darkSecondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColours.darkSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasSavedThread
                      ? 'Resume saved thread'
                      : 'No saved thread yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasSavedThread
                      ? 'Pick up ${thread.threadTitle.toLowerCase()} with the latest saved step already in place.'
                      : 'Start one calm thread and the dashboard will keep it around for next time.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.tonalIcon(
                      key: const Key('voiceResumeSavedThreadButton'),
                      onPressed: onContinueThread,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Resume now'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onStartFresh,
                      icon: const Icon(Icons.add_comment_outlined),
                      label: const Text('Start new thread'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceSectionConversationCard extends StatelessWidget {
  const _VoiceSectionConversationCard({
    required this.thread,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final VoiceConversationThreadState thread;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColours.darkSecondary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forum_outlined, color: AppColours.darkSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          VoiceThreadSummaryStrip(thread: thread),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onAction,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(actionLabel),
              ),
              if (secondaryLabel != null && onSecondary != null)
                OutlinedButton.icon(
                  onPressed: onSecondary,
                  icon: const Icon(Icons.home_outlined),
                  label: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeThreadCard extends StatelessWidget {
  const _HomeThreadCard({
    required this.thread,
    required this.savedEntryCount,
    required this.latestEntry,
    required this.onContinueThread,
    required this.onStartFresh,
    required this.onCopySummary,
  });

  final VoiceConversationThreadState thread;
  final int savedEntryCount;
  final VoiceAuditEntry? latestEntry;
  final VoidCallback onContinueThread;
  final VoidCallback onStartFresh;
  final VoidCallback onCopySummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = latestEntry;
    final latestCaptureLabel = entry?.section ?? thread.latestCaptureLabel;
    final latestCapturePreview =
        entry == null || entry.resultSummary.trim().isEmpty
        ? thread.latestCapturePreview
        : entry.resultSummary.trim();
    final promptChips = thread.prompts.isEmpty
        ? _defaultPrompts(thread)
        : thread.prompts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColours.darkSecondary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Where we left off',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                label: Text('$savedEntryCount saved'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            thread.threadTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            thread.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Last thing you said',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            thread.lastThingYouSaid,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroStatusChip(
                label: 'Latest: $latestCaptureLabel',
                accent: AppColours.darkSecondary,
              ),
              _HeroStatusChip(
                label: 'Next: ${thread.nextStep}',
                accent: AppColours.darkMutedText,
              ),
            ],
          ),
          if (promptChips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Try next',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: promptChips
                  .map(
                    (prompt) => Tooltip(
                      message: prompt.description,
                      child: ActionChip(
                        label: Text(prompt.label),
                        avatar: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                        ),
                        onPressed: prompt.route == null
                            ? null
                            : () => context.go(prompt.route!),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            thread.reviewPrompt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            latestCapturePreview,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                key: const Key('voiceContinueThreadButton'),
                onPressed: onContinueThread,
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Continue conversation'),
              ),
              OutlinedButton.icon(
                key: const Key('voiceStartFreshThreadButton'),
                onPressed: onStartFresh,
                icon: const Icon(Icons.fiber_new_outlined),
                label: const Text('Start fresh'),
              ),
              TextButton.icon(
                key: const Key('voiceCopyThreadSummaryButton'),
                onPressed: onCopySummary,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy summary'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<VoiceConversationPrompt> _defaultPrompts(
    VoiceConversationThreadState thread,
  ) {
    return switch (thread.threadTitle) {
      'Voice Notes' => const [
        VoiceConversationPrompt(
          label: 'Review the note',
          description: 'Open the note capture flow and check the transcript.',
          route: RouteNames.voiceNotes,
        ),
        VoiceConversationPrompt(
          label: 'Move to meetings',
          description: 'Bring the idea into the meeting summary flow.',
          route: RouteNames.voiceMeetings,
        ),
        VoiceConversationPrompt(
          label: 'Start fresh',
          description: 'Clear the current thread and begin a new capture.',
          route: RouteNames.voiceHomeRoute,
        ),
      ],
      'Meeting Transcriber' => const [
        VoiceConversationPrompt(
          label: 'Check follow-ups',
          description: 'Review the latest summary and follow-up actions.',
          route: RouteNames.voiceMeetings,
        ),
        VoiceConversationPrompt(
          label: 'Ask the assistant',
          description: 'Turn the meeting into a gentle dashboard question.',
          route: RouteNames.voiceDashboardAssistant,
        ),
        VoiceConversationPrompt(
          label: 'Copy summary',
          description: 'Copy the thread summary for a local note.',
        ),
      ],
      'Dashboard Assistant' => const [
        VoiceConversationPrompt(
          label: 'Ask a follow-up',
          description: 'Keep the dashboard conversation moving.',
          route: RouteNames.voiceDashboardAssistant,
        ),
        VoiceConversationPrompt(
          label: 'Check MicroGrow',
          description: 'Switch to the safe read-only status view.',
          route: RouteNames.voiceMicrogrow,
        ),
        VoiceConversationPrompt(
          label: 'Review the thread',
          description: 'Go back to the calm home summary.',
          route: RouteNames.voiceHomeRoute,
        ),
      ],
      'MicroGrow Voice Status' => const [
        VoiceConversationPrompt(
          label: 'Read status again',
          description: 'Ask for the next read-only snapshot.',
          route: RouteNames.voiceMicrogrow,
        ),
        VoiceConversationPrompt(
          label: 'Review warnings',
          description: 'Check the latest warnings and notes.',
          route: RouteNames.voiceAudit,
        ),
        VoiceConversationPrompt(
          label: 'Return home',
          description: 'Come back to the calm module hub.',
          route: RouteNames.voiceHomeRoute,
        ),
      ],
      _ => const [
        VoiceConversationPrompt(
          label: 'Open notes',
          description: 'Start with a quick voice note.',
          route: RouteNames.voiceNotes,
        ),
        VoiceConversationPrompt(
          label: 'Summarize a meeting',
          description: 'Turn a transcript into next actions.',
          route: RouteNames.voiceMeetings,
        ),
        VoiceConversationPrompt(
          label: 'Ask the assistant',
          description: 'Use the dashboard assistant for a safe reply.',
          route: RouteNames.voiceDashboardAssistant,
        ),
      ],
    };
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.body,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColours.darkSecondary),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceNotesPage extends ConsumerStatefulWidget {
  const _VoiceNotesPage();

  @override
  ConsumerState<_VoiceNotesPage> createState() => _VoiceNotesPageState();
}

class _VoiceNotesPageState extends ConsumerState<_VoiceNotesPage> {
  final TextEditingController _transcriptController = TextEditingController();
  final TextEditingController _seedController = TextEditingController();
  String _destination = 'inbox';
  String _status = 'Ready to record a note.';
  final List<String> _savedNotes = <String>[];

  @override
  void dispose() {
    _transcriptController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(voiceSessionControllerProvider);
    final config = ref.watch(voiceModuleConfigProvider);
    final transcriptionService = ref.read(voiceTranscriptionServiceProvider);
    final logger = ref.read(voiceAuditLoggerProvider.notifier);
    final thread = ref.read(voiceConversationThreadProvider.notifier);
    final threadState = ref.watch(voiceConversationThreadProvider);

    return ListView(
      children: [
        _VoiceSectionConversationCard(
          thread: threadState,
          title: 'Keep the thread moving',
          body:
              'Voice notes and the shared conversation stay in step so you can move back to the main dialogue whenever the note is ready.',
          actionLabel: 'Open conversation',
          onAction: () => context.go(RouteNames.voiceConversation),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go(RouteNames.voiceHome()),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Recording controls',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: session.recordingActive
                    ? null
                    : () {
                        ref
                            .read(voiceSessionControllerProvider.notifier)
                            .startRecording(
                              mode: VoiceSessionMode.voiceNote,
                              label: 'Voice note recording active',
                            );
                        setState(
                          () => _status = 'Recording started. Speak your note.',
                        );
                      },
                icon: const Icon(Icons.fiber_manual_record),
                label: const Text('Start Recording'),
              ),
              FilledButton.tonalIcon(
                onPressed: session.recordingActive
                    ? () async {
                        final result = await transcriptionService
                            .transcribeMock(
                              mode: VoiceSessionMode.voiceNote,
                              prompt: _seedController.text.isEmpty
                                  ? _transcriptController.text
                                  : _seedController.text,
                              config: config.runtime,
                            );
                        ref
                            .read(voiceSessionControllerProvider.notifier)
                            .updateTranscript(result.transcript);
                        ref
                            .read(voiceSessionControllerProvider.notifier)
                            .stopRecording();
                        _transcriptController.text = result.transcript;
                        setState(
                          () => _status =
                              '${result.providerLabel}: ${result.notes}',
                        );
                        thread.rememberThread(
                          threadTitle: 'Voice Notes',
                          summary:
                              'The note is ready to review before it is saved locally.',
                          nextStep:
                              'Choose a destination, check the transcript, and save it when it feels right.',
                          resumeRoute: RouteNames.voiceNotes,
                          latestCaptureLabel: 'Voice note transcript',
                          latestCapturePreview: result.transcript,
                          lastThingYouSaid: _seedController.text.isEmpty
                              ? result.transcript
                              : _seedController.text,
                          reviewPrompt:
                              'Review the transcript first so the save stays calm and local.',
                          prompts: const [
                            VoiceConversationPrompt(
                              label: 'Review this note',
                              description: 'Return to the note capture flow.',
                              route: RouteNames.voiceNotes,
                            ),
                            VoiceConversationPrompt(
                              label: 'Turn into meeting',
                              description:
                                  'Move the thread into meeting summary.',
                              route: RouteNames.voiceMeetings,
                            ),
                            VoiceConversationPrompt(
                              label: 'Ask assistant',
                              description: 'Use the dashboard assistant next.',
                              route: RouteNames.voiceDashboardAssistant,
                            ),
                          ],
                        );
                        thread.appendSystemMessage(
                          'Voice note transcript ready for review.',
                          title: 'Voice Notes',
                          intent: 'voice.note.transcribe',
                        );
                        logger.record(
                          VoiceAuditEntry(
                            id: 'voice-note-transcribe-${DateTime.now().millisecondsSinceEpoch}',
                            timestamp: DateTime.now(),
                            section: 'Voice Notes',
                            userText: _seedController.text,
                            intent: 'voice.note.transcribe',
                            safetyDecision: const SafetyDecision(
                              allowed: true,
                              riskLevel: VoiceRiskLevel.low,
                              requiresConfirmation: false,
                              reason: 'Transcription is allowed.',
                            ),
                            resultSummary: result.transcript,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Stop and Transcribe'),
              ),
              _HeroStatusChip(
                label: session.recordingActive
                    ? 'Recording active'
                    : 'Recording idle',
                accent: session.recordingActive
                    ? AppColours.darkSuccess
                    : AppColours.darkMutedText,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Transcript review',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _seedController,
                decoration: const InputDecoration(
                  labelText: 'Prompt or source note',
                  hintText: 'Type a seed thought for the mock transcription',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _transcriptController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Transcript',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _destination,
                items: const [
                  DropdownMenuItem(value: 'inbox', child: Text('Inbox')),
                  DropdownMenuItem(value: 'journal', child: Text('Journal')),
                  DropdownMenuItem(value: 'meeting', child: Text('Meeting')),
                  DropdownMenuItem(value: 'project', child: Text('Project')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _destination = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Save to'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  final transcript = _transcriptController.text.trim();
                  if (transcript.isEmpty) {
                    setState(() => _status = 'Add a transcript before saving.');
                    return;
                  }

                  final noteSummary = transcript.length > 140
                      ? '${transcript.substring(0, 137)}...'
                      : transcript;
                  _savedNotes.insert(0, 'Saved to $_destination: $noteSummary');
                  thread.rememberThread(
                    threadTitle: 'Voice Notes',
                    summary:
                        'The voice note was saved locally to $_destination.',
                    nextStep:
                        'Capture another note, or move the thread into meetings, assistant, or MicroGrow status.',
                    resumeRoute: RouteNames.voiceNotes,
                    latestCaptureLabel: 'Saved voice note',
                    latestCapturePreview: noteSummary,
                    lastThingYouSaid: transcript,
                    reviewPrompt:
                        'The note has already been reviewed and saved locally.',
                    prompts: const [
                      VoiceConversationPrompt(
                        label: 'Capture another note',
                        description: 'Start a new voice note review.',
                        route: RouteNames.voiceNotes,
                      ),
                      VoiceConversationPrompt(
                        label: 'Summarize a meeting',
                        description: 'Shift this thread into meeting summary.',
                        route: RouteNames.voiceMeetings,
                      ),
                      VoiceConversationPrompt(
                        label: 'Check MicroGrow',
                        description: 'Move to read-only status checks.',
                        route: RouteNames.voiceMicrogrow,
                      ),
                    ],
                  );
                  thread.appendSystemMessage(
                    'Voice note saved locally to $_destination.',
                    title: 'Voice Notes',
                    intent: 'voice.note.save',
                  );
                  logger.record(
                    VoiceAuditEntry(
                      id: 'voice-note-save-${DateTime.now().millisecondsSinceEpoch}',
                      timestamp: DateTime.now(),
                      section: 'Voice Notes',
                      userText: transcript,
                      intent: 'voice.note.save',
                      safetyDecision: const SafetyDecision(
                        allowed: true,
                        riskLevel: VoiceRiskLevel.low,
                        requiresConfirmation: false,
                        reason: 'Saving reviewed notes is allowed.',
                      ),
                      resultSummary: 'Saved to $_destination.',
                    ),
                  );
                  setState(() => _status = 'Saved locally to $_destination.');
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Note'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(title: 'Status', child: Text(_status)),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Saved notes',
          child: _savedNotes.isEmpty
              ? const Text('No notes have been saved yet.')
              : Column(
                  children: _savedNotes
                      .map(
                        (note) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.note_alt_outlined),
                          title: Text(note),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _VoiceMeetingTranscriberPage extends ConsumerStatefulWidget {
  const _VoiceMeetingTranscriberPage();

  @override
  ConsumerState<_VoiceMeetingTranscriberPage> createState() =>
      _VoiceMeetingTranscriberPageState();
}

class _VoiceMeetingTranscriberPageState
    extends ConsumerState<_VoiceMeetingTranscriberPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _transcriptController = TextEditingController();
  MeetingSummaryResult? _result;
  String _status = 'Paste a transcript to generate a summary.';

  @override
  void dispose() {
    _titleController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(voiceMeetingSummaryServiceProvider);
    final logger = ref.read(voiceAuditLoggerProvider.notifier);
    final thread = ref.read(voiceConversationThreadProvider.notifier);
    final threadState = ref.watch(voiceConversationThreadProvider);

    return ListView(
      children: [
        _VoiceSectionConversationCard(
          thread: threadState,
          title: 'Meeting summary stays connected',
          body:
              'The meeting transcriber feeds the same shared thread, so the summary can flow back into a calmer conversation immediately.',
          actionLabel: 'Open conversation',
          onAction: () => context.go(RouteNames.voiceConversation),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go(RouteNames.voiceHome()),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Meeting details',
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Meeting title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _transcriptController,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Meeting transcript',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await service.createMockSummary(
                        transcript: _transcriptController.text,
                        meetingTitle: _titleController.text,
                      );
                      setState(() {
                        _result = result;
                        _status = 'Mock summary generated locally.';
                      });
                      thread.rememberThread(
                        threadTitle: 'Meeting Transcriber',
                        summary:
                            'The meeting summary draft is ready for review before saving.',
                        nextStep:
                            'Check the decisions, actions, risks, and follow-ups, then save the useful parts.',
                        resumeRoute: RouteNames.voiceMeetings,
                        latestCaptureLabel: 'Meeting summary draft',
                        latestCapturePreview: result.summary,
                        lastThingYouSaid: _transcriptController.text,
                        reviewPrompt:
                            'Review the summary first so the meeting thread stays calm and accurate.',
                        prompts: const [
                          VoiceConversationPrompt(
                            label: 'Review follow-ups',
                            description: 'Check the summary and actions again.',
                            route: RouteNames.voiceMeetings,
                          ),
                          VoiceConversationPrompt(
                            label: 'Ask assistant',
                            description:
                                'Turn the meeting into a dashboard question.',
                            route: RouteNames.voiceDashboardAssistant,
                          ),
                          VoiceConversationPrompt(
                            label: 'Back to home',
                            description: 'Return to the calm thread summary.',
                            route: RouteNames.voiceHomeRoute,
                          ),
                        ],
                      );
                      thread.appendSystemMessage(
                        'Meeting summary draft ready for review.',
                        title: 'Meeting Transcriber',
                        intent: 'meeting.summary.create',
                      );
                      logger.record(
                        VoiceAuditEntry(
                          id: 'voice-meeting-summary-${DateTime.now().millisecondsSinceEpoch}',
                          timestamp: DateTime.now(),
                          section: 'Meeting Transcriber',
                          userText: _transcriptController.text,
                          intent: 'meeting.summary.create',
                          safetyDecision: const SafetyDecision(
                            allowed: true,
                            riskLevel: VoiceRiskLevel.low,
                            requiresConfirmation: false,
                            reason: 'Meeting summaries are allowed.',
                          ),
                          resultSummary: result.summary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Generate Summary'),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _titleController.text = 'MicroGrow planning call';
                        _transcriptController.text =
                            'We agreed to keep MicroGrow read-only in V1. Next, Peter will review the dashboard voice notes and confirm the audit log flow. A relay change remains a blocked action.';
                      });
                    },
                    icon: const Icon(Icons.playlist_add_check_circle_outlined),
                    label: const Text('Load Mock Transcript'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(title: 'Status', child: Text(_status)),
        const SizedBox(height: 14),
        if (_result != null)
          _sectionPanel(
            title: 'Summary',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_result!.summary),
                const SizedBox(height: 12),
                _bulletGroup('Decisions', _result!.decisions),
                _bulletGroup('Actions', _result!.actions),
                _bulletGroup('Risks', _result!.risks),
                _bulletGroup('Follow-ups', _result!.followUps),
              ],
            ),
          ),
      ],
    );
  }

  Widget _bulletGroup(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (items.isEmpty)
            const Text('None captured.')
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $item'),
              ),
            ),
        ],
      ),
    );
  }
}

class _VoiceDashboardAssistantPage extends ConsumerStatefulWidget {
  const _VoiceDashboardAssistantPage();

  @override
  ConsumerState<_VoiceDashboardAssistantPage> createState() =>
      _VoiceDashboardAssistantPageState();
}

class _VoiceDashboardAssistantPageState
    extends ConsumerState<_VoiceDashboardAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  VoiceAssistantResponse? _response;
  String _status = 'Ask the dashboard something safe.';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assistant = ref.read(voiceAssistantServiceProvider);
    final logger = ref.read(voiceAuditLoggerProvider.notifier);
    final threadState = ref.watch(voiceConversationThreadProvider);

    return ListView(
      children: [
        _VoiceSectionConversationCard(
          thread: threadState,
          title: 'Conversation before action',
          body:
              'Ask the dashboard a safe question, then keep the same thread moving through notes, meetings, or MicroGrow status as needed.',
          actionLabel: 'Open conversation',
          onAction: () => context.go(RouteNames.voiceConversation),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go(RouteNames.voiceHome()),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Prompt',
          child: Column(
            children: [
              TextField(
                controller: _messageController,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Assistant message',
                  hintText:
                      'Create a task for MicroGrow sensor testing tomorrow.',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => _send(assistant, logger),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Send'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _messageController.text =
                            'Create a task for MicroGrow sensor testing tomorrow.';
                      });
                    },
                    child: const Text('Use task draft'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _messageController.text =
                            'What is the current MicroGrow temperature and humidity?';
                      });
                    },
                    child: const Text('Use status query'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(title: 'Status', child: Text(_status)),
        const SizedBox(height: 14),
        if (_response != null)
          _sectionPanel(
            title: 'Response',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_response!.reply),
                const SizedBox(height: 12),
                Text('Intents: ${_response!.intents.join(', ')}'),
                Text('Safety: ${_response!.safetyDecision.reason}'),
                const SizedBox(height: 12),
                if (_response!.actions.isNotEmpty) ...[
                  const Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  ..._response!.actions.map(
                    (action) => Text('• ${action.type} (${action.status})'),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _send(
    VoiceAssistantService assistant,
    VoiceAuditLogger logger,
  ) async {
    final thread = ref.read(voiceConversationThreadProvider.notifier);
    final result = await assistant.createMockResponse(
      message: _messageController.text,
    );
    setState(() {
      _response = result;
      _status = result.safetyDecision.allowed
          ? 'Mock assistant response ready.'
          : 'Blocked by the safety gateway.';
    });
    thread.rememberThread(
      threadTitle: 'Dashboard Assistant',
      summary: result.reply,
      nextStep: result.safetyDecision.allowed
          ? 'Use the calm mock reply, or ask a follow-up about the dashboard.'
          : 'Adjust the request and keep hardware writes blocked.',
      resumeRoute: RouteNames.voiceDashboardAssistant,
      latestCaptureLabel: 'Assistant request',
      latestCapturePreview: _messageController.text,
      lastThingYouSaid: _messageController.text,
      reviewPrompt:
          'Review the assistant reply before turning it into a local action.',
      prompts: const [
        VoiceConversationPrompt(
          label: 'Ask a follow-up',
          description: 'Keep the dashboard conversation going.',
          route: RouteNames.voiceDashboardAssistant,
        ),
        VoiceConversationPrompt(
          label: 'Check MicroGrow',
          description: 'Jump to the read-only status view.',
          route: RouteNames.voiceMicrogrow,
        ),
        VoiceConversationPrompt(
          label: 'Return home',
          description: 'Go back to the calm voice hub.',
          route: RouteNames.voiceHomeRoute,
        ),
      ],
    );
    thread.appendAssistantMessage(
      result.reply,
      title: 'Dashboard reply',
      intent: result.intents.isEmpty
          ? 'dashboard.assistant.unknown'
          : result.intents.first,
    );
    logger.record(
      VoiceAuditEntry(
        id: 'voice-assistant-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        section: 'Dashboard Assistant',
        userText: _messageController.text,
        intent: result.intents.isEmpty
            ? 'dashboard.assistant.unknown'
            : result.intents.first,
        safetyDecision: result.safetyDecision,
        resultSummary: result.reply,
      ),
    );
  }
}

class _VoiceMicroGrowStatusPage extends ConsumerStatefulWidget {
  const _VoiceMicroGrowStatusPage();

  @override
  ConsumerState<_VoiceMicroGrowStatusPage> createState() =>
      _VoiceMicroGrowStatusPageState();
}

class _VoiceMicroGrowStatusPageState
    extends ConsumerState<_VoiceMicroGrowStatusPage> {
  final TextEditingController _queryController = TextEditingController();
  MicroGrowVoiceStatusResult? _status;
  String _statusMessage = 'Ask for MicroGrow status using a read-only query.';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(voiceMicroGrowStatusServiceProvider);
    final logger = ref.read(voiceAuditLoggerProvider.notifier);
    final thread = ref.read(voiceConversationThreadProvider.notifier);
    final threadState = ref.watch(voiceConversationThreadProvider);

    return ListView(
      children: [
        _VoiceSectionConversationCard(
          thread: threadState,
          title: 'Read-only status, same thread',
          body:
              'MicroGrow stays read-only in V1, and this status view still feeds the same conversation so nothing feels disconnected.',
          actionLabel: 'Open conversation',
          onAction: () => context.go(RouteNames.voiceConversation),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go(RouteNames.voiceHome()),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Status query',
          child: Column(
            children: [
              TextField(
                controller: _queryController,
                decoration: const InputDecoration(
                  labelText: 'Query',
                  hintText: 'What is the temperature? Are there warnings?',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await service.readMockStatus(
                        query: _queryController.text,
                      );
                      setState(() {
                        _status = result;
                        _statusMessage = result.nodeOnline
                            ? 'MicroGrow read-only status returned.'
                            : 'MicroGrow node is offline in mock mode.';
                      });
                      thread.rememberThread(
                        threadTitle: 'MicroGrow Voice Status',
                        summary:
                            'MicroGrow status was checked in read-only mode and stayed safe.',
                        nextStep:
                            'Review the status snapshot, then return to the dashboard thread when ready.',
                        resumeRoute: RouteNames.voiceMicrogrow,
                        latestCaptureLabel: 'MicroGrow status query',
                        latestCapturePreview: _queryController.text,
                        lastThingYouSaid: _queryController.text,
                        reviewPrompt:
                            'Read-only status is safe, but the snapshot should still be reviewed before you act on it.',
                        prompts: const [
                          VoiceConversationPrompt(
                            label: 'Read again',
                            description: 'Refresh the safe status snapshot.',
                            route: RouteNames.voiceMicrogrow,
                          ),
                          VoiceConversationPrompt(
                            label: 'Review warnings',
                            description: 'Open the audit log and safety notes.',
                            route: RouteNames.voiceAudit,
                          ),
                          VoiceConversationPrompt(
                            label: 'Return home',
                            description: 'Come back to the conversation hub.',
                            route: RouteNames.voiceHomeRoute,
                          ),
                        ],
                      );
                      thread.appendSystemMessage(
                        'MicroGrow read-only status checked.',
                        title: 'MicroGrow Voice Status',
                        intent: 'microgrow.status.read',
                      );
                      logger.record(
                        VoiceAuditEntry(
                          id: 'voice-microgrow-${DateTime.now().millisecondsSinceEpoch}',
                          timestamp: DateTime.now(),
                          section: 'MicroGrow Voice Status',
                          userText: _queryController.text,
                          intent: 'microgrow.status.read',
                          safetyDecision: const SafetyDecision(
                            allowed: true,
                            riskLevel: VoiceRiskLevel.low,
                            requiresConfirmation: false,
                            reason: 'Read-only MicroGrow status is allowed.',
                          ),
                          resultSummary: result.querySummary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Read Status'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _queryController.text = 'What relays are currently on?';
                      });
                    },
                    child: const Text('Relay query'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _queryController.text = 'Are there any warnings?';
                      });
                    },
                    child: const Text('Warning query'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(title: 'Status', child: Text(_statusMessage)),
        const SizedBox(height: 14),
        if (_status != null)
          _sectionPanel(
            title: 'MicroGrow snapshot',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_status!.nodeOnline ? 'Node online' : 'Node offline'),
                if (_status!.temperatureC != null)
                  Text('Temperature: ${_status!.temperatureC} C'),
                if (_status!.humidityPercent != null)
                  Text('Humidity: ${_status!.humidityPercent}%'),
                Text(
                  'Relays: ${_status!.relays.entries.map((entry) => '${entry.key}=${entry.value ? 'on' : 'off'}').join(', ')}',
                ),
                if (_status!.warnings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Warnings',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  ..._status!.warnings.map((warning) => Text('• $warning')),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ignore: unused_element
class _VoiceAuditLogPageOld extends ConsumerWidget {
  const _VoiceAuditLogPageOld();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggerEntries = ref.watch(voiceAuditLoggerProvider);

    return ListView(
      children: [
        _sectionPanel(
          title: 'Audit controls',
          child: Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: loggerEntries.isEmpty
                    ? null
                    : () => ref.read(voiceAuditLoggerProvider.notifier).clear(),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Log'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                key: const Key('voiceAuditJumpBackLatestButton'),
                onPressed: () => context.go(
                  loggerEntries.isNotEmpty
                      ? _auditEntryRoute(loggerEntries.first)
                      : RouteNames.voiceConversation,
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Jump back latest'),
              ),
              const SizedBox(width: 12),
              Text('${loggerEntries.length} entries recorded.'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (loggerEntries.isEmpty)
          _sectionPanel(
            title: 'Audit log',
            child: const Text('No voice intents have been logged yet.'),
          )
        else
          ...loggerEntries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _sectionPanel(
                title: '${entry.section} • ${_formatDateTime(entry.timestamp)}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Intent: ${entry.intent}'),
                    Text(
                      'Allowed: ${entry.safetyDecision.allowed ? 'yes' : 'no'}',
                    ),
                    Text('Reason: ${entry.safetyDecision.reason}'),
                    const SizedBox(height: 8),
                    Text(
                      entry.userText,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(entry.resultSummary),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => context.go(_auditEntryRoute(entry)),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Jump back'),
                        ),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(voiceAuditLoggerProvider.notifier)
                              .removeById(entry.id),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _VoiceAuditLogPage extends ConsumerStatefulWidget {
  const _VoiceAuditLogPage();

  @override
  ConsumerState<_VoiceAuditLogPage> createState() => _VoiceAuditLogPageState();
}

class _VoiceAuditLogPageState extends ConsumerState<_VoiceAuditLogPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _intentController = TextEditingController();
  String? _sectionFilter;

  @override
  void dispose() {
    _searchController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggerEntries = ref.watch(voiceAuditLoggerProvider);
    final filteredEntries = _filteredEntries(loggerEntries);
    final sectionOptions =
        loggerEntries.map((entry) => entry.section).toSet().toList()..sort();
    final threadState = ref.watch(voiceConversationThreadProvider);

    return ListView(
      children: [
        _VoiceSectionConversationCard(
          thread: threadState,
          title: 'Audit log stays part of the flow',
          body:
              'Every entry can jump back to the page that created it, and the shared thread keeps the context warm for follow-up.',
          actionLabel: 'Open conversation',
          onAction: () => context.go(RouteNames.voiceConversation),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go(RouteNames.voiceHome()),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Audit controls',
          child: Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: loggerEntries.isEmpty
                    ? null
                    : () => ref.read(voiceAuditLoggerProvider.notifier).clear(),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Log'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                key: const Key('voiceAuditJumpBackLatestButton'),
                onPressed: () => context.go(
                  loggerEntries.isNotEmpty
                      ? _auditEntryRoute(loggerEntries.first)
                      : RouteNames.voiceConversation,
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Jump back latest'),
              ),
              const SizedBox(width: 12),
              Text('${loggerEntries.length} entries recorded.'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Search and filters',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search section, intent, user text, or summary',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;
                  final sectionField = DropdownButtonFormField<String?>(
                    initialValue: _sectionFilter,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All sections'),
                      ),
                      ...sectionOptions.map(
                        (section) => DropdownMenuItem<String?>(
                          value: section,
                          child: Text(section),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _sectionFilter = value),
                    decoration: const InputDecoration(
                      labelText: 'Section filter',
                    ),
                  );
                  final intentField = TextField(
                    controller: _intentController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Intent filter',
                      hintText: 'e.g. microgrow.status.read',
                    ),
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: sectionField),
                        const SizedBox(width: 12),
                        Expanded(child: intentField),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      sectionField,
                      const SizedBox(height: 12),
                      intentField,
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_searchController.text.trim().isNotEmpty)
                    ActionChip(
                      label: Text('Search: ${_searchController.text.trim()}'),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
                  if (_intentController.text.trim().isNotEmpty)
                    ActionChip(
                      label: Text('Intent: ${_intentController.text.trim()}'),
                      onPressed: () {
                        setState(() {
                          _intentController.clear();
                        });
                      },
                    ),
                  if (_sectionFilter != null)
                    ActionChip(
                      label: Text('Section: $_sectionFilter'),
                      onPressed: () => setState(() => _sectionFilter = null),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (filteredEntries.isEmpty)
          _sectionPanel(
            title: 'Audit log',
            child: Text(
              loggerEntries.isEmpty
                  ? 'No voice intents have been logged yet.'
                  : 'No entries match the current search or filter.',
            ),
          )
        else
          ...filteredEntries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _sectionPanel(
                title:
                    '${entry.section} â€¢ ${_formatDateTime(entry.timestamp)}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Intent: ${entry.intent}'),
                    Text(
                      'Allowed: ${entry.safetyDecision.allowed ? 'yes' : 'no'}',
                    ),
                    Text('Reason: ${entry.safetyDecision.reason}'),
                    const SizedBox(height: 8),
                    Text(
                      entry.userText,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(entry.resultSummary),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          key: const Key('voiceAuditJumpBackButton'),
                          onPressed: () => context.go(_auditEntryRoute(entry)),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Jump back'),
                        ),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(voiceAuditLoggerProvider.notifier)
                              .removeById(entry.id),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<VoiceAuditEntry> _filteredEntries(List<VoiceAuditEntry> entries) {
    final search = _searchController.text.trim().toLowerCase();
    final intentFilter = _intentController.text.trim().toLowerCase();

    return entries
        .where((entry) {
          if (_sectionFilter != null && entry.section != _sectionFilter) {
            return false;
          }

          if (intentFilter.isNotEmpty &&
              !entry.intent.toLowerCase().contains(intentFilter)) {
            return false;
          }

          if (search.isEmpty) {
            return true;
          }

          final haystack = <String>[
            entry.section,
            entry.intent,
            entry.userText,
            entry.resultSummary,
            entry.safetyDecision.reason,
          ].join(' ').toLowerCase();
          return haystack.contains(search);
        })
        .toList(growable: false);
  }
}

String _auditEntryRoute(VoiceAuditEntry entry) {
  final section = entry.section.toLowerCase();
  final intent = entry.intent.toLowerCase();

  if (section.contains('conversation') || intent.contains('assistant')) {
    return RouteNames.voiceConversation;
  }

  if (section.contains('note') || intent.contains('note')) {
    return RouteNames.voiceNotes;
  }

  if (section.contains('meeting') || intent.contains('meeting')) {
    return RouteNames.voiceMeetings;
  }

  if (section.contains('microgrow') || intent.contains('microgrow')) {
    return RouteNames.voiceMicrogrow;
  }

  if (section.contains('audit')) {
    return RouteNames.voiceAudit;
  }

  return RouteNames.voiceConversation;
}

class _VoiceSettingsPage extends ConsumerWidget {
  const _VoiceSettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(voiceFeatureFlagsProvider);
    final config = ref.watch(voiceModuleConfigProvider);
    final mode = ref.watch(voiceProviderModeProvider);
    final loggerEntries = ref.watch(voiceAuditLoggerProvider);
    final thread = ref.watch(voiceConversationThreadProvider);

    return ListView(
      children: [
        _VoiceSectionConversationCard(
          thread: thread,
          title: 'Keep the settings in context',
          body:
              'Provider mode and feature flags stay local, but the conversation thread remains the center of the experience.',
          actionLabel: 'Open conversation',
          onAction: () => context.go(RouteNames.voiceConversation),
          secondaryLabel: 'Back to home',
          onSecondary: () => context.go(RouteNames.voiceHome()),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Provider mode',
          child: SegmentedButton<VoiceProviderMode>(
            segments: const [
              ButtonSegment(value: VoiceProviderMode.mock, label: Text('Mock')),
              ButtonSegment(
                value: VoiceProviderMode.ollama,
                label: Text('Ollama'),
              ),
              ButtonSegment(
                value: VoiceProviderMode.openAi,
                label: Text('OpenAI'),
              ),
              ButtonSegment(
                value: VoiceProviderMode.realtimeLater,
                label: Text('Realtime later'),
              ),
            ],
            selected: <VoiceProviderMode>{mode},
            onSelectionChanged: (selection) {
              ref
                  .read(voiceProviderModeProvider.notifier)
                  .setMode(selection.first);
            },
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Feature flags',
          child: Column(
            children: [
              _flagSwitch(
                ref,
                label: 'Voice notes',
                value: flags.voiceNotesEnabled,
                onChanged: (value) =>
                    _updateFlags(ref, flags.copyWith(voiceNotesEnabled: value)),
              ),
              _flagSwitch(
                ref,
                label: 'Meeting transcriber',
                value: flags.meetingTranscriberEnabled,
                onChanged: (value) => _updateFlags(
                  ref,
                  flags.copyWith(meetingTranscriberEnabled: value),
                ),
              ),
              _flagSwitch(
                ref,
                label: 'Dashboard assistant',
                value: flags.dashboardAssistantEnabled,
                onChanged: (value) => _updateFlags(
                  ref,
                  flags.copyWith(dashboardAssistantEnabled: value),
                ),
              ),
              _flagSwitch(
                ref,
                label: 'MicroGrow read-only',
                value: flags.microgrowReadOnlyEnabled,
                onChanged: (value) => _updateFlags(
                  ref,
                  flags.copyWith(microgrowReadOnlyEnabled: value),
                ),
              ),
              _flagSwitch(
                ref,
                label: 'MicroGrow voice control',
                value: flags.microgrowVoiceControlEnabled,
                onChanged: (value) => _updateFlags(
                  ref,
                  flags.copyWith(microgrowVoiceControlEnabled: value),
                ),
              ),
              _flagSwitch(
                ref,
                label: 'Always-on wake word',
                value: flags.alwaysOnWakeWordEnabled,
                onChanged: (value) => _updateFlags(
                  ref,
                  flags.copyWith(alwaysOnWakeWordEnabled: value),
                ),
              ),
              _flagSwitch(
                ref,
                label: 'Cloud sync voice logs',
                value: flags.cloudSyncVoiceLogsEnabled,
                onChanged: (value) => _updateFlags(
                  ref,
                  flags.copyWith(cloudSyncVoiceLogsEnabled: value),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Environment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OpenAI API key configured: ${config.runtime.hasApiKey ? 'yes' : 'no'}',
              ),
              Text(switch (config.runtime.configSourceLabel) {
                'gaia_usb' => 'Config source: GAIA USB (Ollama detected)',
                _ => 'Config source: ${config.runtime.configSourceLabel}',
              }),
              Text('Transcription model: ${config.runtime.transcriptionModel}'),
              Text('Realtime model: ${config.runtime.realtimeModel}'),
              Text('TTS model: ${config.runtime.ttsModel}'),
              const SizedBox(height: 8),
              const Text(
                'No secret values are stored here. Use environment variables or build-time defines only.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionPanel(
          title: 'Audit snapshot',
          child: Text('Current log entries: ${loggerEntries.length}'),
        ),
      ],
    );
  }

  Widget _flagSwitch(
    WidgetRef ref, {
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  void _updateFlags(WidgetRef ref, VoiceFeatureFlags flags) {
    ref.read(voiceFeatureFlagsProvider.notifier).update(flags);
  }
}

Widget _sectionPanel({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColours.darkSurface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColours.darkOutline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColours.darkText,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.16),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class _HeroStatusChip extends StatelessWidget {
  const _HeroStatusChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColours.darkText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime timestamp) {
  final date = timestamp.toLocal();
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

Color _legacySessionAccent(legacy_session.VoiceSessionState session) {
  return switch (session.phase) {
    legacy_session.VoiceSessionPhase.listening => AppColours.darkSecondary,
    legacy_session.VoiceSessionPhase.processing => AppColours.darkAmber,
    legacy_session.VoiceSessionPhase.speaking => AppColours.darkSuccess,
    legacy_session.VoiceSessionPhase.awaitingFollowUp =>
      AppColours.darkSecondary,
    legacy_session.VoiceSessionPhase.waking => AppColours.darkAccent,
    legacy_session.VoiceSessionPhase.error => AppColours.darkAmber,
    legacy_session.VoiceSessionPhase.idle => AppColours.darkMutedText,
  };
}
