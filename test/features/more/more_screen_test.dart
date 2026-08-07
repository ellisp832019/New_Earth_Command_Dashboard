import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/more/presentation/more_screen.dart';

void main() {
  testWidgets('more screen shows the about and help tile', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsAtLeastNWidgets(1));
    final moreScreenList = find.byKey(const Key('moreScreenList'));

    for (
      var i = 0;
      i < 6 && find.text('About & Help').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(moreScreenList, const Offset(0, -480));
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();
    expect(find.text('About & Help'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'Open the Dashboard guide centre, support links, templates, and helper pages.',
      ),
      findsAtLeastNWidgets(1),
    );
  });
}
