// ignore_for_file: prefer_const_constructors
import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegistrationState', () {
    test('initial has correct properties', () {
      expect(
        RegistrationState.initial(),
        equals(
          RegistrationState(
            username: const UsernameInput.pure(),
            isCheckingUsername: false,
            status: RegistrationStatus.editing,
          ),
        ),
      );
    });

    test('equality', () {
      final username = UsernameInput.dirty(value: 'unicorn');
      final stateA = RegistrationState(
        username: username,
        isCheckingUsername: true,
        status: RegistrationStatus.editing,
      );
      final stateB = RegistrationState(
        username: username,
        isCheckingUsername: false,
        status: RegistrationStatus.editing,
      );
      expect(stateA == stateB, false);
      expect(
        stateA ==
            RegistrationState(
              username: username,
              isCheckingUsername: true,
              status: RegistrationStatus.editing,
            ),
        true,
      );
    });
    group('isBusy', () {
      test('returns true when checking username', () {
        final state = RegistrationState(
          username: UsernameInput.pure(value: 'unicorn'),
          isCheckingUsername: true,
          status: RegistrationStatus.editing,
        );
        expect(state.isBusy, true);
      });
      test('returns true when submitting form', () {
        final state = RegistrationState(
          username: UsernameInput.pure(value: 'unicorn'),
          isCheckingUsername: false,
          status: RegistrationStatus.submitting,
        );
        expect(state.isBusy, true);
      });
    });

    group('canSubmit', () {
      test('true when username is valid and not busy', () {
        final state = RegistrationState(
          username: UsernameInput.dirty(value: 'unicorn'),
          isCheckingUsername: false,
          status: RegistrationStatus.editing,
        );
        expect(state.canSubmit, true);
      });
      test('false when username is invalid', () {
        final state = RegistrationState(
          username: UsernameInput.dirty(value: 'un'),
          isCheckingUsername: false,
          status: RegistrationStatus.editing,
        );
        expect(state.canSubmit, false);
      });
      test('false when username is valid but is busy', () {
        final state = RegistrationState(
          username: UsernameInput.dirty(value: 'unicorn'),
          isCheckingUsername: false,
          status: RegistrationStatus.submitting,
        );
        expect(state.canSubmit, false);
      });
    });
  });
}
