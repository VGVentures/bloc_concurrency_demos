import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:formz/formz.dart';

enum RegistrationStatus { editing, submitting, failed, succeeded }

class RegistrationState {
  const RegistrationState({
    required this.username,
    required this.isCheckingUsername,
    required this.status,
  });

  const RegistrationState.initial()
      :
        // A bug in dart prevents const constructors from being covered in
        // code coverage.
        //
        // coverage:ignore-line
        this(
          username: const UsernameInput.pure(),
          isCheckingUsername: false,
          status: RegistrationStatus.editing,
        );

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
