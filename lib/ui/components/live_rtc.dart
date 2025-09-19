import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:trtc_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_demo/models/data_models.dart';
import 'package:trtc_demo/models/meeting_model.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:trtc_demo/models/user_model.dart';
import 'package:trtc_demo/ui/components/config.dart';
import 'package:trtc_demo/ui/login.dart';
import 'package:trtc_demo/utils/tool.dart';

class LiveRtc extends StatefulWidget { 
  
  LiveRtc({Key? key, required this.isHost}) : super(key: key);

  final bool isHost; // Whether the current user is the host

  @override
  State<LiveRtc> createState() => _LiveRtcState();
}

class _LiveRtcState extends State<LiveRtc> with WidgetsBindingObserver {
  late MeetingModel _meetModel;
  late TRTCCloud _trtcCloud;
  List<UserModel> _userList = [];
  List _screenUserList = [];
  String? _mixStreamTaskId;
  String? _mixStreamId;

  late TRTCCloudListener _listener;

  int _logShowLevel = 0;

  _printLog(int level, String msg) {
    if (level > _logShowLevel) {
      debugPrint(msg);
    }
  }

  TRTCCloudListener getListener() {
    return TRTCCloudListener(
      onError: (errCode, errMsg) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onError errCode:$errCode errMsg:$errMsg");
        _showErrorDialog(errMsg);
      },
      onWarning: (warningCode, warningMsg) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onWarning warningCode:$warningCode warningMsg:$warningMsg");
      },
      onEnterRoom: (result) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onEnterRoom result:$result");

        if (result > 0) {
          MeetingTool.toast('Enter room success', context);
        }
      },
      onExitRoom: (reason) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onExitRoom reason:$reason");

        if (reason > 0) {
          MeetingTool.toast('Exit room success', context);
        }
      },
      onSwitchRole: (errCode, errMsg) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onSwitchRole errCode:$errCode errMsg:$errMsg");
      },
      onRemoteUserEnterRoom: (userId) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteUserEnterRoom userId:$userId");

        _handleOnRemoteUserEnterRoom(userId);
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteUserLeaveRoom userId:$userId reason:$reason");

        _handleOnRemoteUserLeaveRoom(userId);
      },
      onUserVideoAvailable: (userId, available) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVideoAvailable userId:$userId available:$available");

        _handleOnUserVideoAvailable(userId, available);
      },
      onUserSubStreamAvailable: (userId, available) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserSubStreamAvailable userId:$userId available:$available");

        _handleOnUserSubStreamAvailable(userId, available);
      },
      onUserAudioAvailable: (userId, available) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserAudioAvailable userId:$userId available:$available");

        _handleOnUserAudioAvailable(userId, available);
      },
      onFirstVideoFrame: (userId, streamType, width, height) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onFirstVideoFrame userId:$userId streamType:$streamType width:$width height:$height");
      },
      onFirstAudioFrame: (userId) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onFirstAudioFrame userId:$userId");
      },
      onSendFirstLocalVideoFrame: (streamType) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onSendFirstLocalVideoFrame streamType:$streamType");
      },
      onRemoteVideoStatusUpdated: (userId, streamType, status, reason) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteVideoStatusUpdated userId:$userId streamType:$streamType status:$status reason:$reason");
      },
      onRemoteAudioStatusUpdated: (userId, status, reason) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onRemoteAudioStatusUpdated userId:$userId status:$status reason:$reason");
      },
      onUserVideoSizeChanged: (userId, streamType, newWidth, newHeight) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVideoSizeChanged userId:$userId streamType:$streamType newWidth:$newWidth newHeight:$newHeight");
      },
      onNetworkQuality: (localQuality, remoteQuality) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onNetworkQuality localQuality userId:${localQuality.userId} quality:${localQuality.quality}");

        for (TRTCQualityInfo info in remoteQuality) {
          _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onNetworkQuality remoteQuality userId:${info.userId} quality:${info.quality}");
        }
      },
      onStatistics: (statistics) {
        _printLog(
            1,
            "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics "
            "appCu:${statistics.appCpu} systemCu:${statistics.systemCpu} upLoss:${statistics.upLoss} "
            "downLoss:${statistics.downLoss} rtt:${statistics.rtt} gatewayRtt:${statistics.gatewayRtt} "
            "sendBytes:${statistics.sentBytes} receiveBytes:${statistics.receivedBytes}");

        for (TRTCLocalStatistics info in statistics.localStatisticsArray!) {
          _printLog(
              1,
              "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics width:${info.width} height:${info.height} frameRate:${info.frameRate} \n"
              " onStatistics videoBitrate:${info.videoBitrate} audioSampleRate:${info.audioSampleRate} audioBitrate:${info.audioBitrate} \n"
              " onStatistics streamType:${info.streamType} audioCaptureState:${info.audioCaptureState}");
        }

        for (TRTCRemoteStatistics info in statistics.remoteStatisticsArray!) {
          _printLog(
              1,
              "TRTCCloudExample TRTCCloudListenerparseCallbackParam onStatistics userId:${info.userId} audioPacketLoss:${info.audioPacketLoss} videoPacketLoss:${info.videoPacketLoss} \n"
              " onStatistics width:${info.width} height:${info.height} frameRate:${info.frameRate} videoBitrate:${info.videoBitrate} audioSampleRate:${info.audioSampleRate} \n"
              " onStatistics audioBitrate:${info.audioBitrate} jitterBufferDelay:${info.jitterBufferDelay} point2PointDelay:${info.point2PointDelay} audioTotalBlockTime:${info.audioTotalBlockTime} \n"
              " onStatistics audioBlockRate:${info.audioBlockRate} videoTotalBlockTime:${info.videoTotalBlockTime} videoBlockRate:${info.videoBlockRate} finalLoss:${info.finalLoss} remoteNetworkUplinkLoss:${info.remoteNetworkUplinkLoss} \n"
              " onStatistics remoteNetworkRTT:${info.remoteNetworkRTT} streamType:${info.streamType}");
        }
      },
      onConnectionLost: () {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onConnectionLost");
      },
      onTryToReconnect: () {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onTryToReconnect");
      },
      onConnectionRecovery: () {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onConnectionRecovery");
      },
      onCameraDidReady: () {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onCameraDidReady");
      },
      onMicDidReady: () {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onMicDidReady");
      },
      onUserVoiceVolume: (userVolumes, totalVolume) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVoiceVolume totalVolume:$totalVolume");

        for (TRTCVolumeInfo info in userVolumes) {
          _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onUserVoiceVolume userId:${info.userId} volume:${info.volume}");
        }
      },
      onStartPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onStartPublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
        _mixStreamTaskId = taskId;
      },
      onUpdatePublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onUpdatePublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
        _mixStreamTaskId = taskId;
      },
      onStopPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onStopPublishMediaStream taskId:$taskId errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
        _mixStreamTaskId = null;
      },
      onCdnStreamStateChanged: (cdnUrl, status, errCode, errMsg, extraInfo) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onCdnStreamStateChanged cdnUrl:$cdnUrl status:$status errCode:$errCode errMsg:$errMsg extraInfo:$extraInfo");
      },
      onSnapshotComplete: (userId, path, errorCode, errMsg) {
        _printLog(1,"TRTCCloudExample TRTCCloudListenerparseCallbackParam onSnapshotComplete userId:$userId path:$path errorCode:$errorCode errMsg:$errMsg");
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed: //Switch from the background to the foreground, and the interface is visible
        if (!kIsWeb && Platform.isAndroid) {
          List<UserModel> userListLast = jsonDecode(jsonEncode(_userList));
          _userList = [];
          _screenUserList = MeetingTool.getScreenList(_userList);
          this.setState(() {});

          const timeout = const Duration(milliseconds: 100); //10ms
          Timer(timeout, () {
            _userList = userListLast;
            _screenUserList = MeetingTool.getScreenList(_userList);
            this.setState(() {});
          });
        }
        break;
      case AppLifecycleState.paused: // Interface invisible, background
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  _initData() {
    _userList.add(_meetModel.getUserInfo());
    _screenUserList = MeetingTool.getScreenList(_userList);

    _meetModel.setList(_userList);
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _meetModel = context.read<MeetingModel>();
    _initRoom();
  }

  _initRoom() async {
    // Create TRTCCloud singleton
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = getListener();
    _trtcCloud.registerListener(_listener);
    // Enter the room
    _enterRoom();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  // Enter the trtc room
  _enterRoom() {
    try {
      // Generate usersig
      _meetModel.getUserInfo().userSig = GenerateTestUserSig.genTestSig(_meetModel.getUserInfo().userId);
    } catch (err) {
      _meetModel.getUserInfo().userSig = '';
      print(err);
    }
    _mixStreamId = _meetModel.getMeetId().toString();
    // set anchor push video Resolution parameters
    TRTCVideoEncParam videoEncParam = TRTCVideoEncParam();
    videoEncParam.videoResolutionMode = TRTCVideoResolutionMode.portrait;
    videoEncParam.videoResolution = TRTCVideoResolution.res_1280_720;
    videoEncParam.videoFps = 15;
    videoEncParam.videoBitrate = 1800;
    _trtcCloud.setVideoEncoderParam(videoEncParam);

    // open mic
    if (_meetModel.getUserInfo().isOpenMic) {
      if (kIsWeb) {
        Future.delayed(Duration(seconds: 3), () {
          _trtcCloud.startLocalAudio(_meetModel.getQuality());
        });
      } else {
        _trtcCloud.startLocalAudio(_meetModel.getQuality());
      }
    }

    // Set the parameters for entering the room
    TRTCParams trtcParams = TRTCParams();
    trtcParams.sdkAppId = GenerateTestUserSig.sdkAppId;
    trtcParams.userId = _meetModel.getUserInfo().userId;
    trtcParams.userSig = _meetModel.getUserInfo().userSig ?? '';
    trtcParams.role = TRTCRoleType.anchor;
    trtcParams.roomId = _meetModel.getMeetId()!;
    // enter room
    _trtcCloud.enterRoom(trtcParams, TRTCAppScene.live);

    _startMixStream();
  }

  _destroyRoom() {
    _stopMixStream();
    _trtcCloud.stopLocalPreview();
    _trtcCloud.stopLocalAudio();
    _trtcCloud.exitRoom();
    _trtcCloud.unRegisterListener(_listener);
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _destroyRoom();
    super.dispose();
  }

  _handleOnRemoteUserEnterRoom(param) {
    UserModel user = UserModel(userId: param);
    user.type = 'video';
    user.isOpenCamera = false;
    user.size = WidgetSize(width: 0, height: 0);
    _userList.add(user);

    _screenUserList = MeetingTool.getScreenList(_userList);
    this.setState(() {});
    _meetModel.setList(_userList);
    _updateMixStream();
  }

  _handleOnRemoteUserLeaveRoom(String userId) {
    for (var i = 0; i < _userList.length; i++) {
      if (_userList[i].userId == userId) {
        _userList.removeAt(i);
      }
    }
    _screenUserList = MeetingTool.getScreenList(_userList);
    this.setState(() {});
    _meetModel.setList(_userList);
    _updateMixStream();
  }

  _handleOnUserAudioAvailable(String userId, bool available) {
    for (var i = 0; i < _userList.length; i++) {
      if (_userList[i].userId == userId) {
        _userList[i].isOpenMic = available;
      }
    }
  }

  _handleOnUserVideoAvailable(String userId, bool available) {
    if (available) {
      for (var i = 0; i < _userList.length; i++) {
        if (_userList[i].userId == userId && _userList[i].type == 'video') {
          _userList[i].isOpenCamera = true;
        }
      }
    } else {
      for (var i = 0; i < _userList.length; i++) {
        if (_userList[i].userId == userId && _userList[i].type == 'video') {
          _trtcCloud.stopRemoteView(userId, TRTCVideoStreamType.big);
          _userList[i].isOpenCamera = false;
        }
      }
    }

    _screenUserList = MeetingTool.getScreenList(_userList);
    this.setState(() {});
    _meetModel.setList(_userList);
  }

  _handleOnUserSubStreamAvailable(String userId, bool available) {
    if (available) {
      UserModel user = UserModel(userId: userId);
      user.type = 'subStream';
      user.isOpenCamera = true;
      user.size = WidgetSize(width: 0, height: 0);
      _userList.add(user);
    } else {
      for (var i = 0; i < _userList.length; i++) {
        if (_userList[i].userId == userId && _userList[i].type == 'subStream') {
          _trtcCloud.stopRemoteView(userId, TRTCVideoStreamType.sub);
          _userList.removeAt(i);
        }
      }
    }
    _screenUserList = MeetingTool.getScreenList(_userList);
    _meetModel.setList(_userList);
    this.setState(() {});
  }

  Future<bool?> _showErrorDialog(errorMsg) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Tips"),
          content: Text(errorMsg),
          actions: <Widget>[
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                Navigator.push( context, MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ));
              },
            ),
          ],
        );
      },
    );
  }

  _startMixStream() async {
    if (!widget.isHost) return;

    List<TRTCVideoLayout> videoLayoutList = [];

    TRTCVideoLayout videoLayout = TRTCVideoLayout();
    videoLayout.zOrder = 1;
    videoLayout.fixedVideoStreamType = TRTCVideoStreamType.big;
    videoLayout.rect = TRTCRect(left: 0, top: 0, right: 720, bottom: 1280);
    videoLayout.fixedVideoUser = TRTCUser( userId: _meetModel.getUserInfo().userId, intRoomId: _meetModel.getMeetId()!);
    videoLayoutList.add(videoLayout);

    _userList.where((u) => u.userId != _meetModel.getUserInfo().userId).forEach((u) {
      // print("userId: ${u.userId}");
      TRTCVideoLayout itemLayout = TRTCVideoLayout();
      itemLayout.zOrder = 1;
      itemLayout.fixedVideoUser = TRTCUser(userId: u.userId, intRoomId: _meetModel.getMeetId()!);
      itemLayout.rect = TRTCRect(left: 720, top: 0, right: 1440, bottom: 1280);
      itemLayout.fixedVideoStreamType = TRTCVideoStreamType.big;
      videoLayoutList.add(itemLayout);
    });

    // Specify the CDN address for publishing.
    TRTCPublishTarget trtcPublishTarget = TRTCPublishTarget();
    trtcPublishTarget.mode = videoLayoutList.length > 1
        ? TRTCPublishMode.mixStreamToCdn    // If there are multiple people, mix
        : TRTCPublishMode.bigStreamToCdn;   // If there is only one person, publish the main stream
    trtcPublishTarget.cdnUrlList = [
      TRTCPublishCdnUrl(
        rtmpUrl: "rtmp://${Config.pushDomain}/live/${_mixStreamId}", // Your push address
        isInternalLine: true,
      )
    ];

    // set cdn encoding parameters
    TRTCStreamEncoderParam trtcStreamEncoderParam = TRTCStreamEncoderParam();
    trtcStreamEncoderParam.videoEncodedWidth = videoLayoutList.length > 1 ? 1440 : 720;
    trtcStreamEncoderParam.videoEncodedHeight = 1280;
    trtcStreamEncoderParam.videoEncodedKbps = 2400;
    trtcStreamEncoderParam.videoEncodedGOP = 3;
    trtcStreamEncoderParam.videoEncodedFPS = 15;
    trtcStreamEncoderParam.audioEncodedSampleRate = 48000;
    trtcStreamEncoderParam.audioEncodedChannelNum = 1;
    trtcStreamEncoderParam.audioEncodedKbps = 50;

    TRTCStreamMixingConfig trtcStreamMixingConfig = TRTCStreamMixingConfig(videoLayoutList: videoLayoutList);

    // Start cloud mixing
    _trtcCloud.startPublishMediaStream( trtcPublishTarget, trtcStreamEncoderParam, trtcStreamMixingConfig);
  }

  _updateMixStream() async {
    if (!widget.isHost) return;
    if (_mixStreamTaskId == null) return;

    List<TRTCVideoLayout> videoLayoutList = [];

    TRTCVideoLayout videoLayout = TRTCVideoLayout();
    videoLayout.zOrder = 1;
    videoLayout.fixedVideoStreamType = TRTCVideoStreamType.big;
    videoLayout.rect = TRTCRect(left: 0, top: 0, right: 720, bottom: 1280);
    videoLayout.fixedVideoUser = TRTCUser( userId: _meetModel.getUserInfo().userId, intRoomId: _meetModel.getMeetId()!);
    videoLayoutList.add(videoLayout);

    _userList.where((u) => u.userId != _meetModel.getUserInfo().userId).forEach((u) {
      print("userId: ${u.userId}");
      TRTCVideoLayout itemLayout = TRTCVideoLayout();
      itemLayout.zOrder = 1;
      itemLayout.fixedVideoUser = TRTCUser(userId: u.userId, intRoomId: _meetModel.getMeetId()!);
      itemLayout.rect = TRTCRect(left: 720, top: 0, right: 1440, bottom: 1280);
      itemLayout.fixedVideoStreamType = TRTCVideoStreamType.big;
      videoLayoutList.add(itemLayout);
    });

    
    // Specify the CDN address for publishing.
    TRTCPublishTarget trtcPublishTarget = TRTCPublishTarget();
    trtcPublishTarget.mode = videoLayoutList.length > 1
        ? TRTCPublishMode.mixStreamToCdn    // If there are multiple people, mix
        : TRTCPublishMode.bigStreamToCdn;   // If there is only one person, publish the main stream
    trtcPublishTarget.cdnUrlList = [
      TRTCPublishCdnUrl(
        rtmpUrl: "rtmp://${Config.pushDomain}/live/${_mixStreamId}", // Your push address
        isInternalLine: true,
      )
    ];

    // set cdn encoding parameters
    TRTCStreamEncoderParam trtcStreamEncoderParam = TRTCStreamEncoderParam();
    trtcStreamEncoderParam.videoEncodedWidth = videoLayoutList.length > 1 ? 1440 : 720;
    trtcStreamEncoderParam.videoEncodedHeight = 1280;
    trtcStreamEncoderParam.videoEncodedKbps = 2400;
    trtcStreamEncoderParam.videoEncodedGOP = 3;
    trtcStreamEncoderParam.videoEncodedFPS = 15;
    trtcStreamEncoderParam.audioEncodedSampleRate = 48000;
    trtcStreamEncoderParam.audioEncodedChannelNum = 1;
    trtcStreamEncoderParam.audioEncodedKbps = 50;

    TRTCStreamMixingConfig trtcStreamMixingConfig = TRTCStreamMixingConfig(videoLayoutList: videoLayoutList);

    // update cloud mixing
    _trtcCloud.updatePublishMediaStream(_mixStreamTaskId!, trtcPublishTarget, trtcStreamEncoderParam, trtcStreamMixingConfig);
  }

  _stopMixStream() async {
    if (!widget.isHost) return;
    if (_mixStreamTaskId == null) return;
    // stop cloud mixing
    _trtcCloud.stopPublishMediaStream(_mixStreamTaskId!);
  }

  Widget _renderView(UserModel item, valueKey, width, height) {
    if (item.isOpenCamera) {
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: TRTCCloudVideoView(
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              onViewCreated: (viewId) async {
                if (item.userId == _meetModel.getUserInfo().userId) {
                  // open self camera
                  _trtcCloud.startLocalPreview(_meetModel.getUserInfo().isFrontCamera, viewId);
                  setState(() {_meetModel.getUserInfo().localViewId = viewId; });
                } else {
                  _trtcCloud.startRemoteView(
                      item.userId,
                      item.type == 'video' ? TRTCVideoStreamType.big : TRTCVideoStreamType.sub, viewId);
                }
                item.localViewId = viewId;
              }));
    } else {
      return Container(
        alignment: Alignment.center,
        child: ClipOval(child: Image.asset('images/avatar3_100.20191230.png', scale: 3.5)),
      );
    }
  }

  /// The user name and sound are displayed on the video layer
  Widget _videoVoice(UserModel item) {
    return Positioned(
      child: new Container(child: Row(children: <Widget>[
        Text(
            item.userId == _meetModel.getUserInfo().userId ? item.userId + "(me)" : item.userId,
            style: TextStyle(color: Colors.white)),
        Container(
            margin: EdgeInsets.only(left: 10),
            child: Icon(Icons.signal_cellular_alt, color: Colors.white, size: 20)),
      ])),
      left: 24.0,
      bottom: 80.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          PageView.builder(
              physics: new ClampingScrollPhysics(),
              itemCount: _screenUserList.length,
              itemBuilder: (BuildContext context, index) {
                List<UserModel> item = _screenUserList[index];
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Color.fromRGBO(19, 41, 75, 1),
                  child: Wrap(
                    children: List.generate(item.length,(index) => LayoutBuilder(
                        key: ValueKey(item[index].userId + item[index].type + item[index].size.width.toString()),
                        builder:(BuildContext context, BoxConstraints constraints) {

                          Size size = MeetingTool.getViewSize( MediaQuery.of(context).size,_userList.length,index,item.length);
                          double width = size.width;
                          double height = size.height;

                          ValueKey valueKey = ValueKey(item[index].userId + item[index].type + "0");
                          if (item[index].size.width > 0) {
                            width = double.parse(item[index].size.width.toString());
                            height = double.parse(item[index].size.height.toString());
                          }

                          return Container(key: valueKey,height: height,width: width, child: Stack(
                              key: valueKey, children: <Widget>[
                                _renderView( item[index], valueKey, width, height), _videoVoice(item[index])
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
