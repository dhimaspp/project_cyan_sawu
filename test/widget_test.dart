import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_cyan_sawu/src/app.dart';

void main() {
  testWidgets('App renders Project Cyan title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that our title matches
    expect(find.text('Project Cyan'), findsOneWidget);
    expect(find.text('Sawu Seagrass dMRV'), findsOneWidget);
  });
}
