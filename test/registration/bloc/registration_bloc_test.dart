import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc_new.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc_old.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_events.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
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
  });

  for (var i = 0; i < 2; i++) {
    final isOld = i == 0;
    final old = isOld ? 'Old' : 'New';

    const username = 'unicorn';

    group('RegistrationBloc$old', () {
      late RegistrationRepo repo;

      setUp(() {
        repo = MockRegistrationRepo();
      });
      group('RegistrationUsernameChanged', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'indicates available username',
          setUp: () {
            when(() => repo.isUsernameAvailable(username))
                .thenAnswer((_) async => true);
          },
          build: () => RegistrationBloc(isOld: isOld, registrationRepo: repo),
          wait: RegistrationBloc.debounceUsernameDuration,
          act: (bloc) => bloc.add(
            const RegistrationUsernameChanged(username: username),
          ),
          expect: () => <RegistrationState>[
            const RegistrationState(
              username: UsernameInput.dirty(value: username),
              isCheckingUsername: true,
              status: RegistrationStatus.editing,
            ),
            const RegistrationState(
              username: UsernameInput.dirty(value: username),
              isCheckingUsername: false,
              status: RegistrationStatus.editing,
            ),
          ],
          verify: (bloc) {
            verify(() => repo.isUsernameAvailable(username)).called(1);
          },
        );
        blocTest<RegistrationBloc, RegistrationState>(
          'indicates a taken username',
          setUp: () {
            when(() => repo.isUsernameAvailable(username))
                .thenAnswer((_) async => false);
          },
          build: () => RegistrationBloc(isOld: isOld, registrationRepo: repo),
          wait: RegistrationBloc.debounceUsernameDuration,
          act: (bloc) => bloc.add(
            const RegistrationUsernameChanged(username: username),
          ),
          expect: () => <RegistrationState>[
            const RegistrationState(
              username: UsernameInput.dirty(value: username),
              isCheckingUsername: true,
              status: RegistrationStatus.editing,
            ),
            const RegistrationState(
              username: UsernameInput.dirty(
                value: username,
                serverError: UsernameInputError.taken,
              ),
              isCheckingUsername: false,
              status: RegistrationStatus.editing,
            ),
          ],
          verify: (bloc) {
            verify(() => repo.isUsernameAvailable(username)).called(1);
          },
        );
      });

      group('RegistrationSubmitted', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'indicates successful registration',
          setUp: () {
            when(() => repo.register(username: username))
                .thenAnswer((_) async {});
          },
          build: () => RegistrationBloc(isOld: isOld, registrationRepo: repo),
          seed: () => const RegistrationState(
            username: UsernameInput.dirty(value: username),
            isCheckingUsername: false,
            status: RegistrationStatus.editing,
          ),
          act: (bloc) => bloc.add(
            const RegistrationSubmitted(),
          ),
          expect: () => [
            const RegistrationState(
              isCheckingUsername: false,
              username: UsernameInput.dirty(value: username),
              status: RegistrationStatus.submitting,
            ),
            const RegistrationState(
              isCheckingUsername: false,
              username: UsernameInput.dirty(value: username),
              status: RegistrationStatus.succeeded,
            ),
          ],
          verify: (bloc) {
            verify(() => repo.register(username: username)).called(1);
          },
        );
        blocTest<RegistrationBloc, RegistrationState>(
          'indicates registration failure from taken username',
          setUp: () {
            when(() => repo.register(username: username))
                .thenThrow(ArgumentError());
          },
          build: () => RegistrationBloc(isOld: isOld, registrationRepo: repo),
          seed: () => const RegistrationState(
            username: UsernameInput.dirty(value: username),
            isCheckingUsername: false,
            status: RegistrationStatus.editing,
          ),
          act: (bloc) => bloc.add(
            const RegistrationSubmitted(),
          ),
          expect: () => [
            const RegistrationState(
              isCheckingUsername: false,
              username: UsernameInput.dirty(value: username),
              status: RegistrationStatus.submitting,
            ),
            const RegistrationState(
              isCheckingUsername: false,
              username: UsernameInput.dirty(value: username),
              status: RegistrationStatus.failed,
            ),
          ],
          verify: (bloc) {
            verify(() => repo.register(username: username)).called(1);
          },
        );
        blocTest<RegistrationBloc, RegistrationState>(
          'indicates other registration failures',
          setUp: () {
            when(() => repo.register(username: username))
                .thenThrow(Exception());
          },
          build: () => RegistrationBloc(isOld: isOld, registrationRepo: repo),
          seed: () => const RegistrationState(
            username: UsernameInput.dirty(value: username),
            isCheckingUsername: false,
            status: RegistrationStatus.editing,
          ),
          act: (bloc) => bloc.add(
            const RegistrationSubmitted(),
          ),
          expect: () => [
            const RegistrationState(
              isCheckingUsername: false,
              username: UsernameInput.dirty(value: username),
              status: RegistrationStatus.submitting,
            ),
            const RegistrationState(
              isCheckingUsername: false,
              username: UsernameInput.dirty(value: username),
              status: RegistrationStatus.failed,
            ),
          ],
          verify: (bloc) {
            verify(() => repo.register(username: username)).called(1);
          },
        );
      });
    });
  }
}
