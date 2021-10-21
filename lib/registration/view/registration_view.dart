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
      create: (context) => RegistrationBloc(
        isOld: isOld,
        registrationRepo: RegistrationRepo(),
      ),
      child: RegistrationView(isOld: isOld),
    );
  }
}

class RegistrationView extends StatelessWidget {
  RegistrationView({
    Key? key,
    required this.isOld,
  }) : super(key: key);

  final GlobalKey<FormState> _registrationFormKey = GlobalKey<FormState>();
  final bool isOld;
  final TextEditingController _usernameController = TextEditingController();

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.registrationViewError),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state.status == RegistrationStatus.succeeded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.registrationViewSuccess),
                backgroundColor: colorScheme.secondary,
              ),
            );
          }
        },
        child: Form(
          key: _registrationFormKey,
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, top: 32),
            child: Column(
              children: [
                UsernameField(controller: _usernameController),
                const SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return state.status == RegistrationStatus.submitting
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: state.canSubmit
                    ? () => BlocProvider.of<RegistrationBloc>(context).add(
                          Register(),
                        )
                    : null,
                child: const Text('Register'),
              );
      },
    );
  }
}

class UsernameField extends StatelessWidget {
  const UsernameField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final TextEditingController controller;

  String? _usernameError(BuildContext context, UsernameInput username) {
    // final l10n = context.l10n;
    final error = username.displayError;
    if (error == null) return null;
    if (error == UsernameInputError.empty) {
      return 'Username cannot be empty';
    } else if (error == UsernameInputError.invalid) {
      return 'Username should be valid';
    } else if (error == UsernameInputError.taken) {
      return '"${username.value}" is already taken. 😢';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(const Size.fromHeight(120)),
      child: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) {
          return TextField(
            controller: controller,
            autocorrect: false,
            onChanged: (value) {
              BlocProvider.of<RegistrationBloc>(context).add(
                UsernameChanged(username: value),
              );
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              errorText: _usernameError(context, state.username),
              labelText: 'Username',
              helperText: state.showUsernameAvailable
                  ? '"${state.username.value}" is available!'
                  : null,
              filled: true,
              prefixIcon: const Icon(Icons.person),
              suffix: state.isCheckingUsername
                  ? Container(
                      constraints: BoxConstraints.tight(
                        const Size(15, 15),
                      ),
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
