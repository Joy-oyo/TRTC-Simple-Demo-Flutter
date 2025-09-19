import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:trtc_demo/ui/components/live_player.dart';
import 'package:trtc_demo/ui/components/live_rtc.dart';

class Audience extends StatefulWidget {
  const Audience({Key? key}) : super(key: key);

  @override
  State<Audience> createState() => _AudienceState();
}

class _AudienceState extends State<Audience> {
  late MeetingModel _meetModel;
  bool _isRTC = false;

  @override
  void initState() {
    super.initState();
    _meetModel = context.read();
  }

  @override
  Widget build(BuildContext context) {

   ElevatedButton button = ElevatedButton(
      onPressed: () {
        _isRTC = !_isRTC;
        this.setState((){});
      },
      child: Text(_isRTC ? "Yield the floor" : "Take the floor​"),
    );

    Row row = Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [button]);
    Container container = Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 30),height: 70.0,child: row);
    Align align = Align(alignment: Alignment.bottomCenter, child: container);

    StatefulWidget rootView = _isRTC
        ? LiveRtc(isHost: false)
        : LivePlayer(streamId: _meetModel.getMeetId().toString());

    return Stack(children: [rootView, align]);
  }
}
