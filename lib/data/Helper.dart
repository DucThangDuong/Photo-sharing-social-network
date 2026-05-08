import 'package:permission_handler/permission_handler.dart';
class AppHelper {
  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
    return status.isGranted;
  }
  static String formatImageURL(String url) {
    return 'http://10.0.2.2:5090'+url;
  }
}