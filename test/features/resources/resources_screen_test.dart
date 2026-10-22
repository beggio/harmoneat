import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/features/resources/presentation/all_chords_screen.dart';
import 'package:harmoneat/features/resources/presentation/circle_of_fifths_screen.dart';
import 'package:harmoneat/features/resources/presentation/resources_list_screen.dart';
import 'package:harmoneat/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  testWidgets('resources list shows both tools and navigates to each', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ResourcesListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Circle of Fifths'), findsOneWidget);
    expect(find.text('All Major & Minor Chords'), findsOneWidget);

    await tester.tap(find.text('Circle of Fifths'));
    await tester.pumpAndSettle();
    expect(find.byType(CircleOfFifthsScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('All Major & Minor Chords'));
    await tester.pumpAndSettle();
    expect(find.byType(AllChordsScreen), findsOneWidget);
  });

  testWidgets('tapping a key on the Circle of Fifths selects it', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CircleOfFifthsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tap a key to see its details'), findsOneWidget);

    await tester.tap(find.text('D').first);
    await tester.pumpAndSettle();

    expect(find.text('D major / b minor'), findsOneWidget);
    expect(find.textContaining('2 sharps: F♯, C♯'), findsOneWidget);
    // D's dominant (V, clockwise) is A; subdominant (IV, counterclockwise)
    // is G.
    expect(find.textContaining('A — one step clockwise'), findsOneWidget);
    expect(
      find.textContaining('G — one step counterclockwise'),
      findsOneWidget,
    );
  });

  testWidgets('all chords screen lists every root with major and minor', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const AllChordsScreen()));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable);
    for (final root in ['C', 'D', 'E', 'F', 'G', 'A', 'B']) {
      await tester.scrollUntilVisible(
        find.text('$root major'),
        200,
        scrollable: scrollable,
      );
      expect(find.text('$root major'), findsOneWidget);
      expect(find.text('$root minor'), findsOneWidget);
      if (root == 'F') {
        // F major/minor are both the E-shape barre at fret 1.
        expect(find.text('1fr'), findsWidgets);
      }
    }
  });
}
