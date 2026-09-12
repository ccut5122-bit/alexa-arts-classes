import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallTracker {
  static const _countedKey = 'install_counted_v1';

  static const _statsRef =
      'analytics/installs';

  static Future<void> trackOnLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_countedKey) ?? false) return;
      await prefs.setBool(_countedKey, true);

      await FirebaseFirestore.instance
          .collection('analytics')
          .doc('installs')
          .set({
        'count': FieldValue.increment(1),
        'lastInstall': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}