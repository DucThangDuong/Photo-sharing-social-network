import 'package:flutter/material.dart';
import '../ApiServices.dart';

class SnackBarError {
  static void show(BuildContext context,{String prefix = ''}) {
    final displayMessage = prefix.isNotEmpty ? '$prefix' : 'Lỗi không xác định';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
