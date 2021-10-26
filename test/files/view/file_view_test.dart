import 'dart:async';

import 'package:bloc_concurrency_demos/files/bloc/file_cubit.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_events.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';
import 'package:bloc_concurrency_demos/files/view/file_view.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';
import '../file_mocks.dart';

extension on WidgetTester {
  Future<void> pumpFileView(FileCubit bloc) async {
    await pumpApp(
      BlocProvider<FileCubit>.value(
        value: bloc,
        child: const FilesView(isOld: true),
      ),
    );
  }
}

class FileListTileFinder extends MatchFinder {
  FileListTileFinder(this.file);

  @override
  String get description => 'Finds a list tile for a given File instance.';

  final File file;

  @override
  bool matches(Element candidate) {
    return candidate.widget is ListTile &&
        candidate.widget.key == ValueKey(file.id);
  }
}

extension on CommonFinders {
  FileListTileFinder fileListTile(File file) => FileListTileFinder(file);
}

void main() {
  setUpAll(() {
    registerFallbackValue(FileState.initial());
    registerFallbackValue<FileEvent>(const LoadFiles());
  });

  final file = FileRepo.initialFiles.values.first;

  group('Files', () {
    testWidgets('instantiates', (tester) async {
      const files = Files(isOld: false);
      await tester.pumpApp(files);
      await tester.pumpAndSettle();
      expect(find.byType(FilesView), findsOneWidget);
    });
  });

  group('FilesView', () {
    testWidgets('reloads files on pull-to-refresh', (tester) async {
      final fileBloc = MockFileBloc();
      final controller = StreamController<FileState>();

      whenListen(
        fileBloc,
        controller.stream,
        initialState: FileState(
          fileView: FileRepo.initialFiles,
          isLoading: false,
          pendingDeletions: const {},
        ),
      );

      await tester.pumpFileView(fileBloc);

      await tester.pumpAndSettle();

      final widgetToFling = find.byType(ListTile).first;
      expect(widgetToFling, findsOneWidget);

      await tester.fling(widgetToFling, const Offset(0, 500), 1000);

      await tester.pump();

      // Finish the scroll animation
      await tester.pump(const Duration(seconds: 1));
      // Finish the indicator settle animation
      await tester.pump(const Duration(seconds: 1));
      // Finish the indicator hide animation
      await tester.pump(const Duration(seconds: 1));

      await untilCalled(() => fileBloc.add(any(that: isA<LoadFiles>())));

      controller
        ..add(
          FileState(
            fileView: FileRepo.initialFiles,
            isLoading: true,
            pendingDeletions: const {},
          ),
        )
        ..add(
          FileState(
            fileView: FileRepo.initialFiles,
            isLoading: false,
            pendingDeletions: const {},
          ),
        );

      await tester.pumpAndSettle();

      verify(() => fileBloc.add(any(that: isA<LoadFiles>()))).called(1);
      await controller.close();
    });

    testWidgets('deletes file', (tester) async {
      final fileBloc = MockFileBloc();

      when(() => fileBloc.state).thenReturn(
        FileState(
          fileView: FileRepo.initialFiles,
          isLoading: false,
          pendingDeletions: const {},
        ),
      );

      await tester.pumpFileView(fileBloc);

      await tester.pumpAndSettle();

      final fileTile = find.fileListTile(file);
      expect(fileTile, findsOneWidget);

      final deleteAction = find.descendant(
        of: fileTile,
        matching: find.byType(DeleteAction),
      );
      expect(deleteAction, findsOneWidget);

      await tester.tap(deleteAction);
      when(() => fileBloc.state).thenReturn(
        FileState(
          fileView: FileRepo.initialFiles,
          isLoading: false,
          pendingDeletions: {file.id},
        ),
      );
      await tester.pump();

      verify(() => fileBloc.add(any(that: isA<DeleteFile>()))).called(1);
    });
  });

  group('DeleteAction', () {
    testWidgets('shows progress indicator when deleting', (tester) async {
      final fileBloc = MockFileBloc();

      when(() => fileBloc.state).thenReturn(
        FileState(
          fileView: FileRepo.initialFiles,
          isLoading: false,
          pendingDeletions: {file.id},
        ),
      );

      await tester.pumpFileView(fileBloc);

      final fileTile = find.ancestor(
        of: find.text(file.name),
        matching: find.byType(ListTile),
      );
      expect(fileTile, findsOneWidget);

      final deleteAction = find.fileListTile(file);
      expect(deleteAction, findsOneWidget);

      expect(
        find.descendant(
          of: deleteAction,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });
  });
}
