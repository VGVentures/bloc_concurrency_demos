import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_bloc_new.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_cubit_old.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_events.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';

abstract class FileCubit implements Cubit<FileState> {
  factory FileCubit({required bool isOld, required FileRepo fileRepo}) => isOld
      ? FileCubitOld(fileRepo: fileRepo)
      : FileBlocNew(fileRepo: fileRepo);

  FileRepo get fileRepo;

  void add(FileEvent event);
}
