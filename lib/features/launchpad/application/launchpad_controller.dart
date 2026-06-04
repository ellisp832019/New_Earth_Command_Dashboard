import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/launchpad_phase2_models.dart';
import '../data/launchpad_models.dart';
import '../data/launchpad_repository.dart';

final launchpadRepositoryProvider = Provider<LaunchpadRepository>((ref) {
  return LaunchpadRepository();
});

final launchpadWorkspaceProvider = FutureProvider<LaunchpadWorkspace>((ref) {
  final repository = ref.watch(launchpadRepositoryProvider);
  return repository.loadWorkspace();
});

final launchpadCampaignProvider =
    FutureProvider.family<LaunchpadCampaignRecord?, String>((ref, campaignId) async {
  final repository = ref.watch(launchpadRepositoryProvider);
  final workspace = await repository.loadWorkspace();
  return workspace.campaignById(campaignId);
});

final launchpadActiveCampaignProvider =
    FutureProvider<LaunchpadCampaignRecord?>((ref) async {
  final workspace = await ref.watch(launchpadWorkspaceProvider.future);
  return workspace.campaigns.firstWhere(
    (campaign) => campaign.status != LaunchpadCampaignStatus.archived,
    orElse: () => workspace.campaigns.isEmpty
        ? LaunchpadCampaignRecord(
            id: '',
            name: '',
            project: '',
            type: 'other',
            status: LaunchpadCampaignStatus.archived,
            fundingGoalGbp: 0,
            launchDate: null,
            owner: '',
            summary: '',
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
            progressPercentage: 0,
            rewards: const <LaunchpadRewardTier>[],
            storyBlocks: const <LaunchpadStoryBlock>[],
            readinessItems: const <LaunchpadReadinessItem>[],
            risks: const <LaunchpadRiskRecord>[],
            phase2Records: const <LaunchpadPhase2Record>[],
            finance: const LaunchpadCampaignFinanceModel(
              fundingGoalGbp: 0,
              manufacturingCostsGbp: 0,
              shippingGbp: 0,
              vatPercent: 0,
              kickstarterFeePercent: 0,
              paymentFeePercent: 0,
              contingencyPercent: 0,
              fixedCostsGbp: 0,
            ),
          )
        : workspace.campaigns.first,
  );
});
