// Extend FormzInput and provide the input type and error type.
import 'package:formz/formz.dart';

enum UsernameInputError { empty, invalid, taken }

class UsernameInput extends FormzInput<String, UsernameInputError> {
  // Call super.pure to represent an unmodified form input.
  // coverage:ignore-start
  const UsernameInput.pure({String value = '', this.serverError})
      : super.pure(value);
  // coverage:ignore-end

  // Call super.dirty to represent a modified form input.
  // coverage:ignore-start
  const UsernameInput.dirty({String value = '', this.serverError})
      : super.dirty(value);
  // coverage:ignore-end

  final UsernameInputError? serverError;

  UsernameInputError? get displayError => pure ? null : super.error;

  // Override validator to handle validating a given input value.
  @override
  UsernameInputError? validator(String value) {
    final error = serverError;
    if (error != null) return error;
    if (value.isEmpty) return UsernameInputError.empty;
    if (value.length < 4) return UsernameInputError.invalid;
  }

  @override
  String toString() => '($value, $error)';
}
