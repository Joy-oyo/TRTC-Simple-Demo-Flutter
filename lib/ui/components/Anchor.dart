import 'package:flutter/material.dart';
import 'package:trtc_demo/ui/components/live_rtc.dart';

class Anchor extends StatefulWidget {
  const Anchor({Key? key}) : super(key: key);

  @override
  State<Anchor> createState() => _AnchorState();
}

class _AnchorState extends State<Anchor> {
  @override
  Widget build(BuildContext context) {
    return LiveRtc(
      isHost: true,
    );
  }
}
