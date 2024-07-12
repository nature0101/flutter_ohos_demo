import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class OpenNativeApi{

  void openNative(String msg);

  @async
  String getDataFromNative(Map<String,Object> params);
}