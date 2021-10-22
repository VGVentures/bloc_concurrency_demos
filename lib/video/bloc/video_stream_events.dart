import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';

abstract class VideoStreamEvent {
  const VideoStreamEvent();
}

class VideoStreamPlayPauseToggled extends VideoStreamEvent {
  const VideoStreamPlayPauseToggled();  
}

class VideoStreamUpdatedOld extends VideoStreamEvent {
  const VideoStreamUpdatedOld({required this.frame});
  final VideoData frame;
}
