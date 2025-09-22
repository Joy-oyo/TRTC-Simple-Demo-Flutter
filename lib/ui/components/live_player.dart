import 'package:flutter/material.dart';
// import 'package:super_player/super_player.dart';  // Temporarily commented out due to dependency conflict
import 'package:trtc_demo/ui/components/config.dart';

class LivePlayer extends StatefulWidget {
  LivePlayer({Key? key,required this.streamId}): super(key: key);

  String streamId;

  @override
  State<LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends State<LivePlayer> {
  // late TXLivePlayerController _playerController;  // Temporarily commented out due to super_player dependency
  @override
  void initState() {
    super.initState();
    // SuperPlayerPlugin.setGlobalLicense(
    //     Config.licenseURL,     // set licenseURL
    //     Config.licenseKey);    // set licenseKey
    // _playerController = TXLivePlayerController()..setRenderMode(FTXPlayerRenderMode.ADJUST_RESOLUTION);
    // String flayUrl = "https://${Config.playDomain}/live/${ widget.streamId}.flv"; 
    // String flayUrl = "webrtc://${Config.playDomain}/live/${ widget.streamId}";       // Your live stream URL
    // _playerController.startLivePlay(flayUrl).then(print);                            // play cdn stream
  }

  @override
  void dispose() {
    super.dispose();
    // _playerController.stop();
    // _playerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Live Player disabled due to dependency conflict\nStream ID: ${widget.streamId}',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      // child: TXPlayerVideo(
      //   onRenderViewCreatedListener: (viewId) {
      //     _playerController.setPlayerView(viewId);
      //   },
      // ),
    );
  }
}
