import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoStreamingRepo', () {
    test('cycle', () {
      expect(VideoStreamingRepo.cycle, isA<int>());
    });

    testWidgets('produces blank frame', (tester) async {
      await tester.runAsync<void>(() async {
        final frame = await VideoStreamingRepo.blankFrame;
        final image = await decodeImageFromList(frame.buffer.asUint8List());
        expect(image.width, VideoStreamingRepo.frameWidth);
        expect(image.height, VideoStreamingRepo.frameHeight);
      });
    });

    testWidgets('produces frames', (tester) async {
      await tester.runAsync<void>(() async {
        final frame = await VideoStreamingRepo().videoDataStream.first;
        final image = await decodeImageFromList(frame.buffer.asUint8List());
        expect(image.width, VideoStreamingRepo.frameWidth);
        expect(image.height, VideoStreamingRepo.frameHeight);
      });
    });
  });
}
