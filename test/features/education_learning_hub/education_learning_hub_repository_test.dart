import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/education_learning_hub/application/education_services.dart';
import 'package:new_earth_command_dashboard/features/education_learning_hub/data/education_repository.dart';

void main() {
  test('education repository loads the local mock snapshot', () async {
    final repository = LocalEducationRepository();
    final snapshot = await repository.loadSnapshot();

    expect(snapshot.pathwayCount, greaterThanOrEqualTo(5));
    expect(snapshot.lessonCount, greaterThanOrEqualTo(10));
    expect(snapshot.projectCount, greaterThanOrEqualTo(3));
    expect(snapshot.learnerCount, greaterThanOrEqualTo(2));
    expect(snapshot.skillLibrary, isNotEmpty);
    expect(snapshot.contentSources, isNotEmpty);
    expect(
      snapshot.contentSources.where((source) => source.category.isNotEmpty),
      isNotEmpty,
    );

    final searchHits = SearchService(snapshot).search('MicroGrow');
    expect(searchHits, isNotEmpty);
    expect(searchHits.first.kind, isNotEmpty);

    final tutorResponse = TutorService(snapshot).respond('How do I start?');
    expect(tutorResponse.summary, isNotEmpty);
    expect(tutorResponse.practiceQuestions, isNotEmpty);
  });
}
