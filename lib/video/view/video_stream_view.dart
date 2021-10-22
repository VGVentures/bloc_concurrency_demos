import 'package:bloc_concurrency_demos/l10n/l10n.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_bloc.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_events.dart';
import 'package:bloc_concurrency_demos/video/bloc/video_stream_state.dart';
import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoStream extends StatelessWidget {
  const VideoStream({Key? key, required this.isOld, required this.blankFrame})
      : super(key: key);

  final bool isOld;
  final VideoData blankFrame;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoStreamBloc(
        isOld: isOld,
        videoStreamingRepo: VideoStreamingRepo(),
        frame: blankFrame,
      ),
      child: VideoStreamView(isOld: isOld),
    );
  }
}

class VideoStreamView extends StatelessWidget {
  const VideoStreamView({Key? key, required this.isOld}) : super(key: key);

  final bool isOld;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isOld ? l10n.videoStreamViewTitleOld : l10n.videoStreamViewTitleNew,
        ),
      ),
      body: BlocBuilder<VideoStreamBloc, VideoStreamState>(
        builder: (context, state) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  state.currentFrame.buffer.asUint8List(),
                  gaplessPlayback: true,
                  fit: BoxFit.fitWidth,
                  cacheWidth: VideoStreamingRepo.frameWidth,
                  cacheHeight: VideoStreamingRepo.frameHeight,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    BlocProvider.of<VideoStreamBloc>(context).add(
                      const VideoStreamPlayPauseToggled(),
                    );
                  },
                  fillColor: Colors.red,
                  child: state.isPlaying
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
