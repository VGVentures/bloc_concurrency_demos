import 'dart:async';

import 'package:bloc_concurrency_demos/files/bloc/file_cubit.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_events.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';
import 'package:bloc_concurrency_demos/files/view/file_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';
import '../file_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FileState.initial());
    registerFallbackValue<Completer<void>>(MockCompleter());
    registerFallbackValue<FileEvent>(LoadFiles());
  });
  group('Files', () {
    testWidgets('instantiates', (tester) async {
      const files = Files(isOld: false);
      await tester.pumpApp(files);
      await tester.pumpAndSettle();
      expect(find.byType(FilesView), findsOneWidget);
    });
  });

  group('FilesView', () {
    testWidgets('pulls-to-refresh', (tester) async {
      final repo = MockFileRepo();
      when(repo.loadFiles).thenAnswer(
        (_) async => const {
          1: File(id: 1, name: 'file1.txt'),
        },
      );

      final fileCubit = FileCubit(isOld: false, fileRepo: repo)
        ..add(LoadFiles());

      await tester.pumpApp(
        BlocProvider<FileCubit>.value(
          value: fileCubit,
          child: const FilesView(isOld: false),
        ),
      );
      await tester.pumpAndSettle();

      verify(repo.loadFiles).called(1);

      final widgetToFling = find.byType(ListTile);
      expect(widgetToFling, findsOneWidget);
      await tester.fling(widgetToFling, const Offset(0, 500), 1000);

      await tester.pumpAndSettle();

      verify(repo.loadFiles).called(1);
    });
  });
}
