// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:bloc_concurrency_demos/app/app.dart';
import 'package:bloc_concurrency_demos/home/home_page.dart';
import 'package:bloc_concurrency_demos/settings/app_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

void main() {
  group('App', () {
    testWidgets('renders home page', (tester) async {
      final frame = await getVideoFrameForWidgetTest(tester);
      await tester.pumpApp(
        App(
          preloadedConfig: AppConfiguration(
            blankFrame: frame,
          ),
        ),
      );
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
