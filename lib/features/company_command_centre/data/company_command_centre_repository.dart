import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'company_command_centre_config.dart';

final companyCommandCentreRepositoryProvider =
    Provider<CompanyCommandCentreRepository>(
      (ref) => const CompanyCommandCentreRepository(),
    );

final companyCommandCentreSnapshotProvider =
    FutureProvider<CompanyCommandCentreSnapshot>((ref) {
      return ref.read(companyCommandCentreRepositoryProvider).load();
    });

class CompanyCommandCentreRepository {
  const CompanyCommandCentreRepository();

  Future<CompanyCommandCentreSnapshot> load() async {
    final overview = await _readOverview();
    final actionBoard = await _readActionBoard();
    final productPortfolio = await _readProductPortfolio();
    final grantsPipeline = await _readGrantsPipeline();
    final omegaOsPath = overview.omegaOsPath.isNotEmpty
        ? overview.omegaOsPath
        : companyCommandCentreOmegaOsPath;
    final sourcePathExists = Directory(omegaOsPath).existsSync();
    final configExists = File(companyCommandCentreModuleConfigPath).existsSync();
    final configSnapshot = await _readJsonMap(companyCommandCentreModuleConfigPath);
    final configuredPath = _stringValue(configSnapshot, const [
      'omegaPath',
      'omega_os_path',
    ]);

    return CompanyCommandCentreSnapshot(
      overview: overview.copyWith(
        omegaOsPath: omegaOsPath,
        omegaOsPathExists: sourcePathExists,
      ),
      actionBoard: actionBoard,
      productPortfolio: productPortfolio,
      grantsPipeline: grantsPipeline,
      moduleConfigPath: companyCommandCentreModuleConfigPath,
      moduleConfigExists: configExists,
      configuredOmegaPath: configuredPath.isNotEmpty
          ? configuredPath
          : companyCommandCentreOmegaOsPath,
    );
  }

  Future<CompanyOverviewData> _readOverview() async {
    final raw = await _readJsonMap(companyCommandCentreOverviewPath);
    return CompanyOverviewData(
      companyName:
          _stringValue(raw, const ['company_name', 'companyName'])
              .trim(),
      companyNumber:
          _stringValue(raw, const ['company_number', 'companyNumber'])
              .trim(),
      domain: _stringValue(raw, const ['domain']).trim(),
      bank: _stringValue(raw, const ['bank']).trim(),
      omegaOsPath:
          _stringValue(raw, const ['omega_os_path', 'omegaOsPath']).trim(),
      status: _stringValue(raw, const ['status']).trim(),
      focus: _stringList(raw, const ['focus']),
      nextMilestone:
          _stringValue(raw, const ['next_milestone', 'nextMilestone']).trim(),
    );
  }

  Future<List<CompanyActionItemData>> _readActionBoard() async {
    final raw = await _readJsonList(companyCommandCentreActionBoardPath);
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => CompanyActionItemData(
            id: _stringValue(item, const ['id']).trim(),
            title: _stringValue(item, const ['title']).trim(),
            lane: _stringValue(item, const ['lane']).trim(),
            area: _stringValue(item, const ['area']).trim(),
            priority: _stringValue(item, const ['priority']).trim(),
          ),
        )
        .toList(growable: false);
  }

  Future<List<CompanyProductItemData>> _readProductPortfolio() async {
    final raw = await _readJsonList(companyCommandCentreProductPortfolioPath);
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => CompanyProductItemData(
            name: _stringValue(item, const ['name']).trim(),
            type: _stringValue(item, const ['type']).trim(),
            status: _stringValue(item, const ['status']).trim(),
            commercialReadiness: _stringValue(
              item,
              const ['commercial_readiness', 'commercialReadiness'],
            ).trim(),
          ),
        )
        .toList(growable: false);
  }

  Future<List<CompanyGrantItemData>> _readGrantsPipeline() async {
    final raw = await _readJsonList(companyCommandCentreGrantsPipelinePath);
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => CompanyGrantItemData(
            id: _stringValue(item, const ['id']).trim(),
            name: _stringValue(item, const ['name']).trim(),
            stage: _stringValue(item, const ['stage']).trim(),
            fit: _stringValue(item, const ['fit']).trim(),
            nextAction: _stringValue(item, const ['next_action', 'nextAction'])
                .trim(),
          ),
        )
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _readJsonMap(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  Future<List<dynamic>> _readJsonList(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return <dynamic>[];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is List) {
        return decoded;
      }
    } catch (_) {
      return <dynamic>[];
    }
    return <dynamic>[];
  }

  String _stringValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  List<String> _stringList(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        return value
            .whereType<Object?>()
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
    }
    return const [];
  }
}

class CompanyCommandCentreSnapshot {
  const CompanyCommandCentreSnapshot({
    required this.overview,
    required this.actionBoard,
    required this.productPortfolio,
    required this.grantsPipeline,
    required this.moduleConfigPath,
    required this.moduleConfigExists,
    required this.configuredOmegaPath,
  });

  final CompanyOverviewData overview;
  final List<CompanyActionItemData> actionBoard;
  final List<CompanyProductItemData> productPortfolio;
  final List<CompanyGrantItemData> grantsPipeline;
  final String moduleConfigPath;
  final bool moduleConfigExists;
  final String configuredOmegaPath;
}

class CompanyOverviewData {
  const CompanyOverviewData({
    required this.companyName,
    required this.companyNumber,
    required this.domain,
    required this.bank,
    required this.omegaOsPath,
    required this.status,
    required this.focus,
    required this.nextMilestone,
    this.omegaOsPathExists = false,
  });

  final String companyName;
  final String companyNumber;
  final String domain;
  final String bank;
  final String omegaOsPath;
  final String status;
  final List<String> focus;
  final String nextMilestone;
  final bool omegaOsPathExists;

  CompanyOverviewData copyWith({
    String? companyName,
    String? companyNumber,
    String? domain,
    String? bank,
    String? omegaOsPath,
    String? status,
    List<String>? focus,
    String? nextMilestone,
    bool? omegaOsPathExists,
  }) {
    return CompanyOverviewData(
      companyName: companyName ?? this.companyName,
      companyNumber: companyNumber ?? this.companyNumber,
      domain: domain ?? this.domain,
      bank: bank ?? this.bank,
      omegaOsPath: omegaOsPath ?? this.omegaOsPath,
      status: status ?? this.status,
      focus: focus ?? this.focus,
      nextMilestone: nextMilestone ?? this.nextMilestone,
      omegaOsPathExists: omegaOsPathExists ?? this.omegaOsPathExists,
    );
  }
}

class CompanyActionItemData {
  const CompanyActionItemData({
    required this.id,
    required this.title,
    required this.lane,
    required this.area,
    required this.priority,
  });

  final String id;
  final String title;
  final String lane;
  final String area;
  final String priority;
}

class CompanyProductItemData {
  const CompanyProductItemData({
    required this.name,
    required this.type,
    required this.status,
    required this.commercialReadiness,
  });

  final String name;
  final String type;
  final String status;
  final String commercialReadiness;
}

class CompanyGrantItemData {
  const CompanyGrantItemData({
    required this.id,
    required this.name,
    required this.stage,
    required this.fit,
    required this.nextAction,
  });

  final String id;
  final String name;
  final String stage;
  final String fit;
  final String nextAction;
}
