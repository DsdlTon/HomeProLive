import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/widgets/WebViewPlayBack.dart';
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
            child: WebViewPlayback(pathVideo: widget.pathVideo),
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
