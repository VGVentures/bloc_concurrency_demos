class RegistrationRepo {
  final Set<String> takenUsernames = {'username', 'admin', 'user', 'testuser'};

  static const isUsernameAvailableDuration = Duration(milliseconds: 500);
  static const registrationDuration = Duration(seconds: 2);

  Future<bool> isUsernameAvailable(String username) async {
    await Future<void>.delayed(isUsernameAvailableDuration);
    try {
      _checkUsername(username);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> register({required String username}) async {
    await Future<void>.delayed(registrationDuration);
    _checkUsername(username);
    takenUsernames.add(username);
  }

  void _checkUsername(String username) {
    if (takenUsernames.contains(username)) {
      throw ArgumentError('$username taken');
    }
  }
}
