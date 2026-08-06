import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/more/presentation/more_screen.dart';

void main() {
  testWidgets('more screen shows the about and help tile', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsAtLeastNWidgets(1));
    await tester.scrollUntilVisible(
      find.text('About & Help'),
      200,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
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
