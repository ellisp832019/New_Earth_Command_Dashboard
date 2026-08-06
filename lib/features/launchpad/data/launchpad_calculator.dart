import 'dart:math' as math;

import 'launchpad_models.dart';

class LaunchpadFinancialSummary {
  const LaunchpadFinancialSummary({
    required this.grossFundingGbp,
    required this.platformFeesGbp,
    required this.paymentFeesGbp,
    required this.vatReserveGbp,
    required this.contingencyReserveGbp,
    required this.manufacturingCostsGbp,
    required this.shippingGbp,
    required this.fixedCostsGbp,
    required this.netAvailableFundsGbp,
    required this.profitMarginPercent,
    required this.breakEvenBackers,
    required this.riskIndicators,
  });

  final double grossFundingGbp;
  final double platformFeesGbp;
  final double paymentFeesGbp;
  final double vatReserveGbp;
  final double contingencyReserveGbp;
  final double manufacturingCostsGbp;
  final double shippingGbp;
  final double fixedCostsGbp;
  final double netAvailableFundsGbp;
  final double profitMarginPercent;
  final int breakEvenBackers;
  final List<String> riskIndicators;
}

class LaunchpadReadinessSummary {
  const LaunchpadReadinessSummary({
    required this.hardwarePercent,
    required this.firmwarePercent,
    required this.softwarePercent,
    required this.manufacturingPercent,
    required this.documentationPercent,
    required this.marketingPercent,
    required this.overallPercent,
  });

  final double hardwarePercent;
  final double firmwarePercent;
  final double softwarePercent;
  final double manufacturingPercent;
  final double documentationPercent;
  final double marketingPercent;
  final double overallPercent;
}

LaunchpadFinancialSummary calculateLaunchpadFinancialSummary(
  LaunchpadCampaignRecord campaign,
) {
  final finance = campaign.finance;
  final grossFundingGbp = finance.fundingGoalGbp;
  final platformFeesGbp = grossFundingGbp * finance.kickstarterFeePercent / 100;
  final paymentFeesGbp = grossFundingGbp * finance.paymentFeePercent / 100;
  final vatReserveGbp = grossFundingGbp * finance.vatPercent / 100;
  final contingencyReserveGbp =
      grossFundingGbp * finance.contingencyPercent / 100;
  final netAvailableFundsGbp = grossFundingGbp -
      platformFeesGbp -
      paymentFeesGbp -
      vatReserveGbp -
      contingencyReserveGbp -
      finance.manufacturingCostsGbp -
      finance.shippingGbp -
      finance.fixedCostsGbp;

  final averageContribution = _averageContribution(campaign.rewards);
  final breakEvenBase =
      platformFeesGbp +
      paymentFeesGbp +
      vatReserveGbp +
      contingencyReserveGbp +
      finance.manufacturingCostsGbp +
      finance.shippingGbp +
      finance.fixedCostsGbp;
  final breakEvenBackers = averageContribution <= 0
      ? 0
      : math.max(1, (breakEvenBase / averageContribution).ceil());

  final riskIndicators = <String>[
    if (netAvailableFundsGbp < 0)
      'The plan is underfunded by £${netAvailableFundsGbp.abs().toStringAsFixed(0)}.',
    if (finance.contingencyPercent < 10)
      'Contingency is below the safer 10% buffer.',
    if (finance.vatPercent <= 0)
      'VAT reserve has not been configured yet.',
    if (averageContribution > 0 && averageContribution < 20)
      'Average reward margin is thin.',
    if (breakEvenBackers > 500)
      'Break-even depends on a large backer count.',
    if (finance.shippingGbp > finance.manufacturingCostsGbp * 0.4)
      'Shipping is a significant share of manufacturing cost.',
  ];

  final profitMarginPercent = grossFundingGbp <= 0
      ? 0.0
      : (netAvailableFundsGbp / grossFundingGbp) * 100;

  return LaunchpadFinancialSummary(
    grossFundingGbp: grossFundingGbp,
    platformFeesGbp: platformFeesGbp,
    paymentFeesGbp: paymentFeesGbp,
    vatReserveGbp: vatReserveGbp,
    contingencyReserveGbp: contingencyReserveGbp,
    manufacturingCostsGbp: finance.manufacturingCostsGbp,
    shippingGbp: finance.shippingGbp,
    fixedCostsGbp: finance.fixedCostsGbp,
    netAvailableFundsGbp: netAvailableFundsGbp,
    profitMarginPercent: profitMarginPercent,
    breakEvenBackers: breakEvenBackers,
    riskIndicators: riskIndicators,
  );
}

LaunchpadReadinessSummary calculateLaunchpadReadinessSummary(
  List<LaunchpadReadinessItem> items,
) {
  double scoreFor(String category) {
    final categoryItems = items
        .where((item) => item.category.trim().toLowerCase() == category)
        .toList(growable: false);
    if (categoryItems.isEmpty) {
      return 0;
    }

  final total = categoryItems.fold<double>(
      0.0,
      (sum, item) => sum + _statusScore(item.status),
    );
    return total / categoryItems.length;
  }

  final hardwarePercent = scoreFor('hardware');
  final firmwarePercent = scoreFor('firmware');
  final softwarePercent = scoreFor('software');
  final manufacturingPercent = scoreFor('manufacturing');
  final documentationPercent = scoreFor('documentation');
  final marketingPercent = scoreFor('marketing');

  final summaryValues = [
    hardwarePercent,
    firmwarePercent,
    softwarePercent,
    manufacturingPercent,
    documentationPercent,
    marketingPercent,
  ];
  final nonZeroValues = summaryValues.where((value) => value > 0).toList();
  final overallPercent = nonZeroValues.isEmpty
      ? 0.0
      : nonZeroValues.fold<double>(0, (sum, value) => sum + value) /
          nonZeroValues.length;

  return LaunchpadReadinessSummary(
    hardwarePercent: hardwarePercent,
    firmwarePercent: firmwarePercent,
    softwarePercent: softwarePercent,
    manufacturingPercent: manufacturingPercent,
    documentationPercent: documentationPercent,
    marketingPercent: marketingPercent,
    overallPercent: overallPercent,
  );
}

double _statusScore(String status) {
  switch (status.trim().toLowerCase()) {
    case 'done':
      return 100;
    case 'in progress':
    case 'in-progress':
      return 60;
    case 'draft':
      return 35;
    case 'todo':
      return 0;
    case 'blocked':
      return 10;
    default:
      return 25;
  }
}

double _averageContribution(List<LaunchpadRewardTier> tiers) {
  final contributing = tiers.where((tier) => tier.priceGbp > 0).toList();
  if (contributing.isEmpty) {
    return 0;
  }

  final total = contributing.fold<double>(
    0.0,
    (sum, tier) =>
        sum + tier.priceGbp - tier.estimatedCogsGbp - tier.estimatedShippingGbp,
  );
  return total / contributing.length;
}
