import 'package:bloc_concurrency_demos/video/bloc/video_stream_bloc.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_bloc_old.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_events.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_state.dart';
import 'package:bloc_concurrency_demos/video/view/video_stream_view.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class MockVideoStreamBloc extends MockBloc<VideoStreamEvent, VideoStreamState>
    implements VideoStreamBlocOld {}

void main() {
  setUpAll(() async {
    final frame = await getVideoFrame();
    registerFallbackValue(
      VideoStreamState(currentFrame: frame, isPlaying: false),
    );
    registerFallbackValue(const VideoStreamPlayPauseToggled());
  });
  group('VideoStream', () {
    testWidgets('instantiates', (tester) async {
      final frame = await getVideoFrameForWidgetTest(tester);
      final videoStream = VideoStream(isOld: false, blankFrame: frame);
      expect(videoStream, isA<VideoStream>());
      await tester.pumpApp(videoStream);
      expect(find.byType(VideoStreamView), findsOneWidget);
    });
  });

  group('VideoStreamView', () {
    testWidgets('toggles playing when pressing play button', (tester) async {
      final frame = await getVideoFrameForWidgetTest(tester);
      final videoBloc = MockVideoStreamBloc();

      const isPlaying = true;

      when(() => videoBloc.state).thenReturn(
        VideoStreamState(currentFrame: frame, isPlaying: isPlaying),
      );

      final widget = BlocProvider<VideoStreamBloc>(
        create: (_) => videoBloc,
        child: const VideoStreamView(isOld: false),
      );
      await tester.pumpApp(widget);
      final playPauseButton = find.byType(RawMaterialButton);
      expect(playPauseButton, findsOneWidget);
      await tester.tap(playPauseButton);
      verify(
        () => videoBloc.add(any(that: isA<VideoStreamPlayPauseToggled>())),
      );
    });
  });
}
