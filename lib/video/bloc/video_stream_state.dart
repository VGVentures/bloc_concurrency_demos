import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';

class VideoStreamState {
  const VideoStreamState({required this.currentFrame, required this.isPlaying});

  const VideoStreamState.initial(VideoData frame)
      : this(currentFrame: frame, isPlaying: false);

  final VideoData currentFrame;
  final bool isPlaying;
}
