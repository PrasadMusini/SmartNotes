import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnotes/main.dart';

void main() {
  testWidgets('App boots to notes home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartNotesApp()));
    await tester.pumpAndSettle();

    expect(find.text('All Notes'), findsOneWidget);
  });
}
