import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<String?> getUserAccessToken(User user) async {
  try {
    return await user.getIdToken(true);
  } catch (e) {
    debugPrint('Error fetching token: $e');
    return null;
  }
}
