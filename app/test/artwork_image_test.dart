// Tests for ArtworkImage's URL normalization + placeholder behavior (see
// lib/utils/media_url.dart). Only exercises the deterministic "no network
// needed" branch: null/empty/malformed URLs must fall back to the
// music-note placeholder rather than being handed to CachedNetworkImage.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medyo/widgets/artwork_image.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('a null imageUrl renders the fallback, not a network image', (tester) async {
    await tester.pumpWidget(_wrap(const ArtworkImage(imageUrl: null, width: 100, height: 100)));
    await tester.pump();

    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
  });

  testWidgets('an empty imageUrl renders the fallback', (tester) async {
    await tester.pumpWidget(_wrap(const ArtworkImage(imageUrl: '', width: 100, height: 100)));
    await tester.pump();

    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
  });

  testWidgets('a raw filesystem path is rejected by normalization and renders the fallback', (tester) async {
    await tester.pumpWidget(_wrap(const ArtworkImage(
      imageUrl: '/var/www/storage/app/public/images/x.png',
      width: 100,
      height: 100,
    )));
    await tester.pump();

    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
  });
}
