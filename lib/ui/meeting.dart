import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:trtc_demo/ui/components/Anchor.dart';
import 'package:trtc_demo/ui/components/Audience.dart';

/// Meeting Page
class MeetingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeetingPageState();
}

class MeetingPageState extends State<MeetingPage> {
  late MeetingModel _meetModel;
  @override
  void initState() {
    super.initState();
    _meetModel = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Meeting ${_meetModel.getMeetId()}"),
      ),
      body: _meetModel.isAnchor ? Anchor() : Audience(),
    );
  }
}
