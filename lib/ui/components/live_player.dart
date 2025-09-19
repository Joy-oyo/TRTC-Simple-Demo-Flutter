import 'package:flutter/material.dart';
import 'package:super_player/super_player.dart';
import 'package:trtc_demo/ui/components/config.dart';

class LivePlayer extends StatefulWidget {
  LivePlayer({Key? key,required this.streamId}): super(key: key);

  String streamId;

  @override
  State<LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends State<LivePlayer> {
  late TXLivePlayerController _playerController;
  @override
  void initState() {
    super.initState();
    SuperPlayerPlugin.setGlobalLicense(
        Config.licenseURL,     // set licenseURL
        Config.licenseKey);    // set licenseKey
    _playerController = TXLivePlayerController()..setRenderMode(FTXPlayerRenderMode.ADJUST_RESOLUTION);
    // String flvUrl = "https://${Config.playDomain}/live/${ widget.streamId}.flv"; 
    String flvUrl = "webrtc://${Config.playDomain}/live/${ widget.streamId}";       // Your live stream URL
    _playerController.startLivePlay(flvUrl).then(print);                            // play cdn stream
  }

  @override
  void dispose() {
    super.dispose();
    _playerController.stop();
    _playerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TXPlayerVideo(
        onRenderViewCreatedListener: (viewId) {
          _playerController.setPlayerView(viewId);
        },
      ),
    );
  }
}
