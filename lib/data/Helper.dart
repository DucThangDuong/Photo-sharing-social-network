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
  static String formatTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks tuần';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months tháng';
    } else {
      int years = (difference.inDays / 365).floor();
      return '$years năm';
    }
  }
}