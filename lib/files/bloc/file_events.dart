import 'package:bloc_concurrency_demos/files/file_repo.dart';

abstract class FileEvent {
  const FileEvent();
}

class LoadFiles extends FileEvent {
  const LoadFiles();
}

class DeleteFile extends FileEvent {
  const DeleteFile({required this.fileId});
  final FileId fileId;
}
