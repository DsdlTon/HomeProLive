import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPlayback extends StatefulWidget {
  final String pathVideo;

  const WebViewPlayback({Key key, this.pathVideo}) : super(key: key);
  @override
  createState() => _WebViewPlaybackState();
}

class _WebViewPlaybackState extends State<WebViewPlayback> {
  InAppWebViewController _webViewController;
  double progress = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Container(
              margin: const EdgeInsets.all(0.0),
              child: InAppWebView(
                initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html>
<body style="background-color:black">
<script>

</script>

<section>
  <video src="https://188.166.189.84${widget.pathVideo}" autoplay muted></video>
</section>
</body>
<style>
video{
position:absolute;
  top:0;
  left:0;
  display:block;
  width:100%;
  height:100%;
  object-fit:cover
}
body{
  margin:0}

section{
  display:flex;
  justify-content:center;
  align-items:center;
  width:100%;
  height:100vh;
  overflow:hidden}
</style>
</html>
                  """),
//                    initialUrl: "https://188.166.189.84/recorder/video/8f5cbe16-906c-4011-84f0-e1c485cd56ce/0_20201015084314783.mp4",
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                  debuggingEnabled: true,
                )),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onLoadStart: (InAppWebViewController controller, String url) {},
                onLoadStop:
                    (InAppWebViewController controller, String url) async {},
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                onReceivedServerTrustAuthRequest:
                    (InAppWebViewController controller,
                        ServerTrustChallenge challenge) async {
                  return ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED);
                },
              ),
            )),
      ),
    );
  }
}
