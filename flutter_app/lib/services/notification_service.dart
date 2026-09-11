import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  const androidDetails = AndroidNotificationDetails(
    'alexa_art_classes',
    'Alexa Arts Classes',
    channelDescription: 'Notifications for students',
    importance: Importance.high,
    priority: Priority.high,
  );
  await FlutterLocalNotificationsPlugin().show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    message.notification?.title ?? 'Alexa Arts Classes',
    message.notification?.body ?? '',
    const NotificationDetails(android: androidDetails),
  );
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static DateTime? _lastShotStart;
  static final Set<String> _seenIds = {};

  static Future<void> initialize() async {
    _messaging
        .setBackgroundMessageHandler(_firebaseMessagingBackgroundHandler);

    _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _localNotifications.initialize(initSettings);

    _messaging.getToken().then((token) {
      if (token != null) {
        _saveToken(token);
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message);
    });

    _lastShotStart = DateTime.now();
    _listenToFirestoreNotifications();
  }

  static void _listenToFirestoreNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get()
        .then((snap) {
      for (final doc in snap.docs) {
        _seenIds.add(doc.id);
      }
    }).catchError((_) {});

    FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
          for (final doc in snap.docs) {
            final id = doc.id;
            if (_seenIds.contains(id)) continue;
            _seenIds.add(id);
            final data = doc.data();
            final ts = (data['createdAt'] as Timestamp?)?.toDate();
            if (ts == null || (_lastShotStart != null && ts.isBefore(_lastShotStart!))) {
              continue;
            }
            _showFirestoreNotification(data);
          }
        }, onError: (_) {});
  }

  static Future<void> _showFirestoreNotification(Map<String, dynamic> data) async {
    const androidDetails = AndroidNotificationDetails(
      'alexa_art_classes',
      'Alexa Arts Classes',
      channelDescription: 'Notifications for students',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      data['title'] ?? 'Alexa Arts Classes',
      data['body'] ?? '',
      details,
    );
  }

  static Future<void> refreshToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (_) {}
  }

  static Future<void> _saveToken(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'fcmToken': token, 'lastActive': FieldValue.serverTimestamp()},
                SetOptions(merge: true));
      }
    } catch (_) {}
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'alexa_art_classes',
      'Alexa Arts Classes',
      channelDescription: 'Notifications for students',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    // Navigate based on message.data
  }
}