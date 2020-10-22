import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class PlaybackVideo extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const PlaybackVideo({
    Key key,
    @required this.videoPlayerController,
  }) : super(key: key);

  @override
  _PlaybackVideoState createState() => _PlaybackVideoState();
}

class _PlaybackVideoState extends State<PlaybackVideo> {
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
        videoPlayerController: widget.videoPlayerController,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        autoPlay: true,
        allowedScreenSleep: false,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        looping: true,
        showControls: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.white),
            ),
          );
        });
    _chewieController.addListener(() {
      if (_chewieController.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
    print('Received: ${widget.videoPlayerController}');
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }
}
