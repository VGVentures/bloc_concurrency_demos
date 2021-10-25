import 'dart:async';

import 'package:bloc_concurrency_demos/files/file_repo.dart';
import 'package:mocktail/mocktail.dart';

class MockFileRepo extends Mock implements FileRepo {}

class MockCompleter extends Mock implements Completer<void> {}
