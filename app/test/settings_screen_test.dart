// Tests for the Phase 8A Settings changes: the new Audio Quality row is
// present, carries a visible "Coming Soon" marker, and is truly inert
// (wrapped in IgnorePointer) rather than a fake-interactive control.
//
// Note: only one EasyLocalization tree is mounted for the whole file, per
// the pattern established in sleep_timer_button_test.dart - a second mount
// within the same test process was observed to silently render empty.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medyo/features/profile/views/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
      'Audio Quality row is visible, marked Coming Soon, and inert',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
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
                  home: const SettingsScreen(),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.text('Audio Quality'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);

    // Language and Sleep Timer Default rows are deliberately excluded
    // per the plan's pre-work note (write-only/unused data today).
    expect(find.text('Language'), findsNothing);
    expect(find.text('Sleep Timer Default'), findsNothing);

    // The row must be genuinely inert, not just visually dimmed: among the
    // IgnorePointer ancestors of the Audio Quality label, at least one must
    // actually be ignoring taps.
    final ignorePointers = tester
        .widgetList<IgnorePointer>(
          find.ancestor(
            of: find.text('Audio Quality'),
            matching: find.byType(IgnorePointer),
          ),
        )
        .toList();
    expect(ignorePointers.any((w) => w.ignoring == true), isTrue);

    // Existing Dark Mode / Notifications toggles still function untouched.
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsNWidgets(2));
  });
}
