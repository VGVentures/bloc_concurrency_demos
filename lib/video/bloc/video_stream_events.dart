import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';

abstract class VideoStreamEvent {}

class VideoStreamPlayPauseEvent extends VideoStreamEvent {
  VideoStreamPlayPauseEvent({required this.play});
  final bool play;
}

class VideoStreamUpdatedEventOld extends VideoStreamEvent {
  VideoStreamUpdatedEventOld({required this.frame});
  final VideoData frame;
}
