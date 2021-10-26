import 'package:bloc_concurrency_demos/registration/registration_repo.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isUsernameAvailable', () {
    final repo = RegistrationRepo();
    test('indicates available username', () async {
      fakeAsync((async) {
        expect(repo.isUsernameAvailable('unicorn'), completion(equals(true)));
        async.elapse(RegistrationRepo.isUsernameAvailableDuration);
      });
    });
    test('indicates unavailable username', () {
      fakeAsync((async) {
        expect(repo.isUsernameAvailable('username'), completion(equals(false)));
        async.elapse(RegistrationRepo.isUsernameAvailableDuration);
      });
    });
  });

  group('register', () {
    final repo = RegistrationRepo();
    test('registers user', () async {
      fakeAsync((async) {
        expect(repo.register(username: 'unicorn'), completes);
        async.elapse(RegistrationRepo.registrationDuration);
      });
    });

    test('does not allow duplicate username to register', () {
      fakeAsync((async) {
        expect(
          repo.register(username: 'unicorn'),
          throwsA(isA<ArgumentError>()),
        );
        async.elapse(RegistrationRepo.registrationDuration);
      });
    });
  });
}
