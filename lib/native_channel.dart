import 'dart:async';
import 'package:flutter/services.dart';

class OpenNativePlugin {
  static const MethodChannel _channel =
      MethodChannel('flutter.demo.dev/native');

  Future<void> openNative(String arg_msg) async {
    return _channel.invokeMethod<void>("openNative", arg_msg);
  }

  Future<String?> getDataFromNative(Map<String?, Object?> arg_params) async {
    return await _channel.invokeMethod<String>("getDataFromNative", arg_params);
  }
}
