import 'package:bloc_concurrency_demos/bootstrap.dart';
import 'package:bloc_concurrency_demos/files/view/file_view.dart';
import 'package:bloc_concurrency_demos/l10n/l10n.dart';
import 'package:bloc_concurrency_demos/registration/view/registration_view.dart';
import 'package:bloc_concurrency_demos/video/video_streaming_repo.dart';
import 'package:bloc_concurrency_demos/video/view/video_stream_view.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    required this.preloadedConfig,
  }) : super(key: key);

  VideoData get blankFrame => preloadedConfig.blankFrame;

  Map<String, Widget> _buildDemoFeatures(BuildContext context) => {
        context.l10n.videoStreamViewTitleOld: VideoStream(
          isOld: true,
          blankFrame: blankFrame,
        ),
        context.l10n.videoStreamViewTitleNew: VideoStream(
          isOld: false,
          blankFrame: blankFrame,
        ),
        context.l10n.filesViewTitleOld: const Files(isOld: true),
        context.l10n.filesViewTitleNew: const Files(isOld: false),
        context.l10n.registrationViewTitleOld: const Registration(isOld: true),
        context.l10n.registrationViewTitleNew: const Registration(isOld: false),
      };

  final AppPreloadedConfiguration preloadedConfig;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final demoFeatures = _buildDemoFeatures(context);
    final featureTitles = demoFeatures.keys.toList();
    final features = demoFeatures.values.toList();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListView.separated(
        primary: true,
        itemBuilder: (context, index) => DemoFeature(
          title: featureTitles[index],
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (context) => features[index]),
          ),
        ),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: demoFeatures.length,
      ),
    );
  }
}

class DemoFeature extends StatelessWidget {
  const DemoFeature({Key? key, required this.title, required this.onTap})
      : super(key: key);

  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
