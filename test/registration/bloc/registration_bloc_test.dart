import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc_new.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc_old.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_events.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/registration_repo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

    for (var i = 0; i < 2; i++) {
      final isOld = i == 0;
      final old = isOld ? 'Old' : 'New';

      const validUsername = 'unicorn';
      const invalidUsername = 'username';

      group('RegistrationBloc$old', () {
        late RegistrationRepo repo;
        final error = Exception();

        setUp(() {
          repo = MockRegistrationRepo();
        });
        group('RegistrationUsernameChanged', () {
          blocTest<RegistrationBloc, RegistrationState>(
            'succeeds on available username',
            setUp: () {
              when(() => repo.isUsernameAvailable(validUsername))
                  .thenAnswer((_) async => true);
            },
            build: () => RegistrationBloc(isOld: isOld, registrationRepo: repo),
            act: (bloc) => bloc.add(
              const RegistrationUsernameChanged(username: validUsername),
            ),
            expect: () => [
              isA<RegistrationState>()
                  .having(
                    (s) => s.username.value,
                    'username.value',
                    validUsername,
                  )
                  .having(
                    (s) => s.isCheckingUsername,
                    'isCheckingUsername',
                    true,
                  ),
              isA<RegistrationState>()
                  .having(
                    (s) => s.username.value,
                    'username.value',
                    validUsername,
                  )
                  .having((s) => s.username.valid, 'username.valid', true)
                  .having(
                    (s) => s.isCheckingUsername,
                    'isCheckingUsername',
                    false,
                  ),
            ],
            verify: (bloc) {
              verify(() => repo.isUsernameAvailable(validUsername)).called(1);
            },
          );
        });
      });
    }
  });
}
