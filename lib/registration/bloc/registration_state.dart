import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:formz/formz.dart';

enum RegistrationStatus { editing, submitting, failed, succeeded }

class RegistrationState {
  const RegistrationState({
    required this.username,
    required this.isCheckingUsername,
    required this.status,
  });

  // A bug in dart prevents const constructors from receiving
  // proper coverage.

  // coverage:ignore-start
  const RegistrationState.initial()
      : this(
          username: const UsernameInput.pure(),
          isCheckingUsername: false,
          status: RegistrationStatus.editing,
        );
  // coverage:ignore-end

  final UsernameInput username;
  final bool isCheckingUsername;
  final RegistrationStatus status;

  bool get isBusy {
    return isCheckingUsername || status == RegistrationStatus.submitting;
  }

  bool get canSubmit {
    return Formz.validate([username]) == FormzStatus.valid && !isBusy;
  }
}
