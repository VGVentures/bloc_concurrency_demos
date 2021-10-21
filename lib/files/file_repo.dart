import 'package:equatable/equatable.dart';

typedef FileId = int;

class File extends Equatable {
  File({required this.id, required this.name, DateTime? lastModified})
      : lastModified = lastModified ?? DateTime.now();

  final FileId id;
  final String name;
  final DateTime lastModified;

  File renamed({required String name}) => File(name: name, id: id);

  @override
  List<Object?> get props => [name];
}

class FileRepo {
  static final _initialFiles = <FileId, File>{
    1: File(id: 1, name: 'file1.txt'),
    2: File(id: 2, name: 'file2.txt'),
    3: File(id: 3, name: 'file3.txt'),
    4: File(id: 4, name: 'file4.txt'),
    5: File(id: 5, name: 'file5.txt'),
  };

  final Map<int, File> _files = {};

  late FileId _nextId = _initialFiles.length + 1;

  Future<void> renameFile({required FileId id, required String newName}) async {
    await Future.delayed(const Duration(seconds: 10), () {});
    if (!_files.containsKey(id)) {
      throw ArgumentError('File with id=$id does not exist');
    }
    final file = _files[id]!;
    _files[id] = file.renamed(name: newName);
  }

  Future<void> deleteFile({required FileId id}) async {
    await Future.delayed(const Duration(seconds: 2), () {});
    if (!_files.containsKey(id)) {
      throw ArgumentError('File with id=$id does not exist');
    }
    _files.remove(id);
  }

  Future<void> createFile({required String name}) async {
    await Future.delayed(const Duration(seconds: 10), () {});
    if (_files.values.where((file) => file.name == name).isNotEmpty) {
      throw ArgumentError('File with name=$name already exists');
    }
    final file = File(id: _nextId++, name: name);
    _files[_nextId++] = file;
  }

  Future<Map<FileId, File>> loadFiles() async {
    await Future.delayed(const Duration(seconds: 1), () {});
    if (_files.isEmpty) {
      _files.addAll(_initialFiles);
    }
    return {..._files};
  }
}
