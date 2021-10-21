import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_bloc_new.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_bloc_old.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_events.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_state.dart';
import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';

abstract class VideoStreamBloc
    implements Bloc<VideoStreamEvent, VideoStreamState> {
  factory VideoStreamBloc({
    required bool isOld,
    required VideoStreamingRepo videoStreamingRepo,
    required VideoData frame,
  }) =>
      isOld
          ? VideoStreamBlocOld(
              videoStreamingRepo: videoStreamingRepo,
              frame: frame,
            )
          : VideoStreamBlocNew(
              videoStreamingRepo: videoStreamingRepo,
              frame: frame,
            );

  VideoStreamingRepo get videoStreamingRepo;
}
