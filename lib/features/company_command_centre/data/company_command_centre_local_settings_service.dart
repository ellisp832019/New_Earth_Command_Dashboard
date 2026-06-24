import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final companyCommandCentreLocalSettingsProvider =
    FutureProvider<CompanyCommandCentreLocalSettings>((ref) {
      return const CompanyCommandCentreLocalSettingsService().load();
    });

class CompanyCommandCentreLocalSettings {
  const CompanyCommandCentreLocalSettings({required this.linkedinCompanyUrl});

  factory CompanyCommandCentreLocalSettings.defaults() {
    return const CompanyCommandCentreLocalSettings(linkedinCompanyUrl: '');
  }

  final String linkedinCompanyUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'linkedinCompanyUrl': linkedinCompanyUrl};
  }

  factory CompanyCommandCentreLocalSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyCommandCentreLocalSettings(
      linkedinCompanyUrl: (json['linkedinCompanyUrl'] as String? ?? '').trim(),
    );
  }
}

class CompanyCommandCentreLocalSettingsService {
  const CompanyCommandCentreLocalSettingsService();

  Future<CompanyCommandCentreLocalSettings> load() async {
    final file = await _settingsFile();
    if (!await file.exists()) {
      return CompanyCommandCentreLocalSettings.defaults();
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return CompanyCommandCentreLocalSettings.fromJson(decoded);
      }
    } catch (_) {
      // Fall back to defaults when the local settings file is missing or corrupt.
    }

    return CompanyCommandCentreLocalSettings.defaults();
  }

  Future<void> save(CompanyCommandCentreLocalSettings settings) async {
    final file = await _settingsFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(settings.toJson()),
      flush: true,
    );
  }

  Future<File> _settingsFile() async {
    final directory = await getApplicationSupportDirectory();
    return File(
      path.join(
        directory.path,
        'company_command_centre',
        'company_command_centre_local_settings.json',
      ),
    );
  }
}
