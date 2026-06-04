import 'dart:convert';

import 'launchpad_phase2_models.dart';

enum LaunchpadCampaignStatus {
  idea,
  research,
  prototype,
  preLaunch,
  live,
  funded,
  manufacturing,
  fulfilment,
  complete,
  archived,
}

extension LaunchpadCampaignStatusLabel on LaunchpadCampaignStatus {
  String get label => switch (this) {
    LaunchpadCampaignStatus.idea => 'Idea',
    LaunchpadCampaignStatus.research => 'Research',
    LaunchpadCampaignStatus.prototype => 'Prototype',
    LaunchpadCampaignStatus.preLaunch => 'Pre-Launch',
    LaunchpadCampaignStatus.live => 'Live',
    LaunchpadCampaignStatus.funded => 'Funded',
    LaunchpadCampaignStatus.manufacturing => 'Manufacturing',
    LaunchpadCampaignStatus.fulfilment => 'Fulfilment',
    LaunchpadCampaignStatus.complete => 'Complete',
    LaunchpadCampaignStatus.archived => 'Archived',
  };

  String get storageValue => name;
}

LaunchpadCampaignStatus launchpadCampaignStatusFromString(String value) {
  switch (value.trim().toLowerCase()) {
    case 'idea':
      return LaunchpadCampaignStatus.idea;
    case 'research':
      return LaunchpadCampaignStatus.research;
    case 'prototype':
      return LaunchpadCampaignStatus.prototype;
    case 'pre-launch':
    case 'prelaunch':
      return LaunchpadCampaignStatus.preLaunch;
    case 'live':
      return LaunchpadCampaignStatus.live;
    case 'funded':
      return LaunchpadCampaignStatus.funded;
    case 'manufacturing':
      return LaunchpadCampaignStatus.manufacturing;
    case 'fulfilment':
    case 'fulfillment':
      return LaunchpadCampaignStatus.fulfilment;
    case 'complete':
      return LaunchpadCampaignStatus.complete;
    case 'archived':
      return LaunchpadCampaignStatus.archived;
    default:
      return LaunchpadCampaignStatus.prototype;
  }
}

class LaunchpadCampaignFinanceModel {
  const LaunchpadCampaignFinanceModel({
    required this.fundingGoalGbp,
    required this.manufacturingCostsGbp,
    required this.shippingGbp,
    required this.vatPercent,
    required this.kickstarterFeePercent,
    required this.paymentFeePercent,
    required this.contingencyPercent,
    required this.fixedCostsGbp,
  });

  final double fundingGoalGbp;
  final double manufacturingCostsGbp;
  final double shippingGbp;
  final double vatPercent;
  final double kickstarterFeePercent;
  final double paymentFeePercent;
  final double contingencyPercent;
  final double fixedCostsGbp;

  LaunchpadCampaignFinanceModel copyWith({
    double? fundingGoalGbp,
    double? manufacturingCostsGbp,
    double? shippingGbp,
    double? vatPercent,
    double? kickstarterFeePercent,
    double? paymentFeePercent,
    double? contingencyPercent,
    double? fixedCostsGbp,
  }) {
    return LaunchpadCampaignFinanceModel(
      fundingGoalGbp: fundingGoalGbp ?? this.fundingGoalGbp,
      manufacturingCostsGbp: manufacturingCostsGbp ?? this.manufacturingCostsGbp,
      shippingGbp: shippingGbp ?? this.shippingGbp,
      vatPercent: vatPercent ?? this.vatPercent,
      kickstarterFeePercent:
          kickstarterFeePercent ?? this.kickstarterFeePercent,
      paymentFeePercent: paymentFeePercent ?? this.paymentFeePercent,
      contingencyPercent: contingencyPercent ?? this.contingencyPercent,
      fixedCostsGbp: fixedCostsGbp ?? this.fixedCostsGbp,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'funding_goal_gbp': fundingGoalGbp,
      'manufacturing_costs_gbp': manufacturingCostsGbp,
      'shipping_gbp': shippingGbp,
      'vat_percent': vatPercent,
      'kickstarter_fee_percent': kickstarterFeePercent,
      'payment_fee_percent': paymentFeePercent,
      'contingency_percent': contingencyPercent,
      'fixed_costs_gbp': fixedCostsGbp,
    };
  }

  factory LaunchpadCampaignFinanceModel.fromJson(Map<String, dynamic> json) {
    return LaunchpadCampaignFinanceModel(
      fundingGoalGbp: _doubleValue(json['funding_goal_gbp'], fallback: 0),
      manufacturingCostsGbp: _doubleValue(
        json['manufacturing_costs_gbp'],
        fallback: 0,
      ),
      shippingGbp: _doubleValue(json['shipping_gbp'], fallback: 0),
      vatPercent: _doubleValue(json['vat_percent'], fallback: 0),
      kickstarterFeePercent: _doubleValue(
        json['kickstarter_fee_percent'],
        fallback: 0,
      ),
      paymentFeePercent: _doubleValue(
        json['payment_fee_percent'],
        fallback: 0,
      ),
      contingencyPercent: _doubleValue(
        json['contingency_percent'],
        fallback: 0,
      ),
      fixedCostsGbp: _doubleValue(json['fixed_costs_gbp'], fallback: 0),
    );
  }
}

class LaunchpadRewardTier {
  const LaunchpadRewardTier({
    required this.id,
    required this.campaignId,
    required this.name,
    required this.priceGbp,
    required this.quantityLimit,
    required this.estimatedCogsGbp,
    required this.estimatedShippingGbp,
    required this.deliveryEstimate,
    required this.notes,
  });

  final String id;
  final String campaignId;
  final String name;
  final double priceGbp;
  final int? quantityLimit;
  final double estimatedCogsGbp;
  final double estimatedShippingGbp;
  final String deliveryEstimate;
  final String notes;

  LaunchpadRewardTier copyWith({
    String? id,
    String? campaignId,
    String? name,
    double? priceGbp,
    int? quantityLimit,
    double? estimatedCogsGbp,
    double? estimatedShippingGbp,
    String? deliveryEstimate,
    String? notes,
  }) {
    return LaunchpadRewardTier(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      name: name ?? this.name,
      priceGbp: priceGbp ?? this.priceGbp,
      quantityLimit: quantityLimit ?? this.quantityLimit,
      estimatedCogsGbp: estimatedCogsGbp ?? this.estimatedCogsGbp,
      estimatedShippingGbp: estimatedShippingGbp ?? this.estimatedShippingGbp,
      deliveryEstimate: deliveryEstimate ?? this.deliveryEstimate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'campaign_id': campaignId,
      'name': name,
      'price_gbp': priceGbp,
      'quantity_limit': quantityLimit,
      'estimated_cogs_gbp': estimatedCogsGbp,
      'estimated_shipping_gbp': estimatedShippingGbp,
      'delivery_estimate': deliveryEstimate,
      'notes': notes,
    };
  }

  factory LaunchpadRewardTier.fromJson(
    Map<String, dynamic> json, {
    required String campaignIdFallback,
  }) {
    return LaunchpadRewardTier(
      id: _stringValue(json['id']),
      campaignId: _firstNonEmpty([
        _stringValue(json['campaign_id']),
        _stringValue(json['campaignId']),
        campaignIdFallback,
      ]),
      name: _stringValue(json['name']),
      priceGbp: _doubleValue(json['price_gbp'], fallback: 0),
      quantityLimit: _nullableIntValue(
        json['quantity_limit'],
        fallback: _nullableIntValue(json['quantityLimit']),
      ),
      estimatedCogsGbp: _doubleValue(json['estimated_cogs_gbp'], fallback: 0),
      estimatedShippingGbp: _doubleValue(
        json['estimated_shipping_gbp'],
        fallback: 0,
      ),
      deliveryEstimate: _firstNonEmpty([
        _stringValue(json['delivery_estimate']),
        _stringValue(json['deliveryEstimate']),
      ]),
      notes: _stringValue(json['notes']),
    );
  }
}

class LaunchpadStoryBlock {
  const LaunchpadStoryBlock({
    required this.id,
    required this.campaignId,
    required this.section,
    required this.title,
    required this.body,
    required this.order,
  });

  final String id;
  final String campaignId;
  final String section;
  final String title;
  final String body;
  final int order;

  LaunchpadStoryBlock copyWith({
    String? id,
    String? campaignId,
    String? section,
    String? title,
    String? body,
    int? order,
  }) {
    return LaunchpadStoryBlock(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      section: section ?? this.section,
      title: title ?? this.title,
      body: body ?? this.body,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'campaign_id': campaignId,
      'section': section,
      'title': title,
      'body': body,
      'order': order,
    };
  }

  factory LaunchpadStoryBlock.fromJson(
    Map<String, dynamic> json, {
    required String campaignIdFallback,
  }) {
    return LaunchpadStoryBlock(
      id: _stringValue(json['id']),
      campaignId: _firstNonEmpty([
        _stringValue(json['campaign_id']),
        _stringValue(json['campaignId']),
        campaignIdFallback,
      ]),
      section: _stringValue(json['section']),
      title: _stringValue(json['title']),
      body: _stringValue(json['body']),
      order: _intValue(json['order'], fallback: 0),
    );
  }
}

class LaunchpadReadinessItem {
  const LaunchpadReadinessItem({
    required this.id,
    required this.campaignId,
    required this.category,
    required this.title,
    required this.status,
    required this.proofLink,
    required this.notes,
  });

  final String id;
  final String campaignId;
  final String category;
  final String title;
  final String status;
  final String proofLink;
  final String notes;

  LaunchpadReadinessItem copyWith({
    String? id,
    String? campaignId,
    String? category,
    String? title,
    String? status,
    String? proofLink,
    String? notes,
  }) {
    return LaunchpadReadinessItem(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      category: category ?? this.category,
      title: title ?? this.title,
      status: status ?? this.status,
      proofLink: proofLink ?? this.proofLink,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'campaign_id': campaignId,
      'category': category,
      'title': title,
      'status': status,
      'proof_link': proofLink,
      'notes': notes,
    };
  }

  factory LaunchpadReadinessItem.fromJson(
    Map<String, dynamic> json, {
    required String campaignIdFallback,
  }) {
    return LaunchpadReadinessItem(
      id: _stringValue(json['id']),
      campaignId: _firstNonEmpty([
        _stringValue(json['campaign_id']),
        _stringValue(json['campaignId']),
        campaignIdFallback,
      ]),
      category: _stringValue(json['category']),
      title: _stringValue(json['title']),
      status: _firstNonEmpty([_stringValue(json['status']), 'Todo']),
      proofLink: _firstNonEmpty([
        _stringValue(json['proof_link']),
        _stringValue(json['proofLink']),
      ]),
      notes: _stringValue(json['notes']),
    );
  }
}

class LaunchpadRiskRecord {
  const LaunchpadRiskRecord({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.severity,
    required this.likelihood,
    required this.mitigation,
    required this.publicNote,
  });

  final String id;
  final String campaignId;
  final String title;
  final String severity;
  final String likelihood;
  final String mitigation;
  final String publicNote;

  LaunchpadRiskRecord copyWith({
    String? id,
    String? campaignId,
    String? title,
    String? severity,
    String? likelihood,
    String? mitigation,
    String? publicNote,
  }) {
    return LaunchpadRiskRecord(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      title: title ?? this.title,
      severity: severity ?? this.severity,
      likelihood: likelihood ?? this.likelihood,
      mitigation: mitigation ?? this.mitigation,
      publicNote: publicNote ?? this.publicNote,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'campaign_id': campaignId,
      'title': title,
      'severity': severity,
      'likelihood': likelihood,
      'mitigation': mitigation,
      'public_note': publicNote,
    };
  }

  factory LaunchpadRiskRecord.fromJson(
    Map<String, dynamic> json, {
    required String campaignIdFallback,
  }) {
    return LaunchpadRiskRecord(
      id: _stringValue(json['id']),
      campaignId: _firstNonEmpty([
        _stringValue(json['campaign_id']),
        _stringValue(json['campaignId']),
        campaignIdFallback,
      ]),
      title: _stringValue(json['title']),
      severity: _firstNonEmpty([_stringValue(json['severity']), 'Medium']),
      likelihood: _firstNonEmpty([_stringValue(json['likelihood']), 'Medium']),
      mitigation: _stringValue(json['mitigation']),
      publicNote: _firstNonEmpty([
        _stringValue(json['public_note']),
        _stringValue(json['publicNote']),
      ]),
    );
  }
}

class LaunchpadCampaignRecord {
  const LaunchpadCampaignRecord({
    required this.id,
    required this.name,
    required this.project,
    required this.type,
    required this.status,
    required this.fundingGoalGbp,
    required this.launchDate,
    required this.owner,
    required this.summary,
    required this.createdAt,
    required this.updatedAt,
    required this.progressPercentage,
    required this.rewards,
    required this.storyBlocks,
    required this.readinessItems,
    required this.risks,
    required this.phase2Records,
    required this.finance,
  });

  final String id;
  final String name;
  final String project;
  final String type;
  final LaunchpadCampaignStatus status;
  final double fundingGoalGbp;
  final DateTime? launchDate;
  final String owner;
  final String summary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int progressPercentage;
  final List<LaunchpadRewardTier> rewards;
  final List<LaunchpadStoryBlock> storyBlocks;
  final List<LaunchpadReadinessItem> readinessItems;
  final List<LaunchpadRiskRecord> risks;
  final List<LaunchpadPhase2Record> phase2Records;
  final LaunchpadCampaignFinanceModel finance;

  LaunchpadCampaignRecord copyWith({
    String? id,
    String? name,
    String? project,
    String? type,
    LaunchpadCampaignStatus? status,
    double? fundingGoalGbp,
    DateTime? launchDate,
    bool clearLaunchDate = false,
    String? owner,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? progressPercentage,
    List<LaunchpadRewardTier>? rewards,
    List<LaunchpadStoryBlock>? storyBlocks,
    List<LaunchpadReadinessItem>? readinessItems,
    List<LaunchpadRiskRecord>? risks,
    List<LaunchpadPhase2Record>? phase2Records,
    LaunchpadCampaignFinanceModel? finance,
  }) {
    return LaunchpadCampaignRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      project: project ?? this.project,
      type: type ?? this.type,
      status: status ?? this.status,
      fundingGoalGbp: fundingGoalGbp ?? this.fundingGoalGbp,
      launchDate: clearLaunchDate ? null : (launchDate ?? this.launchDate),
      owner: owner ?? this.owner,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      rewards: rewards ?? this.rewards,
      storyBlocks: storyBlocks ?? this.storyBlocks,
      readinessItems: readinessItems ?? this.readinessItems,
      risks: risks ?? this.risks,
      phase2Records: phase2Records ?? this.phase2Records,
      finance: finance ?? this.finance,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'project': project,
      'type': type,
      'status': status.storageValue,
      'funding_goal_gbp': fundingGoalGbp,
      'launch_date': launchDate?.toIso8601String(),
      'owner': owner,
      'summary': summary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'progress_percentage': progressPercentage,
      'rewards': rewards.map((reward) => reward.toJson()).toList(growable: false),
      'story_blocks': storyBlocks
          .map((story) => story.toJson())
          .toList(growable: false),
      'readiness_items': readinessItems
          .map((item) => item.toJson())
          .toList(growable: false),
      'risks': risks.map((risk) => risk.toJson()).toList(growable: false),
      'phase2_records': phase2Records
          .map((record) => record.toJson())
          .toList(growable: false),
      'finance': finance.toJson(),
    };
  }

  factory LaunchpadCampaignRecord.fromJson(Map<String, dynamic> json) {
    final campaignId = _stringValue(json['id']);
    return LaunchpadCampaignRecord(
      id: campaignId,
      name: _stringValue(json['name']),
      project: _stringValue(json['project']),
      type: _firstNonEmpty([_stringValue(json['type']), 'other']),
      status: launchpadCampaignStatusFromString(
        _firstNonEmpty([_stringValue(json['status']), 'prototype']),
      ),
      fundingGoalGbp: _doubleValue(json['funding_goal_gbp'], fallback: 0),
      launchDate: _parseDate(json['launch_date']),
      owner: _stringValue(json['owner']),
      summary: _stringValue(json['summary']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      progressPercentage: _intValue(json['progress_percentage'], fallback: 0),
      rewards: _readTypedList<LaunchpadRewardTier>(
        json['rewards'],
        (item) => LaunchpadRewardTier.fromJson(
          item,
          campaignIdFallback: campaignId,
        ),
      ),
      storyBlocks: _readTypedList<LaunchpadStoryBlock>(
        json['story_blocks'],
        (item) => LaunchpadStoryBlock.fromJson(
          item,
          campaignIdFallback: campaignId,
        ),
      ),
      readinessItems: _readTypedList<LaunchpadReadinessItem>(
        json['readiness_items'],
        (item) => LaunchpadReadinessItem.fromJson(
          item,
          campaignIdFallback: campaignId,
        ),
      ),
      risks: _readTypedList<LaunchpadRiskRecord>(
        json['risks'],
        (item) => LaunchpadRiskRecord.fromJson(
          item,
          campaignIdFallback: campaignId,
        ),
      ),
      phase2Records: _readTypedList<LaunchpadPhase2Record>(
        json['phase2_records'],
        (item) => LaunchpadPhase2Record.fromJson(
          item,
          campaignIdFallback: campaignId,
          sectionFallback: '',
        ),
      ),
      finance: json['finance'] is Map<String, dynamic>
          ? LaunchpadCampaignFinanceModel.fromJson(
              json['finance'] as Map<String, dynamic>,
            )
          : const LaunchpadCampaignFinanceModel(
              fundingGoalGbp: 0,
              manufacturingCostsGbp: 0,
              shippingGbp: 0,
              vatPercent: 0,
              kickstarterFeePercent: 0,
              paymentFeePercent: 0,
              contingencyPercent: 0,
              fixedCostsGbp: 0,
            ),
    );
  }
}

class LaunchpadWorkspace {
  const LaunchpadWorkspace({
    required this.configPath,
    required this.runtimePath,
    required this.seedRootPath,
    required this.exportRootPath,
    required this.campaigns,
    required this.issues,
    required this.updatedAt,
  });

  final String configPath;
  final String runtimePath;
  final String seedRootPath;
  final String exportRootPath;
  final List<LaunchpadCampaignRecord> campaigns;
  final List<String> issues;
  final DateTime? updatedAt;

  bool get hasCampaigns => campaigns.isNotEmpty;

  LaunchpadCampaignRecord? campaignById(String campaignId) {
    for (final campaign in campaigns) {
      if (campaign.id == campaignId) {
        return campaign;
      }
    }
    return null;
  }

  LaunchpadWorkspace copyWith({
    String? configPath,
    String? runtimePath,
    String? seedRootPath,
    String? exportRootPath,
    List<LaunchpadCampaignRecord>? campaigns,
    List<String>? issues,
    DateTime? updatedAt,
  }) {
    return LaunchpadWorkspace(
      configPath: configPath ?? this.configPath,
      runtimePath: runtimePath ?? this.runtimePath,
      seedRootPath: seedRootPath ?? this.seedRootPath,
      exportRootPath: exportRootPath ?? this.exportRootPath,
      campaigns: campaigns ?? this.campaigns,
      issues: issues ?? this.issues,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'updated_at': updatedAt?.toIso8601String(),
      'campaigns': campaigns.map((campaign) => campaign.toJson()).toList(
        growable: false,
      ),
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}

String launchpadCampaignSectionLabel(String section) {
  switch (section) {
    case 'dashboard':
      return 'Dashboard';
    case 'campaigns':
      return 'Campaigns';
    case 'rewards':
      return 'Rewards';
    case 'story-builder':
      return 'Story Builder';
    case 'media-studio':
      return 'Media Studio';
    case 'financial-modeller':
      return 'Financial Modeller';
    case 'manufacturing-planner':
      return 'Manufacturing Planner';
    case 'community-builder':
      return 'Community Builder';
    case 'grant-centre':
      return 'Grant Centre';
    case 'investor-crm':
      return 'Investor CRM';
    case 'partner-crm':
      return 'Partner CRM';
    case 'risk-register':
      return 'Risk Register';
    case 'timeline-planner':
      return 'Timeline Planner';
    case 'analytics':
      return 'Analytics';
    case 'archive':
      return 'Archive';
    default:
      return 'Launchpad';
  }
}

List<T> _readTypedList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) factory,
) {
  if (value is! List) {
    return <T>[];
  }

  return value
      .whereType<Map>()
      .map((item) => factory(item.cast<String, dynamic>()))
      .toList(growable: false);
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}

String _stringValue(dynamic value) {
  return value?.toString() ?? '';
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

int _intValue(dynamic value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}

int? _nullableIntValue(dynamic value, {int? fallback}) {
  if (value == null) {
    return fallback;
  }
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    return parsed ?? fallback;
  }
  return fallback;
}

double _doubleValue(dynamic value, {required double fallback}) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}
