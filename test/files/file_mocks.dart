import 'package:bloc_concurrency_demos/files/bloc/file_cubit.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileBloc extends MockCubit<FileState> implements FileCubit {}

class MockFileRepo extends Mock implements FileRepo {}
