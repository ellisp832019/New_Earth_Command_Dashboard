import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/treasury_budget_pots_controller.dart';

class TreasuryBudgetPotsScreen extends ConsumerWidget {
  const TreasuryBudgetPotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final potsAsync = ref.watch(treasuryBudgetPotsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Budget Pots'),
        leading: IconButton(
          tooltip: 'Back to Treasury',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.go(RouteNames.treasury);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: () => ref.invalidate(treasuryBudgetPotsProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Open monthly summary',
            onPressed: () => context.push(RouteNames.treasuryMonthlySummary),
            icon: const Icon(Icons.assessment_outlined),
          ),
        ],
      ),
      body: potsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _BudgetPotsErrorCard(
          onReload: () => ref.invalidate(treasuryBudgetPotsProvider),
        ),
        data: (snapshot) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _BudgetPotsHeroCard(snapshot: snapshot),
                const SizedBox(height: 16),
                _BudgetOverviewCard(snapshot: snapshot),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 1240
                        ? 3
                        : constraints.maxWidth >= 760
                        ? 2
                        : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.pots.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: crossAxisCount == 1 ? 2.4 : 1.5,
                      ),
                      itemBuilder: (context, index) {
                        final pot = snapshot.pots[index];
                        return _BudgetPotCard(pot: pot);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                _BudgetPotsFooterCard(snapshot: snapshot),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BudgetPotsHeroCard extends StatelessWidget {
  const _BudgetPotsHeroCard({required this.snapshot});

  final TreasuryBudgetPotsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money = NumberFormat.currency(symbol: '£', decimalDigits: 2);

    return Container(
      decoration: _cardDecoration(highlighted: true),
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 900;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Pots',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A calm place to think about where money sits before it moves anywhere else.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusPill(
                    label: '${snapshot.pots.length} pots visible',
                    accent: AppColours.darkSecondary,
                  ),
                  _StatusPill(
                    label: money.format(snapshot.projectSpendTotal),
                    accent: AppColours.darkPurple,
                  ),
                  _StatusPill(
                    label:
                        'Recurring ${money.format(snapshot.subscriptionTotal)}',
                    accent: AppColours.darkAccent,
                  ),
                ],
              ),
            ],
          );

          final right = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroMetricCard(
                label: 'Monthly committed spend',
                value: money.format(
                  snapshot.projectSpendTotal + snapshot.subscriptionTotal,
                ),
                note:
                    'A simple combined read of project spend and recurring costs.',
                accent: AppColours.darkSuccess,
              ),
              const SizedBox(height: 12),
              _HeroMetricCard(
                label: 'Tracked states',
                value:
                    '${snapshot.pots.where((pot) => pot.itemCount > 0).length} active pots',
                note:
                    'Each pot stays calm and visible so Hayley knows where attention sits.',
                accent: AppColours.darkSecondary,
              ),
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(height: 18), right],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 20),
              SizedBox(width: 380, child: right),
            ],
          );
        },
      ),
    );
  }
}

class _BudgetOverviewCard extends StatelessWidget {
  const _BudgetOverviewCard({required this.snapshot});

  final TreasuryBudgetPotsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.view_comfy_alt_outlined,
            title: 'How Treasury is grouped',
          ),
          const SizedBox(height: 12),
          Text(
            'These pots are a calm planning layer built from the current Treasury states. They keep the money picture readable without needing a new file format yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetPotCard extends StatelessWidget {
  const _BudgetPotCard({required this.pot});

  final TreasuryBudgetPot pot;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForKind(pot.kind);

    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForKind(pot.kind), color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pot.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusPill(label: '${pot.itemCount}', accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pot.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (pot.items.isEmpty)
            Text(
              'Nothing is listed here yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            )
          else
            ...pot.items
                .take(3)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.radio_button_unchecked,
                          size: 16,
                          color: AppColours.darkAmber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (pot.items.length > 3) ...[
            const SizedBox(height: 4),
            Text(
              '+ ${pot.items.length - 3} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetPotsFooterCard extends StatelessWidget {
  const _BudgetPotsFooterCard({required this.snapshot});

  final TreasuryBudgetPotsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.info_outline, title: 'Notes'),
          const SizedBox(height: 12),
          Text(
            snapshot.issues.isEmpty
                ? 'Budget Pots is using the live Treasury summary and stays local-first.'
                : snapshot.issues.join('\n'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetPotsErrorCard extends StatelessWidget {
  const _BudgetPotsErrorCard({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.info_outline,
                title: 'Budget Pots',
              ),
              const SizedBox(height: 12),
              Text(
                'Budget Pots could not load right now.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({
    required this.label,
    required this.value,
    required this.note,
    required this.accent,
  });

  final String label;
  final String value;
  final String note;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColours.darkSecondary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
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

Color _accentForKind(TreasuryBudgetPotKind kind) {
  return switch (kind) {
    TreasuryBudgetPotKind.safe => AppColours.darkSuccess,
    TreasuryBudgetPotKind.watch => AppColours.darkAmber,
    TreasuryBudgetPotKind.pause => const Color(0xFFE26B6B),
    TreasuryBudgetPotKind.decision => AppColours.darkSecondary,
    TreasuryBudgetPotKind.future => AppColours.darkPurple,
    TreasuryBudgetPotKind.archived => AppColours.darkMutedText,
  };
}

IconData _iconForKind(TreasuryBudgetPotKind kind) {
  return switch (kind) {
    TreasuryBudgetPotKind.safe => Icons.savings_outlined,
    TreasuryBudgetPotKind.watch => Icons.visibility_outlined,
    TreasuryBudgetPotKind.pause => Icons.pause_circle_outline,
    TreasuryBudgetPotKind.decision => Icons.gavel_outlined,
    TreasuryBudgetPotKind.future => Icons.auto_awesome_outlined,
    TreasuryBudgetPotKind.archived => Icons.archive_outlined,
  };
}

BoxDecoration _cardDecoration({bool highlighted = false}) {
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
