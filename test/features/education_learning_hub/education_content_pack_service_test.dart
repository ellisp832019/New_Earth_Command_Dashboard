import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/education_learning_hub/application/education_content_pack_service.dart';
import 'package:new_earth_command_dashboard/features/education_learning_hub/domain/education_models.dart';

void main() {
  test('content pack service keeps bundle ids and checksums stable', () {
    const service = EducationContentPackService();

    final draftA = ContentPackDraft(
      title: 'Field Pack',
      version: '1.2.3',
      audience: 'Mentor',
      summary: 'A compact offline pack for field learning and handoff.',
      template: 'mentor_pack',
      validationReady: false,
      validationNotes: '',
      updatedAt: DateTime.utc(2026),
    );
    final draftB = ContentPackDraft(
      title: '  Field Pack  ',
      version: ' 1.2.3 ',
      audience: ' Mentor ',
      summary: 'A compact offline pack for field learning and handoff.  ',
      template: 'mentor_pack',
      validationReady: false,
      validationNotes: '',
      updatedAt: DateTime.utc(2026),
    );

    final normalizedA = service.normalize(draftA);
    final normalizedB = service.normalize(draftB);

    expect(normalizedA.bundleId, normalizedB.bundleId);
    expect(normalizedA.checksum, normalizedB.checksum);
    expect(normalizedA.validationReady, isTrue);
    expect(normalizedB.validationReady, isTrue);
    expect(normalizedA.validationNotes, 'Ready for export.');
  });

  test('content pack service reports invalid semantic versions clearly', () {
    const service = EducationContentPackService();

    final normalized = service.normalize(
      ContentPackDraft(
        title: 'Field Pack',
        version: 'v1',
        audience: 'Mentor',
        summary: 'A compact offline pack for field learning and handoff.',
        template: 'mentor_pack',
        validationReady: false,
        validationNotes: '',
        updatedAt: DateTime.utc(2026),
      ),
    );

    expect(normalized.validationReady, isFalse);
    expect(normalized.validationNotes, contains('semantic versioning'));
    expect(
      normalized.validationNotes,
      isNot(contains('Choose a primary audience')),
    );
  });
}
