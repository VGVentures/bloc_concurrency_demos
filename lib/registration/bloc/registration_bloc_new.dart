import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_events.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:bloc_concurrency_demos/registration/registration_repo.dart';
import 'package:rxdart/rxdart.dart';

class RegistrationBlocNew extends Bloc<RegistrationEvent, RegistrationState>
    implements RegistrationBloc {
  RegistrationBlocNew({required this.registrationRepo})
      : super(const RegistrationState.initial()) {
    on<UsernameChanged>(
      (event, emit) async {
        var username = UsernameInput.dirty(value: event.username);
        emit(
          RegistrationState(
            username: username,
            isCheckingUsername: username.valid,
            status: state.status,
          ),
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
          emit(
            RegistrationState(
              username: username,
              isCheckingUsername: false,
              status: state.status,
            ),
          );
        }
      },
      transformer: debounceRestartable(
        RegistrationBloc.debounceUsernameDuration,
      ),
    );
    on<Register>(
      (event, emit) async {
        final username = state.username.value;
        try {
          emit(
            RegistrationState(
              username: state.username,
              isCheckingUsername: false,
              status: RegistrationStatus.submitting,
            ),
          );
          await registrationRepo.register(
            username: username,
          );
          emit(
            RegistrationState(
              username: state.username,
              isCheckingUsername: false,
              status: RegistrationStatus.succeeded,
            ),
          );
        } catch (e) {
          // Check for specific backend error that indicates a taken username.
          if (e is ArgumentError && state.username.value == username) {
            emit(
              RegistrationState(
                username: UsernameInput.dirty(
                  value: username,
                  serverError: UsernameInputError.taken,
                ),
                isCheckingUsername: state.isCheckingUsername,
                status: RegistrationStatus.failed,
              ),
            );
          } else {
            emit(
              RegistrationState(
                username: state.username,
                isCheckingUsername: state.isCheckingUsername,
                status: RegistrationStatus.failed,
              ),
            );
          }
        }
      },
      transformer: sequential(),
    );
  }

  @override
  final RegistrationRepo registrationRepo;

  EventTransformer<RegistrationEvent> debounceRestartable<RegistrationEvent>(
    Duration duration,
  ) {
    return (events, mapper) => restartable<RegistrationEvent>()
        .call(events.debounceTime(duration), mapper);
  }
}
