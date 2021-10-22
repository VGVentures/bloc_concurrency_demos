import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_bloc.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_events.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_state.dart';
import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';

class VideoStreamBlocNew extends Bloc<VideoStreamEvent, VideoStreamState>
    implements VideoStreamBloc {
  VideoStreamBlocNew({
    required this.videoStreamingRepo,
    required VideoData frame,
  }) : super(VideoStreamState.initial(frame)) {
    on<VideoStreamPlayPauseToggled>(
      (event, emit) async {
        if (!state.isPlaying) {
          // ------------------------------------------------------------------- //
          // BAD—THIS WILL NOT GET CANCELED PROPERLY IF THE EVENT IS RESTARTED
          // ------------------------------------------------------------------- //
          // await for (final videoData in videoStreamingRepo.videoDataStream) {
          //   emit(VideoStreamState(currentFrame: videoData, isPlaying: true));
          // }
          // ------------------------------------------------------------------- //
          //
          // INSTEAD ....
          //
          // ------------------------------------------------------------------- //
          // Use this! This is like `await for`, but allows cancelation!
          // ------------------------------------------------------------------- //
          await emit.forEach<VideoData>(
            videoStreamingRepo.videoDataStream,
            onData: (videoStreamData) => VideoStreamState(
              currentFrame: videoStreamData,
              isPlaying: true,
            ),
          );
          // ------------------------------------------------------------------- //
          // ------------------------------------------------------------------- //
        } else {
          emit(
            VideoStreamState(
              currentFrame: state.currentFrame,
              isPlaying: false,
            ),
          );
        }
      },
      // Allow only one of these events to ever be active at once, canceling
      // any active `emit.forEach` above.
      transformer: restartable(),
    );
  }

  @override
  final VideoStreamingRepo videoStreamingRepo;
}
