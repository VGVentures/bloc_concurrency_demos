import 'package:bloc_concurrency_demos/bootstrap.dart';
import 'package:bloc_concurrency_demos/home/home_page.dart';
import 'package:bloc_concurrency_demos/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';

import '../helpers/helpers.dart';

Future<void> main() async {
  group('HomePage', () {
    testWidgets('navigates to selected feature', (tester) async {
      final frame = await getVideoFrameForWidgetTest(tester);

      final navigator = MockNavigator();
      when(() => navigator.push(any())).thenAnswer((_) async {});

      await tester.pumpApp(
        HomePage(
          preloadedConfig: AppPreloadedConfiguration(blankFrame: frame),
        ),
        navigator: navigator,
      );

      final featureList = find.byType(ListView).first;
      final context = tester.element(featureList);
      final featureText = context.l10n.videoStreamViewTitleOld;
      final featureItem = find.text(featureText);
      expect(featureItem, findsOneWidget);
      await tester.tap(featureItem);
      verify(() => navigator.push(any())).called(1);
    });
  });
}
