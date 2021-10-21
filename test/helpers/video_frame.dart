import 'dart:async';
import 'dart:developer';

import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';
import 'package:flutter_test/flutter_test.dart';

Future<VideoData> getVideoFrame() async {
  // Can't do image generation without doing it in our own zone...
  final frame = await runZonedGuarded(
    () async => VideoStreamingRepo.blankFrame,
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
  if (frame == null) fail('video frame must load');
  return frame;
}

Future<VideoData> getVideoFrameForWidgetTest(WidgetTester tester) async {
  // This has to be done in `runAsync` for widget tests, for whatever reasons.
  final frame = await tester.runAsync(() => VideoStreamingRepo.blankFrame);
  if (frame == null) fail('video frame must load');
  return frame;
}
