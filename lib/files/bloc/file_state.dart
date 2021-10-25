import 'package:bloc_concurrency_demos/files/file_repo.dart';
import 'package:equatable/equatable.dart';

enum FileOperationType {
  rename,
  delete,
}

class FileState extends Equatable {
  FileState({
    required this.fileView,
    this.error,
    required this.isLoading,
    required this.pendingDeletions,
  });

  FileState.initial()
      : this(
          fileView: const {},
          pendingDeletions: const {},
          isLoading: false,
        );

  final Map<FileId, File> fileView;
  late final List<File> files = fileView.values.toList();
  final Set<FileId> pendingDeletions;
  final bool isLoading;
  final Object? error;

  @override
  List<Object?> get props => [
        fileView,
        error,
        isLoading,
        pendingDeletions,
      ];

  @override
  String toString() => '''FileState(${fileView.keys}, $pendingDeletions)''';
}
