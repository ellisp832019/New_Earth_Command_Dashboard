import '../domain/education_models.dart';

class EducationContentPackService {
  const EducationContentPackService();

  static final RegExp semanticVersionPattern = RegExp(r'^\d+\.\d+\.\d+$');

  ContentPackDraft normalize(ContentPackDraft draft) {
    final trimmedDraft = draft.copyWith(
      title: draft.title.trim(),
      version: draft.version.trim(),
      audience: draft.audience.trim(),
      summary: draft.summary.trim(),
      template: draft.template.trim(),
      validationNotes: draft.validationNotes.trim(),
      bundleId: draft.bundleId.trim(),
      checksum: draft.checksum.trim(),
    );
    final validationNotes = buildValidationNotes(trimmedDraft);
    final validationReady = validationNotes.isEmpty;
    final validatedDraft = trimmedDraft.copyWith(
      validationReady: validationReady,
      validationNotes: validationReady
          ? (trimmedDraft.validationNotes.isEmpty
                ? 'Ready for export.'
                : trimmedDraft.validationNotes)
          : validationNotes,
    );
    final checksum = checksumFor(validatedDraft);
    final bundleId = bundleIdFor(validatedDraft, checksum: checksum);
    return validatedDraft.copyWith(checksum: checksum, bundleId: bundleId);
  }

  String buildValidationNotes(ContentPackDraft draft) {
    final notes = <String>[];
    if (draft.title.isEmpty) {
      notes.add('Add a pack title.');
    }
    if (draft.version.isEmpty ||
        !semanticVersionPattern.hasMatch(draft.version)) {
      notes.add('Use semantic versioning like 0.1.0 or 1.0.0.');
    }
    if (draft.audience.isEmpty) {
      notes.add('Choose a primary audience.');
    }
    if (draft.summary.length < 24) {
      notes.add('Add a clearer summary so the pack is easy to review.');
    }
    if (draft.template.isEmpty) {
      notes.add('Choose a template preset.');
    }
    return notes.join(' ');
  }

  String checksumFor(ContentPackDraft draft) {
    final seed = checksumSeedFor(draft);
    var hash = 0x811c9dc5;
    for (final unit in seed.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  String checksumSeedFor(ContentPackDraft draft) {
    return [
      draft.title.trim(),
      draft.version.trim(),
      draft.audience.trim(),
      draft.summary.trim(),
      draft.template.trim(),
      draft.validationReady.toString(),
      draft.validationNotes.trim(),
    ].join('|');
  }

  String bundleIdFor(ContentPackDraft draft, {String? checksum}) {
    final slug = draft.title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final version = draft.version.trim().isEmpty
        ? '0.1.0'
        : draft.version.trim();
    final resolvedChecksum = checksum ?? checksumFor(draft);
    return 'edu-pack-${slug.isEmpty ? 'draft' : slug}-$version-${resolvedChecksum.substring(0, 4)}';
  }
}
