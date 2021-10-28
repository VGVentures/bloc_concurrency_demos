import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();
}

class RegistrationUsernameChanged extends RegistrationEvent {
  const RegistrationUsernameChanged({required this.username});
  final String username;

  @override
  List<Object?> get props => [username];
}

class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted();

  @override
  List<Object?> get props => [];
}
