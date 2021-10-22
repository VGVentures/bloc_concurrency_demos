import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_events.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:bloc_concurrency_demos/registration/registration_repo.dart';
import 'package:rxdart/rxdart.dart';

class RegistrationBlocOld extends Bloc<RegistrationEvent, RegistrationState>
    implements RegistrationBloc {
  RegistrationBlocOld({required this.registrationRepo})
      : super(const RegistrationState.initial());

  @override
  final RegistrationRepo registrationRepo;

  @override
  Stream<RegistrationState> mapEventToState(RegistrationEvent event) async* {
    if (event is RegistrationUsernameChanged) {
      var username = UsernameInput.dirty(value: event.username);
      yield RegistrationState(
        username: username,
        isCheckingUsername: username.valid,
        status: state.status,
      );
      if (username.valid) {
        final isUsernameAvailable =
            await registrationRepo.isUsernameAvailable(username.value);
        if (!isUsernameAvailable) {
          username = UsernameInput.dirty(
            value: event.username,
            serverError: UsernameInputError.taken,
          );
        }
        yield RegistrationState(
          username: username,
          isCheckingUsername: false,
          status: state.status,
        );
      }
    } else if (event is RegistrationSubmitted) {
      final username = state.username.value;
      try {
        yield RegistrationState(
          username: state.username,
          isCheckingUsername: false,
          status: RegistrationStatus.submitting,
        );
        await registrationRepo.register(
          username: username,
        );
        yield RegistrationState(
          username: state.username,
          isCheckingUsername: false,
          status: RegistrationStatus.succeeded,
        );
      } catch (e) {
        // Check for specific backend error that indicates a taken username.
        if (e is ArgumentError && state.username.value == username) {
          yield RegistrationState(
            username: UsernameInput.dirty(
              value: username,
              serverError: UsernameInputError.taken,
            ),
            isCheckingUsername: state.isCheckingUsername,
            status: RegistrationStatus.failed,
          );
        } else {
          yield RegistrationState(
            username: state.username,
            isCheckingUsername: state.isCheckingUsername,
            status: RegistrationStatus.failed,
          );
        }
      }
    }
  }

  @override
  Stream<Transition<RegistrationEvent, RegistrationState>> transformEvents(
    Stream<RegistrationEvent> events,
    Stream<Transition<RegistrationEvent, RegistrationState>> Function(
      RegistrationEvent,
    )
        transitionFn,
  ) {
    // Make the UsernameChanged event debounced AND restartable, leaving
    // all other events unchanged (using the old bloc way of transforming
    // events).
    //
    // If this is difficult to understand, you're not alone. The new API
    // makes this considerabily simpler.
    final deferredEvents = events
        .where((e) => e is RegistrationUsernameChanged)
        .debounceTime(RegistrationBloc.debounceUsernameDuration)
        .distinct()
        .switchMap(transitionFn);
    final forwardedEvents = events
        .where((e) => e is! RegistrationUsernameChanged)
        .asyncExpand(transitionFn);
    return forwardedEvents.mergeWith([deferredEvents]);
  }
}
