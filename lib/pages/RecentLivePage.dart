import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/widgets/BackgroundLive.dart';
import 'package:test_live_app/widgets/RecentForeground.dart';

class RecentLivePage extends StatefulWidget {
  final String title;
  final String channelName;
  final String username;
  final String userProfile;
  final String liveUser;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const RecentLivePage({
    Key key,
    this.channelName,
    this.title,
    this.role,
    this.username,
    this.userProfile,
    this.liveUser,
  }) : super(key: key);

  @override
  _RecentLivePageState createState() => _RecentLivePageState();
}

class _RecentLivePageState extends State<RecentLivePage> {
  PageController _pageController = PageController(
    initialPage: 0,
  );

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
          ),
          PageView(
            controller: _pageController,
            children: [
              RecentForegroundLive(
                title: widget.title,
                channelName: widget.channelName,
                userProfile: widget.userProfile,
                liveUser: widget.liveUser,
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
