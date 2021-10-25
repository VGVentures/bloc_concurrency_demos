import 'package:bloc_concurrency_demos/files/file_repo.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileRepo', () {
    group('loadFiles', () {
      test('simple load succeeds', () {
        fakeAsync((async) {
          final fileRepo = FileRepo();

          // Expect the first loading result future
          // completes with the expected return value.
          expect(
            fileRepo.loadFiles(),
            completion(equals(FileRepo.initialFiles)),
          );
          // Speed up time so that the future above completes.
          async.elapse(FileRepo.loadFilesDuration);
        });
      });

      test('loads files', () {
        // We can use fakeAsync to avoid actually waiting
        // on Future.delayed() in our test.
        fakeAsync((async) async {
          const id = 1;
          final initialFiles = {
            id: File(id: id, name: 'file1.txt'),
          };
          final fileRepo = FileRepo(
            defaultFileProvider: () => initialFiles,
          );

          // Expect the first loading result future
          // completes with the expected return value.
          expect(fileRepo.loadFiles(), completion(equals(initialFiles)));
          // Speed up time so that the future above completes.
          async.elapse(FileRepo.loadFilesDuration);

          expect(fileRepo.deleteFile(id: id), completes);
          async.elapse(FileRepo.deleteFileDuration);

          expect(
            fileRepo.loadFiles(),
            completion(equals(FileRepo.initialFiles)),
          );
          async.elapse(FileRepo.loadFilesDuration);
        });
      });
    });

    group('delete file', () {
      test('fails on bad id', () {
        fakeAsync((async) {
          final initialFiles = {
            1: File(id: 1, name: 'file1.txt'),
          };
          final fileRepo = FileRepo(
            defaultFileProvider: () => initialFiles,
          );

          expect(
            fileRepo.deleteFile(id: 2),
            throwsA(isInstanceOf<ArgumentError>()),
          );
          async.elapse(FileRepo.deleteFileDuration);
        });
      });
    });
  });
}
