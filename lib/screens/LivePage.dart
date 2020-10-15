import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/widgets/BackgroundLive.dart';
import 'package:test_live_app/widgets/ForegroundLive.dart';

class LivePage extends StatefulWidget {
  final String title;
  final String channelName;
  final String username;
  final String adminProfile;
  final String liveAdmin;
  final String appId;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const LivePage({
    Key key,
    this.channelName,
    this.title,
    this.role,
    this.username,
    this.adminProfile,
    this.liveAdmin,
    this.appId,
  }) : super(key: key);

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('=========================');
    print('From LivePage');
    print('title: ${widget.title}');
    print('adminProfile: assets/logo.png');
    print('liveAdmin ${widget.liveAdmin}');
    print('channelName ${widget.channelName}');
    print('username ${widget.username}');
    print('appId ${widget.appId}');
    print('=========================');
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
        children: <Widget>[
          BackgroundLive(
            channelName: widget.channelName,
            role: ClientRole.Audience,
            appId: widget.appId,
          ),
          PageView(
            controller: _pageController,
            children: [
              ForegroundLive(
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
