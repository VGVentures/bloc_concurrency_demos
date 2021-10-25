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
      final fileCubit = MockFileCubit();
      when(() => fileCubit.state).thenReturn(FileState.initial());

      await tester.pumpApp(
        BlocProvider<FileCubit>.value(
          value: fileCubit,
          child: const FilesView(isOld: false),
        ),
      );
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);
      await tester.drag(refreshIndicator, const Offset(0, 500));
      await tester.pumpAndSettle(FileRepo.loadFilesDuration);
      verify(() => fileCubit.add(any(that: isA<LoadFiles>()))).called(1);
    });
  });
}
