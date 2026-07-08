// Tests for the Phase 4A Sleep Timer changes:
//  - the duration options list matches the design (10/20/30/45/60 minutes)
//  - the chip's idle vs. counting-down label rendering
//
// Deliberately does NOT tap the chip to open the bottom sheet: selecting an
// option calls SleepTimerController.start(), which writes to Hive via
// LocalStorageService - out of scope for a pure widget-rendering test.
//
// Note: only one EasyLocalization tree is mounted for the whole file.
// Mounting a fresh EasyLocalization instance per test was observed to
// silently render an empty tree on the second+ mount within the same test
// process, so state changes are driven directly through the ProviderContainer
// instead of re-pumping a new widget tree per scenario.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medyo/features/core/logic/sleep_timer_provider.dart';
import 'package:medyo/features/core/views/player_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('sleep timer options match the design (10/20/30/45/60 minutes)', () {
    expect(SleepTimerButton.options, [10, 20, 30, 45, 60]);
  });

  testWidgets(
      'sleep timer chip shows idle label, then a live mm:ss countdown',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: EasyLocalization(
          path: 'assets/translations',
          supportedLocales: const [Locale('en', 'US')],
          fallbackLocale: const Locale('en', 'US'),
          child: Builder(
            builder: (context) {
              return ScreenUtilInit(
                designSize: const Size(390, 844),
                builder: (context, _) => MaterialApp(
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: const Scaffold(body: SleepTimerButton()),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Idle: no timer running yet.
    expect(find.text('Sleep Timer'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Drive the same provider the widget watches, as if a timer just
    // started - the chip should switch to a live mm:ss countdown.
    container.read(sleepTimerRemainingProvider.notifier).state =
        const Duration(minutes: 9, seconds: 5);
    await tester.pump();

    expect(find.text('9:05'), findsOneWidget);
    expect(find.text('Sleep Timer'), findsNothing);
    expect(tester.takeException(), isNull);

    // Timer expires / is cancelled - chip should go back to idle.
    container.read(sleepTimerRemainingProvider.notifier).state = null;
    await tester.pump();

    expect(find.text('Sleep Timer'), findsOneWidget);
    expect(find.text('9:05'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
