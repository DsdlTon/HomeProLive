import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/widgets/VlcPlayerPage.dart';
import '../widgets/RecentForeground.dart';

class RecentLivePage extends StatefulWidget {
  final String title;
  final String channelName;
  final String username;
  final String adminProfile;
  final String liveAdmin;
  final String appId;
  final String view;
  final String pathVideo;

  final ClientRole role;

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
    this.view,
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
    super.initState();
    print('channelName: ${widget.channelName}');
    print('title: ${widget.title}');
    print('role: ${widget.role}');
    print('username: ${widget.username}');
    print('adminProfile: ${widget.adminProfile}');
    print('liveAdmin: ${widget.liveAdmin}');
    print('appId: ${widget.appId}');
    print('view: ${widget.view}');
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
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: ClipRRect(
              child: VlcPlayerPage(pathVideo: widget.pathVideo),
            ),
          ),
          PageView(
            controller: _pageController,
            children: [
              RecentForegroundLive(
                view: widget.view,
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
