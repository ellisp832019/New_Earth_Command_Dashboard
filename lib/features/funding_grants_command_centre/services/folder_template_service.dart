import 'dart:io';

import 'package:path/path.dart' as path;

import '../data/funding_grants_paths.dart';
import '../models/grant_record.dart';
import '../models/grant_status.dart';

class FolderTemplateService {
  Future<String> createGrantFolder({
    required String targetFolderPath,
    required GrantRecord grant,
  }) async {
    final target = Directory(_uniqueFolderPath(targetFolderPath));
    await target.create(recursive: true);

    for (final entry in _templateFileMap.entries) {
      final file = File(path.join(target.path, entry.key));
      final content = await _renderTemplate(entry.key, entry.value, grant);
      await file.parent.create(recursive: true);
      await file.writeAsString(content, flush: true);
    }

    await Directory(path.join(target.path, 'attachments')).create(
      recursive: true,
    );

    return target.path;
  }

  Future<String> moveGrantFolder({
    required String sourceFolderPath,
    required String targetFolderPath,
  }) async {
    final source = Directory(sourceFolderPath);
    if (!await source.exists()) {
      return targetFolderPath;
    }

    final target = Directory(_uniqueFolderPath(targetFolderPath));
    if (source.path == target.path) {
      return source.path;
    }

    await target.parent.create(recursive: true);
    return source.rename(target.path).then((folder) => folder.path);
  }

  Future<String> _renderTemplate(
    String fileName,
    String sourceTemplate,
    GrantRecord grant,
  ) async {
    final templateFile = File(
      path.join(FundingGrantsPaths.moduleTemplatesPath, sourceTemplate),
    );
    if (await templateFile.exists()) {
      final content = await templateFile.readAsString();
      if (fileName == 'README.md') {
        return _renderReadme(grant);
      }
      return content;
    }

    return _fallbackTemplate(fileName, grant);
  }

  String _fallbackTemplate(String fileName, GrantRecord grant) {
    switch (fileName) {
      case 'README.md':
        return _renderReadme(grant);
      case 'deadlines.md':
        return [
          '# Deadlines',
          '',
          '## Milestones',
          '',
          '- Application deadline:',
          '- Evidence deadline:',
          '- Decision date:',
          '- Reporting deadline:',
        ].join('\n');
      default:
        return '';
    }
  }

  String _renderReadme(GrantRecord grant) {
    return [
      '# ${grant.id} - ${grant.grantName}',
      '',
      '## Overview',
      '',
      '- Project: ${grant.project}',
      '- Funding body: ${grant.fundingBody}',
      '- Funding type: ${grant.fundingType}',
      '- Requested: ${grant.amountRequested.toStringAsFixed(0)}',
      '- Status: ${grant.status.label}',
      '- Priority: ${grant.priority}',
      '- Owner: ${grant.owner}',
      '- Deadline: ${grant.deadline}',
      '',
      '## Next action',
      '',
      grant.nextAction.isEmpty
          ? '- Add the next useful action.'
          : '- ${grant.nextAction}',
      '',
      '## Notes',
      '',
      grant.notes.isEmpty
          ? '- Add context, partner notes, and evidence links here.'
          : grant.notes,
      '',
      '## Source of truth',
      '',
      '- Omega OS tracker JSON and CSV remain the canonical records.',
      '- Attachments live inside the local grant folder.',
    ].join('\n');
  }

  String _uniqueFolderPath(String targetFolderPath) {
    final candidate = Directory(targetFolderPath);
    if (!candidate.existsSync()) {
      return targetFolderPath;
    }

    final parent = path.dirname(targetFolderPath);
    final leaf = path.basename(targetFolderPath);
    var suffix = 2;
    while (true) {
      final attempt = path.join(parent, '${leaf}_$suffix');
      if (!Directory(attempt).existsSync()) {
        return attempt;
      }
      suffix += 1;
    }
  }

  static const Map<String, String> _templateFileMap = {
    'README.md': 'README.md',
    'application.md': 'application_template.md',
    'budget.md': 'budget_template.md',
    'evidence_pack.md': 'evidence_pack_template.md',
    'deadlines.md': 'deadlines.md',
    'submission_notes.md': 'submission_notes_template.md',
    'partner_letters.md': 'partner_letter_template.md',
    'risk_register.md': 'risk_register_template.md',
    'lessons_learned.md': 'lessons_learned_template.md',
  };
}
