import 'dart:async';

import 'package:bloc_concurrency_demos/files/bloc/file_cubit.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_events.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';

mixin FileCubitCommon implements FileCubit {
  Future<void> loadFiles(
    LoadFiles event,
    void Function(FileState) emit,
  ) async {
    Map<FileId, File>? files;
    Object? error;
    try {
      emit(
        FileState(
          fileView: state.fileView,
          pendingDeletions: state.pendingDeletions,
          isLoading: true,
        ),
      );
      files = await fileRepo.loadFiles();
    } catch (e) {
      error = e;
    } finally {
      final completer = event.completer;
      if (completer != null) completer.complete();
      emit(
        FileState(
          fileView: files ?? state.fileView,
          pendingDeletions: state.pendingDeletions,
          isLoading: false,
          error: error,
        ),
      );
    }
  }

  Future<void> deleteFile(
    DeleteFile event,
    void Function(FileState) emit,
  ) async {
    if (state.pendingDeletions.contains(event.fileId)) {
      return;
    }
    emit(
      FileState(
        fileView: state.fileView,
        isLoading: state.isLoading,
        pendingDeletions: {
          ...state.pendingDeletions,
          event.fileId,
        },
      ),
    );
    try {
      await fileRepo.deleteFile(id: event.fileId);
      emit(
        FileState(
          isLoading: state.isLoading,
          fileView: {...state.fileView}..remove(event.fileId),
          pendingDeletions: {
            ...state.pendingDeletions,
          }..remove(event.fileId),
        ),
      );
    } catch (e) {
      emit(
        FileState(
          isLoading: state.isLoading,
          fileView: state.fileView,
          pendingDeletions: {
            ...state.pendingDeletions,
          }..remove(event.fileId),
          error: e,
        ),
      );
    }
  }
}
