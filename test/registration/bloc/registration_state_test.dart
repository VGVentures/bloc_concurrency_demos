import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegistrationState', () {
    group('isBusy', () {
      test('returns true when checking username', () {
        const state = RegistrationState(
          username: UsernameInput.pure(value: 'unicorn'),
          isCheckingUsername: true,
          status: RegistrationStatus.editing,
        );
        expect(state.isBusy, true);
      });
      test('returns true when submitting form', () {
        const state = RegistrationState(
          username: UsernameInput.pure(value: 'unicorn'),
          isCheckingUsername: false,
          status: RegistrationStatus.submitting,
        );
        expect(state.isBusy, true);
      });
    });

    group('canSubmit', () {
      test('true when username is valid and not busy', () {
        const state = RegistrationState(
          username: UsernameInput.dirty(value: 'unicorn'),
          isCheckingUsername: false,
          status: RegistrationStatus.editing,
        );
        expect(state.canSubmit, true);
      });
      test('false when username is invalid', () {
        const state = RegistrationState(
          username: UsernameInput.dirty(value: 'un'),
          isCheckingUsername: false,
          status: RegistrationStatus.editing,
        );
        expect(state.canSubmit, false);
      });
      test('false when username is valid but is busy', () {
        const state = RegistrationState(
          username: UsernameInput.dirty(value: 'unicorn'),
          isCheckingUsername: false,
          status: RegistrationStatus.submitting,
        );
        expect(state.canSubmit, false);
      });
    });
  });
}
