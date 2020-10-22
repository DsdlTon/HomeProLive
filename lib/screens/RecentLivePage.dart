import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/Playback.dart';
import '../widgets/RecentForeground.dart';

class RecentLivePage extends StatefulWidget {
  final String title;
  final String channelName;
  final String username;
  final String adminProfile;
  final String liveAdmin;
  final String appId;
  final String pathVideo;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const RecentLivePage({
    Key key,
    this.channelName,
    this.title,
    this.role,
    this.username,
    this.adminProfile,
    this.liveAdmin,
    this.appId,
    this.pathVideo,
  }) : super(key: key);

  @override
  _RecentLivePageState createState() => _RecentLivePageState();
}

class _RecentLivePageState extends State<RecentLivePage> {
  PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('channelName: ${widget.channelName}');
    print('title: ${widget.title}');
    print('role: ${widget.role}');
    print('username: ${widget.username}');
    print('adminProfile: ${widget.adminProfile}');
    print('liveAdmin: ${widget.liveAdmin}');
    print('appId: ${widget.appId}');
    print('pathVideo: ${widget.pathVideo}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: PlaybackVideo(
                // videoPlayerController: VideoPlayerController.asset(
                //     'assets/video/testVideo.mov'),
                videoPlayerController: VideoPlayerController.network(
                  // 'https://188.166.189.84${widget.pathVideo}',
                  // 'https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_480_1_5MG.mp4',
                  // 'https://188.166.189.84/recorder/video/8f5cbe16-906c-4011-84f0-e1c485cd56ce/0_20201015084314783.mp4',
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
                ),
              ),
            ),
          ),
          PageView(
            controller: _pageController,
            children: [
              RecentForegroundLive(
                title: widget.title,
                channelName: widget.channelName,
                adminProfile: widget.adminProfile,
                liveAdmin: widget.liveAdmin,
                username: widget.username,
              ),
              Container(),
            ],
          ),
        ],
      ),
    );
  }
}
