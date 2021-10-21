import 'dart:async';

import 'package:bloc_concurrency_demos/files/file_repo.dart';

abstract class FileEvent {}

class LoadFiles extends FileEvent {
  LoadFiles({this.completer});
  final Completer<void>? completer;
}

class DeleteFile extends FileEvent {
  DeleteFile({required this.fileId});
  final FileId fileId;
}
