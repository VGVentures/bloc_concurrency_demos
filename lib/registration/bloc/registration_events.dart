abstract class RegistrationEvent {}

class UsernameChanged extends RegistrationEvent {
  UsernameChanged({required this.username});
  final String username;
}

class Register extends RegistrationEvent {}
