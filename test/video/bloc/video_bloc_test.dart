import 'package:bloc_concurrency_demos/video/bloc/video_stream_bloc.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_events.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_state.dart';
import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class MockVideoStreamingRepo extends Mock implements VideoStreamingRepo {}

Future<void> main() async {
  final frame = await getVideoFrame();
  final otherFrame = await VideoStreamingRepo().getNextFrame(1);
  for (var i = 0; i < 2; i++) {
    final isOld = i == 0;
    final old = isOld ? 'Old' : 'New';
    group('VideoStreamBloc$old', () {
      final repo = MockVideoStreamingRepo();

      blocTest<VideoStreamBloc, VideoStreamState>(
        '$old instantiates with no errors',
        build: () => VideoStreamBloc(
          isOld: isOld,
          videoStreamingRepo: repo,
          frame: frame,
        ),
        errors: () => isEmpty,
      );

      blocTest<VideoStreamBloc, VideoStreamState>(
        'yields playing state',
        setUp: () {
          when(() => repo.videoDataStream).thenAnswer(
            (_) => Stream.fromIterable([frame]),
          );
        },
        build: () => VideoStreamBloc(
          isOld: isOld,
          videoStreamingRepo: repo,
          frame: frame,
        ),
        act: (bloc) => bloc.add(VideoStreamPlayPauseEvent(play: true)),
        wait: Duration.zero,
        expect: () => [
          isA<VideoStreamState>()
              .having(
                (state) => state.isPlaying,
                'isPlaying',
                true,
              )
              .having(
                (state) => state.currentFrame,
                'currentFrame',
                isA<VideoData>(),
              )
        ],
      );

      blocTest<VideoStreamBloc, VideoStreamState>(
        'yields paused state',
        setUp: () {
          when(() => repo.videoDataStream).thenAnswer(
            (_) => Stream.fromIterable([frame]),
          );
        },
        build: () => VideoStreamBloc(
          isOld: isOld,
          videoStreamingRepo: repo,
          frame: frame,
        ),
        act: (bloc) => bloc.add(VideoStreamPlayPauseEvent(play: false)),
        expect: () => [
          isA<VideoStreamState>()
              .having(
                (state) => state.isPlaying,
                'isPlaying',
                false,
              )
              .having(
                (state) => state.currentFrame,
                'currentFrame',
                isA<VideoData>(),
              )
        ],
      );

      if (isOld) {
        blocTest<VideoStreamBloc, VideoStreamState>(
          'emits on stream update if playing',
          build: () => VideoStreamBloc(
            isOld: isOld,
            videoStreamingRepo: repo,
            frame: frame,
          ),
          seed: () => VideoStreamState(
            currentFrame: otherFrame,
            isPlaying: true,
          ),
          act: (bloc) => bloc.add(VideoStreamUpdatedEventOld(frame: frame)),
          expect: () => [
            isA<VideoStreamState>().having(
              (state) => state.currentFrame,
              'currentFrame',
              equals(frame),
            )
          ],
        );
      }
    });
  }
}
