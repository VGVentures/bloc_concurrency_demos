import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_cubit.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_cubit_common.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_events.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';

class FileBlocNew extends Bloc<FileEvent, FileState>
    with FileCubitCommon
    implements FileCubit {
  FileBlocNew({required this.fileRepo}) : super(FileState.initial()) {
    on<LoadFiles>(
      (event, emit) => loadFiles(event, emit.call),
      // If a LoadFiles event is added while a previous LoadFiles event
      // is still processing, the previous LoadFiles event will be cancelled.
      // This is beneficial since we only care about the latest result, and
      // avoids waiting on unnecessary and possibly out of date results.
      transformer: restartable(),
    );
    on<DeleteFile>(
      (event, emit) => deleteFile(event, emit.call),
      // The default behavior of Bloc 7.2+ is to process events in parallel,
      // so we could have left out the transformer here.
      //
      // However, it is worth leaving here to indicate that the writes here
      // don't mutate the states of other files, so we can benefit from
      // concurrent processing.
      //
      // If the order of writes is important, we could have used sequential()
      // here.
      transformer: concurrent(),
    );
  }

  @override
  final FileRepo fileRepo;
}
