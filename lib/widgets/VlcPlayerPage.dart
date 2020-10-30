import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcPlayerPage extends StatefulWidget {
  final String pathVideo;

  const VlcPlayerPage({Key key, this.pathVideo}) : super(key: key);
  @override
  _VlcPlayerPageState createState() => _VlcPlayerPageState();
}

class _VlcPlayerPageState extends State<VlcPlayerPage> {
  VlcPlayerController controller = new VlcPlayerController();

  @override
  void initState() {
    super.initState();
    controller = new VlcPlayerController(onInit: () {
      controller.play();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VlcPlayer(
      autoplay: true,
      aspectRatio: 16 / 9,
      url: 'https://homeprolive-test.ml${widget.pathVideo}',
      controller: controller,
      placeholder: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
