import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc.dart';
import 'package:bloc_concurrency_demos/registration/view/registration_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

extension on WidgetTester {
  Future<void> pumpRegistrationView(RegistrationBloc bloc) async {
    await pumpApp(
      BlocProvider<RegistrationBloc>.value(
        value: bloc,
        child: const RegistrationView(isOld: true),
      ),
    );
  }
}

void main() {
  group('Registration', () {
    testWidgets('instantiates', (tester) async {
      const files = Registration(isOld: false);
      await tester.pumpApp(files);
      await tester.pumpAndSettle();
      expect(find.byType(RegistrationView), findsOneWidget);
    });
  });

  group('RegistrationView', () {
    testWidgets('instantiates', (tester) async {});
  });
}
