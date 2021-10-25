import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

typedef FileId = int;
typedef DefaultFileProvider = Map<FileId, File> Function();

class File extends Equatable {
  File({required this.id, required this.name, DateTime? lastModified})
      : lastModified = lastModified ?? DateTime.now();

  final FileId id;
  final String name;
  final DateTime lastModified;

  @override
  List<Object?> get props => [name];
}

class FileRepo {
  FileRepo({DefaultFileProvider? defaultFileProvider})
      : _defaultFileProvider = defaultFileProvider ?? (() => initialFiles);

  @visibleForTesting
  static final Map<FileId, File> initialFiles = {
    1: File(id: 1, name: 'file1.txt'),
    2: File(id: 2, name: 'file2.txt'),
    3: File(id: 3, name: 'file3.txt'),
    4: File(id: 4, name: 'file4.txt'),
    5: File(id: 5, name: 'file5.txt'),
  };

  static const deleteFileDuration = Duration(seconds: 2);
  static const loadFilesDuration = Duration(seconds: 1);

  final Map<FileId, File> Function() _defaultFileProvider;

  late final Map<int, File> _files = _defaultFileProvider();

  Future<void> deleteFile({required FileId id}) async {
    await Future.delayed(deleteFileDuration, () {});
    if (!_files.containsKey(id)) {
      throw ArgumentError('File with id=$id does not exist');
    }
    _files.remove(id);
  }

  Future<Map<FileId, File>> loadFiles() async {
    await Future.delayed(loadFilesDuration, () {});
    if (_files.isEmpty) {
      _files.addAll(initialFiles);
    }
    return {..._files};
  }
}
