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
  bool _isAnchor = false;
  @override
  void initState() {
    super.initState();
    _meetModel = context.read();
    _isAnchor = _meetModel.isAnchor;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _isAnchor
            ? LiveRtc(
                isAnchor: _isAnchor,
              )
            : LivePlayer(
                streamId: _meetModel.getMeetId().toString(),
                isAnchor: _isAnchor,
                onAnchorStateChanged: () => {},
              ),
        if (!_meetModel.isAnchor)
          Align(
              child: new Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isAnchor = !_isAnchor;
                          });
                        },
                        child: Text(_isAnchor
                            ? "Switch to Audience"
                            : "Go live together​"))
                  ],
                ),
                height: 70.0,
              ),
              alignment: Alignment.bottomCenter)
      ],
    );
  }
}
