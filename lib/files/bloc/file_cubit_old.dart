import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_cubit.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_cubit_common.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_events.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';

class FileCubitOld extends Cubit<FileState>
    with FileCubitCommon
    implements FileCubit {
  FileCubitOld({required this.fileRepo}) : super(FileState.initial());

  @override
  final FileRepo fileRepo;

  @override
  void add(FileEvent event) {
    // Make this cubit act like a bloc for ease-of-use in widget.
    if (event is LoadFiles) {
      loadFiles(event, emit);
    } else if (event is DeleteFile) {
      deleteFile(event, emit);
    }
  }
}
