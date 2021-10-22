abstract class RegistrationEvent {
  const RegistrationEvent();
}

class RegistrationUsernameChanged extends RegistrationEvent {
  const RegistrationUsernameChanged({required this.username});
  final String username;
}

class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted();
}
