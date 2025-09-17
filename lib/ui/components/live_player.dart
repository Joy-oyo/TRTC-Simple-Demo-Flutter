import 'package:flutter/material.dart';
import 'package:super_player/super_player.dart';

class LivePlayer extends StatefulWidget {
  LivePlayer({Key? key,required this.isAnchor,required this.onAnchorStateChanged,required this.streamId}): super(key: key);
  bool isAnchor;
  String streamId;
  VoidCallback onAnchorStateChanged;

  @override
  State<LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends State<LivePlayer> {
  late TXLivePlayerController _controller;
  @override
  void initState() {
    super.initState();
    SuperPlayerPlugin.setGlobalLicense(
        "",   // set licenseURL
        "");  // set licenseKey
    _controller = TXLivePlayerController()..setRenderMode(FTXPlayerRenderMode.ADJUST_RESOLUTION);
    String flvUrl = "https://liveplay.boyang.work/live/${ widget.streamId}.flv";       // Your live stream URL
    _controller.startLivePlay(flvUrl).then(print);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.stop();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TXPlayerVideo(
        onRenderViewCreatedListener: (viewId) {
          _controller.setPlayerView(viewId);
        },
      ),
    );
  }
}
