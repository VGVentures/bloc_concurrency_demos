import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc_new.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc_old.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_events.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/registration_repo.dart';

abstract class RegistrationBloc
    implements Bloc<RegistrationEvent, RegistrationState> {
  factory RegistrationBloc({
    required bool isOld,
    required RegistrationRepo registrationRepo,
  }) {
    return isOld
        ? RegistrationBlocOld(registrationRepo: registrationRepo)
        : RegistrationBlocNew(registrationRepo: registrationRepo);
  }

  // How long to wait after the last keypress event before checking
  // username availability.
  static const debounceUsernameDuration = Duration(milliseconds: 400);

  RegistrationRepo get registrationRepo;
}
