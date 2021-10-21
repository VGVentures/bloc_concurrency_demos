import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';

class VideoStreamState {
  const VideoStreamState({required this.currentFrame, required this.isPlaying});
  final VideoData currentFrame;
  final bool isPlaying;

  static VideoStreamState initial(VideoData frame) => VideoStreamState(
        currentFrame: frame,
        isPlaying: false,
      );
}
