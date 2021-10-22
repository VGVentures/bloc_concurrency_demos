import 'package:bloc_concurrency_demos/l10n/l10n.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_events.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:bloc_concurrency_demos/registration/registration_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Registration extends StatelessWidget {
  const Registration({Key? key, required this.isOld}) : super(key: key);

  final bool isOld;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistrationBloc(
        isOld: isOld,
        registrationRepo: RegistrationRepo(),
      ),
      child: RegistrationView(isOld: isOld),
    );
  }
}

class RegistrationView extends StatelessWidget {
  const RegistrationView({Key? key, required this.isOld}) : super(key: key);

  final bool isOld;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isOld ? l10n.registrationViewTitleOld : l10n.registrationViewTitleNew,
        ),
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listenWhen: (previous, current) =>
            previous.status == RegistrationStatus.submitting &&
            current.status != RegistrationStatus.submitting,
        listener: (context, state) {
          final colorScheme = Theme.of(context).colorScheme;
          if (state.status == RegistrationStatus.failed) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(l10n.registrationViewError),
                  backgroundColor: colorScheme.error,
                ),
              );
          } else if (state.status == RegistrationStatus.succeeded) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(l10n.registrationViewSuccess),
                  backgroundColor: colorScheme.secondary,
                ),
              );
          }
        },
        child: Form(
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, top: 32),
            child: Column(
              children: const [UsernameField(), SubmitButton()],
            ),
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final l10n = context.l10n;
        return state.status == RegistrationStatus.submitting
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: state.canSubmit
                    ? () {
                        BlocProvider.of<RegistrationBloc>(context).add(
                          const RegistrationSubmitted(),
                        );
                      }
                    : null,
                child: Text(l10n.registrationRegister),
              );
      },
    );
  }
}

class UsernameField extends StatelessWidget {
  const UsernameField({Key? key}) : super(key: key);

  String? _usernameError(BuildContext context, UsernameInput username) {
    final l10n = context.l10n;
    final error = username.displayError;
    if (error == null) return null;
    if (error == UsernameInputError.empty) {
      return l10n.registrationUsernameEmpty;
    } else if (error == UsernameInputError.invalid) {
      return l10n.registrationUsernameInvalid;
    } else if (error == UsernameInputError.taken) {
      return l10n.registrationUsernameTaken(username.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints.tight(const Size.fromHeight(120)),
      child: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) {
          return TextField(
            autocorrect: false,
            onChanged: (value) {
              BlocProvider.of<RegistrationBloc>(context).add(
                RegistrationUsernameChanged(username: value),
              );
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              errorText: _usernameError(context, state.username),
              labelText: l10n.registrationUsername,
              helperText: state.showUsernameAvailable
                  ? l10n.registrationUsernameAvailable(state.username.value)
                  : null,
              filled: true,
              prefixIcon: const Icon(Icons.person),
              suffix: state.isCheckingUsername
                  ? ConstrainedBox(
                      constraints: BoxConstraints.tight(const Size(15, 15)),
                      child: const CircularProgressIndicator(strokeWidth: 3),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
