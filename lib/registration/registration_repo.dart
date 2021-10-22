class RegistrationRepo {
  final Set<String> takenUsernames = {'username', 'admin', 'user', 'testuser'};

  Future<bool> isUsernameAvailable(String username) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    try {
      _checkUsername(username);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> register({required String username}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    _checkUsername(username);
    takenUsernames.add(username);
  }

  void _checkUsername(String username) {
    if (takenUsernames.contains(username)) {
      throw ArgumentError('$username taken');
    }
  }
}
