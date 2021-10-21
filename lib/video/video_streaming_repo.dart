import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

typedef VideoData = ByteData;

class VideoStreamingRepo {
  static const int _frameDelay = 50; // # of milliseconds to create a frame
  static final int cycle = (2 /* seconds */ / _frameDelay * 1000).round();
  static const int frameWidth = 640;
  static const int frameHeight = 480;
  static final Rect _rect = Rect.fromLTWH(
    0,
    0,
    frameWidth.toDouble(),
    frameHeight.toDouble(),
  );

  static Future<VideoData> get blankFrame async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder)..clipRect(_rect, doAntiAlias: false);

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRect(_rect, paint);

    final picture = recorder.endRecording();

    final pngBytes = (await (await picture.toImage(frameWidth, frameHeight))
        .toByteData(format: ImageByteFormat.png))!;

    return pngBytes;
  }

  late final Stream<VideoData> videoDataStream =
      _videoDataStream().asBroadcastStream();

  Stream<VideoData> _videoDataStream() async* {
    yield* Stream<Future<VideoData>>.periodic(
      const Duration(milliseconds: _frameDelay),
      getNextFrame,
    ).asyncMap((event) async => event);
  }

  // Based on https://stackoverflow.com/q/54465835
  @visibleForTesting
  Future<VideoData> getNextFrame(int frameNumber) async {
    // Pretend this frame came from a socket connection with a server
    // (or something like that)...
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder)..clipRect(_rect, doAntiAlias: false);

    var n = (frameNumber % cycle) / cycle;
    if (n > .5) n = 1 - n;
    n = n.clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Color.lerp(
        Colors.red,
        Colors.blue,
        Curves.linear.transform(n),
      )!
      ..style = PaintingStyle.fill;

    canvas.drawRect(_rect, paint);

    final picture = recorder.endRecording();

    final pngBytes = (await (await picture.toImage(frameWidth, frameHeight))
        .toByteData(format: ImageByteFormat.png))!;

    // Usage: var image = Image.memory(pngBytes.buffer.asUint8List());
    return pngBytes;
  }
}
