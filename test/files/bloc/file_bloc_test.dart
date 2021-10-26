import 'package:bloc_concurrency_demos/files/bloc/file_bloc_new.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_cubit.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_cubit_old.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_events.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../file_mocks.dart';

void main() {
  group('FileCubit', () {
    test('creates old bloc', () {
      final bloc = FileCubit(isOld: true, fileRepo: MockFileRepo());
      expect(bloc, isA<FileCubitOld>());
    });

    test('creates new bloc', () {
      final bloc = FileCubit(isOld: false, fileRepo: MockFileRepo());
      expect(bloc, isA<FileBlocNew>());
    });
  });

  for (var i = 0; i < 2; i++) {
    final isOld = i == 0;
    final old = isOld ? 'CubitOld' : 'BlocNew';

    group('File$old', () {
      late FileRepo repo;
      final error = Exception();

      setUp(() {
        repo = MockFileRepo();
      });

      group('LoadFiles', () {
        blocTest<FileCubit, FileState>(
          'succeeds',
          setUp: () {
            when(() => repo.loadFiles()).thenAnswer(
              (_) async => FileRepo.initialFiles,
            );
          },
          build: () => FileCubit(isOld: isOld, fileRepo: repo),
          act: (bloc) => bloc.add(const LoadFiles()),
          expect: () => <FileState>[
            FileState(
              fileView: const {},
              pendingDeletions: const {},
              isLoading: true,
            ),
            FileState(
              fileView: FileRepo.initialFiles,
              pendingDeletions: const {},
              isLoading: false,
            ),
          ],
        );
        blocTest<FileCubit, FileState>(
          'emits failure state',
          setUp: () {
            when(() => repo.loadFiles()).thenThrow(error);
          },
          build: () => FileCubit(isOld: isOld, fileRepo: repo),
          act: (bloc) => bloc.add(const LoadFiles()),
          expect: () => <FileState>[
            FileState(
              fileView: const {},
              pendingDeletions: const {},
              isLoading: true,
            ),
            FileState(
              fileView: const {},
              pendingDeletions: const {},
              error: error,
              isLoading: false,
            ),
          ],
        );
      });

      group('DeleteFile', () {
        final files = {
          1: const File(id: 1, name: 'file1.txt'),
        };

        blocTest<FileCubit, FileState>(
          'succeeds',
          setUp: () {
            when(() => repo.deleteFile(id: 1)).thenAnswer((_) async {});
          },
          build: () => FileCubit(isOld: isOld, fileRepo: repo),
          seed: () => FileState(
            fileView: files,
            isLoading: false,
            pendingDeletions: const {},
          ),
          act: (bloc) => bloc.add(const DeleteFile(fileId: 1)),
          expect: () => <FileState>[
            FileState(
              fileView: files,
              pendingDeletions: const {1},
              isLoading: false,
            ),
            FileState(
              fileView: const {},
              pendingDeletions: const {},
              isLoading: false,
            ),
          ],
        );

        blocTest<FileCubit, FileState>(
          'emits failure state',
          setUp: () {
            when(() => repo.deleteFile(id: 1)).thenThrow(error);
          },
          build: () => FileCubit(isOld: isOld, fileRepo: repo),
          seed: () => FileState(
            fileView: files,
            isLoading: false,
            pendingDeletions: const {},
          ),
          act: (bloc) => bloc.add(const DeleteFile(fileId: 1)),
          expect: () => <FileState>[
            FileState(
              fileView: files,
              pendingDeletions: const {1},
              isLoading: false,
            ),
            FileState(
              fileView: files,
              pendingDeletions: const {},
              isLoading: false,
              error: error,
            ),
          ],
        );

        blocTest<FileCubit, FileState>(
          'does not delete while pending',
          build: () => FileCubit(isOld: isOld, fileRepo: repo),
          seed: () => FileState(
            fileView: files,
            isLoading: false,
            pendingDeletions: const {1},
          ),
          act: (bloc) => bloc.add(const DeleteFile(fileId: 1)),
          expect: () => <FileState>[],
        );
      });
    });
  }
}
