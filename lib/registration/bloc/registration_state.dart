import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:formz/formz.dart';

enum RegistrationStatus { editing, submitting, failed, succeeded }

class RegistrationState {
  RegistrationState({
    required this.username,
    required this.isCheckingUsername,
    required this.status,
  });

  static final initial = RegistrationState(
    username: const UsernameInput.pure(),
    isCheckingUsername: false,
    status: RegistrationStatus.editing,
  );

  final UsernameInput username;

  final bool isCheckingUsername;
  final RegistrationStatus status;

  late final isBusy =
      isCheckingUsername || status == RegistrationStatus.submitting;
  late final canSubmit =
      Formz.validate([username]) == FormzStatus.valid && !isBusy;
  late final showUsernameAvailable = username.valid && !isCheckingUsername;
}
