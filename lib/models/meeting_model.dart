import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:trtc_demo/models/user_model.dart';

class MeetingModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  int? _meetId;
  bool _isTextureRendering = false;
  TRTCAudioQuality _quality = TRTCAudioQuality.defaultMode;

  late UserModel _userInfo;
  List<UserModel> _userList = [];

  void setList(list) {
    _userList = list;
    notifyListeners();
  }

  void setUserSettings(
      {required int meetId,
      required String userId,
      required bool enabledCamera,
      required bool enabledMicrophone,
      required bool enableTextureRendering,
      required bool isAnchor,
      TRTCAudioQuality quality = TRTCAudioQuality.defaultMode}) {
    _meetId = meetId;
    _userInfo = UserModel(userId: userId)..isAnchor = isAnchor;
    _userInfo.isOpenCamera = enabledCamera;
    _userInfo.isOpenMic = enabledMicrophone;
    _isTextureRendering = enableTextureRendering;
    _quality = quality;
  }

  int? getMeetId() {
    return _meetId;
  }

  TRTCAudioQuality getQuality() {
    return _quality;
  }

  bool getTextureRenderingEnable() {
    return _isTextureRendering;
  }

  UserModel getUserInfo() {
    return _userInfo;
  }

  List<UserModel> getList() {
    return _userList;
  }

  bool get isAnchor {
    return _userInfo.isAnchor;
  }

  void update(
      {int? meetId,
      String? userId,
      bool? enabledCamera,
      bool? enabledMicrophone,
      bool? enableTextureRendering,
      bool? isAnchor,
      TRTCAudioQuality? quality}) {
    if (meetId != null) _meetId = meetId;
    if (userId != null) _userInfo.userId = userId;
    if (enabledCamera != null) _userInfo.isOpenCamera = enabledCamera;
    if (enabledMicrophone != null) _userInfo.isOpenMic = enabledMicrophone;
    if (enableTextureRendering != null)
      _isTextureRendering = enableTextureRendering;
    if (isAnchor != null) _userInfo.isAnchor = isAnchor;
    if (quality != null) _quality = quality;
    notifyListeners();
  }

  void removeAll() {
    _userList.clear();
    notifyListeners();
  }
}
