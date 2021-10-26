import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc_new.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc_old.dart';
import 'package:flutter_test/flutter_test.dart';

import '../registration_mocks.dart';

void main() {
  group('RegistrationBloc', () {
    test('creates old bloc', () {
      final bloc = RegistrationBloc(
        isOld: true,
        registrationRepo: MockRegistrationRepo(),
      );
      expect(bloc, isA<RegistrationBlocOld>());
    });
    test('creates new bloc', () {
      final bloc = RegistrationBloc(
        isOld: false,
        registrationRepo: MockRegistrationRepo(),
      );
      expect(bloc, isA<RegistrationBlocNew>());
    });

    for (var i = 0; i < 2; i++) {}
  });
}
