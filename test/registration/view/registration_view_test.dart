import 'package:bloc_concurrency_demos/l10n/l10n.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_bloc.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_events.dart';
import 'package:bloc_concurrency_demos/registration/bloc/registration_state.dart';
import 'package:bloc_concurrency_demos/registration/models/username_input.dart';
import 'package:bloc_concurrency_demos/registration/view/registration_view.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class MockRegistrationBloc
    extends MockBloc<RegistrationEvent, RegistrationState>
    implements RegistrationBloc {}

extension on WidgetTester {
  Future<void> pumpRegistrationView(RegistrationBloc bloc) async {
    await pumpApp(
      BlocProvider<RegistrationBloc>.value(
        value: bloc,
        child: const RegistrationView(isOld: true),
      ),
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const RegistrationState.initial());
    registerFallbackValue<RegistrationEvent>(const RegistrationSubmitted());
  });

  group('Registration', () {
    testWidgets('instantiates', (tester) async {
      const files = Registration(isOld: false);
      await tester.pumpApp(files);
      await tester.pumpAndSettle();
      expect(find.byType(RegistrationView), findsOneWidget);
    });
  });

  group('RegistrationView', () {
    const username = 'unicorn';
    const usernameTooShortState = RegistrationState(
      username: UsernameInput.dirty(value: 'uni'),
      isCheckingUsername: false,
      status: RegistrationStatus.editing,
    );
    const usernameEmptyState = RegistrationState(
      username: UsernameInput.dirty(),
      isCheckingUsername: false,
      status: RegistrationStatus.editing,
    );
    const initialUsernameState = RegistrationState(
      username: UsernameInput.dirty(value: username),
      isCheckingUsername: false,
      status: RegistrationStatus.editing,
    );
    const usernameTakenState = RegistrationState(
      username: UsernameInput.dirty(
        value: username,
        serverError: UsernameInputError.taken,
      ),
      isCheckingUsername: false,
      status: RegistrationStatus.editing,
    );
    const checkingUsernameState = RegistrationState(
      username: UsernameInput.dirty(value: username),
      isCheckingUsername: true,
      status: RegistrationStatus.editing,
    );

    group('body', () {
      Stream<RegistrationState> registrationStates({required bool success}) {
        return Stream<RegistrationState>.fromIterable(
          [
            const RegistrationState(
              username: UsernameInput.dirty(value: username),
              isCheckingUsername: false,
              status: RegistrationStatus.submitting,
            ),
            RegistrationState(
              username: const UsernameInput.dirty(value: username),
              isCheckingUsername: false,
              status: success
                  ? RegistrationStatus.succeeded
                  : RegistrationStatus.failed,
            ),
          ],
        );
      }

      testWidgets('shows form inputs', (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(initialUsernameState);
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();
        final form = find.byType(Form);
        expect(form, findsOneWidget);
        final usernameField = find.byType(UsernameField);
        expect(usernameField, findsOneWidget);
        final submitButton = find.byType(SubmitButton);
        expect(submitButton, findsOneWidget);
      });

      testWidgets('shows snackbar for registration failure', (tester) async {
        final bloc = MockRegistrationBloc();
        whenListen(
          bloc,
          registrationStates(success: false),
          initialState: initialUsernameState,
        );
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();
        final snackbar = find.byType(SnackBar);
        expect(snackbar, findsOneWidget);
        final context = tester.element(snackbar);
        final text = find.descendant(
          of: snackbar,
          matching: find.text(context.l10n.registrationViewError),
        );
        expect(text, findsOneWidget);
      });

      testWidgets('shows snackbar for registration success', (tester) async {
        final bloc = MockRegistrationBloc();
        whenListen(
          bloc,
          registrationStates(success: true),
          initialState: initialUsernameState,
        );
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();
        final snackbar = find.byType(SnackBar);
        expect(snackbar, findsOneWidget);
        final context = tester.element(snackbar);
        final text = find.descendant(
          of: snackbar,
          matching: find.text(context.l10n.registrationViewSuccess),
        );
        expect(text, findsOneWidget);
      });
    });

    group('UsernameField', () {
      testWidgets('configures for available and valid username',
          (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(initialUsernameState);
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);
        final textFieldWidget = tester.widget<TextField>(textField);
        final context = tester.element(textField);

        expect(
          textFieldWidget.decoration?.helperText,
          context.l10n.registrationUsernameAvailable(username),
        );
        expect(textFieldWidget.decoration?.errorText, isNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('configures for invalid username', (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(usernameTooShortState);
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);
        final textFieldWidget = tester.widget<TextField>(textField);
        final context = tester.element(textField);

        expect(
          textFieldWidget.decoration?.errorText,
          context.l10n.registrationUsernameInvalid,
        );
        expect(textFieldWidget.decoration?.helperText, isNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('configures for empty username', (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(usernameEmptyState);
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);
        final textFieldWidget = tester.widget<TextField>(textField);
        final context = tester.element(textField);

        expect(
          textFieldWidget.decoration?.errorText,
          context.l10n.registrationUsernameEmpty,
        );
        expect(textFieldWidget.decoration?.helperText, isNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('configures for taken username', (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(usernameTakenState);
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);
        final textFieldWidget = tester.widget<TextField>(textField);
        final context = tester.element(textField);

        expect(
          textFieldWidget.decoration?.errorText,
          context.l10n.registrationUsernameTaken(username),
        );
        expect(textFieldWidget.decoration?.helperText, isNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('adds event on input', (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(usernameEmptyState);
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);

        await tester.enterText(textField, username);
        await tester.pumpAndSettle(RegistrationBloc.debounceUsernameDuration);

        verify(
          () => bloc.add(const RegistrationUsernameChanged(username: username)),
        );
      });

      testWidgets('shows progress indicator when checking username',
          (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(checkingUsernameState);
        await tester.pumpRegistrationView(bloc);
        await tester.pump();

        final textField = find.byType(TextField);
        final textFieldWidget = tester.widget<TextField>(textField);

        expect(textFieldWidget.decoration?.errorText, isNull);
        expect(textFieldWidget.decoration?.helperText, isNull);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('SubmitButton', () {
      testWidgets('enabled on valid form, adds registration event',
          (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(initialUsernameState);
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();
        final submitButton = find.byType(ElevatedButton);
        final submitWidget = tester.widget<ElevatedButton>(submitButton);
        expect(submitWidget.enabled, true);
        await tester.tap(submitButton);
        verify(() => bloc.add(const RegistrationSubmitted()));
      });
      testWidgets('disabled on invalid form', (tester) async {
        final bloc = MockRegistrationBloc();
        when(() => bloc.state).thenReturn(initialUsernameState);
        await tester.pumpRegistrationView(bloc);
        await tester.pumpAndSettle();
        final submitButton = find.byType(ElevatedButton);
        final submitWidget = tester.widget<ElevatedButton>(submitButton);
        expect(submitWidget.enabled, true);
      });
    });
  });
}
