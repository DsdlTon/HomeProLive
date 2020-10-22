import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class BackgroundLive extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  final String appId;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const BackgroundLive({Key key, this.channelName, this.role, this.appId})
      : super(key: key);

  @override
  _BackgroundLiveState createState() => _BackgroundLiveState();
}

class _BackgroundLiveState extends State<BackgroundLive> {
  static final _users = <int>[]; //host
  final _infoStrings = <String>[]; //for showing in log msg

  bool muted = false;
  int userView = 0;
  var userMap;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    // _createClient();
  }

  Future<void> initialize() async {
    if (widget.appId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(1920, 1080);
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(widget.appId);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
        print('_infoStrings $_infoStrings');
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
        print('_infoStrings $_infoStrings');
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        print('_infoStrings $_infoStrings');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        print('_infoStrings $_infoStrings');
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        print('_infoStrings $_infoStrings');
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
        print('_infoStrings $_infoStrings');
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

// --------------------------------------------------------------------------------------------

  /// Video view wrapper
  Widget _videoView(view) {
    return Container(
      child: view,
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();

    switch (views.length) {
      case 1:
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _videoView(views[0]),
          ),
        );

      default:
    }
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.sentiment_dissatisfied, color: Colors.grey[600], size: 60),
            SizedBox(height: 10),
            Text(
              'Live is Ended.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
          ],
        ),
      ),
    );
  }
}
