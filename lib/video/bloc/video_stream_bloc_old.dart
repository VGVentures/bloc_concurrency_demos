import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_bloc.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_events.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_state.dart';
import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';

class VideoStreamBlocOld extends Bloc<VideoStreamEvent, VideoStreamState>
    implements VideoStreamBloc {
  VideoStreamBlocOld({
    required this.videoStreamingRepo,
    required VideoData frame,
  }) : super(VideoStreamState.initial(frame));

  @override
  final VideoStreamingRepo videoStreamingRepo;
  StreamSubscription<VideoData>? _subscription;

  @override
  Stream<VideoStreamState> mapEventToState(VideoStreamEvent event) async* {
    if (event is VideoStreamPlayPauseToggled) {
      if (!state.isPlaying) {
        _subscription ??= videoStreamingRepo.videoDataStream.listen((data) {
          add(VideoStreamUpdatedOld(frame: data));
        });
      } else {
        await _subscription?.cancel();
        _subscription = null;
        yield VideoStreamState(
          currentFrame: state.currentFrame,
          isPlaying: false,
        );
      }
    } else if (event is VideoStreamUpdatedOld) {
      yield VideoStreamState(currentFrame: event.frame, isPlaying: true);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
