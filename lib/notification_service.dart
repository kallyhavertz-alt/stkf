import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'db_helper.dart';
import 'truecaller_overlay_banner.dart';

// Top-level background handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('Handling a background message: ${message.messageId}');

    String body = message.data['rawSmsText'] ?? message.notification?.body ?? '';
    if (body.isNotEmpty) {
      try {
        await MessageDatabase.instance.insertMessage(
          body,
          DateTime.now().toIso8601String(),
        );
      } catch (e) {
        debugPrint('Error saving background message to database: $e');
      }
    }
  } catch (e) {
    debugPrint('Error in background message handler: $e');
  }
}

class FCMNotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // 1. Initialize Firebase App
      await Firebase.initializeApp();

      // 2. Set Background Messaging Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Request User Permissions
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('User notification permission status: ${settings.authorizationStatus}');

      // 4. Initialize Flutter Local Notifications
      const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Local Notification Tapped: ${details.payload}');
        },
      );

      // Create high importance Android channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'mpesa_channel',
        'M-PESA Notifications',
        description: 'Channel for M-PESA transaction alerts',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 5. Subscribe to FCM Topic
      try {
        await messaging.subscribeToTopic('mpesa_notifications');
        debugPrint('Subscribed to FCM topic: mpesa_notifications');
      } catch (e) {
        debugPrint('FCM topic subscription notice: $e');
      }

      // Fetch Device FCM Token
      try {
        String? token = await messaging.getToken();
        debugPrint('====================================================');
        debugPrint('FCM DEVICE TOKEN: $token');
        debugPrint('====================================================');
      } catch (e) {
        debugPrint('Error getting FCM token: $e');
      }

      // 6. Listen for Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint('Got a message whilst in the foreground!');

        final data = message.data;
        debugPrint('====================================================');
        debugPrint('[FCM INCOMING DATA MAP]: $data');
        debugPrint('====================================================');

        String title = message.notification?.title ?? data['pushTitle'] ?? 'MPESA';
        String rawSmsText = data['rawSmsText'] ?? message.notification?.body ?? '';

        String transactionCode = data['transactionCode'] ?? '';
        double amount = double.tryParse(data['amount'] ?? '0.00') ?? 0.00;
        String transactionType = data['transactionType'] ?? 'PAYBILL';

        // 1. Try FCM data key first
        String recipientName = data['recipientOrMerchant'] ?? '';

        // 2. Extract real name directly out of rawSmsText string if key is blank
        if (recipientName.trim().isEmpty && rawSmsText.isNotEmpty) {
          recipientName = _extractRecipientFromSms(rawSmsText, transactionType);
        }

        // 3. Contextual safety fallback if string parsing is also blank
        if (recipientName.trim().isEmpty) {
          switch (transactionType) {
            case 'BUY_GOODS':
              recipientName = 'TILL MERCHANT';
              break;
            case 'POCHI':
              recipientName = 'POCHI MERCHANT';
              break;
            case 'PAYBILL':
            default:
              recipientName = 'PAYBILL MERCHANT';
              break;
          }
        }

        // Save raw formatted M-PESA text directly to local inbox database
        if (rawSmsText.isNotEmpty) {
          try {
            await MessageDatabase.instance.insertMessage(
              rawSmsText,
              DateTime.now().toIso8601String(),
            );
          } catch (e) {
            debugPrint('Error saving foreground message to database: $e');
          }
        }

        // Trigger System Tray Notification
        _showLocalNotification(
          title,
          "$transactionCode confirmed. Ksh${amount.toStringAsFixed(2)} sent to $recipientName.",
        );

        // Trigger Truecaller Overlay Banner
        _triggerTruecallerBanner(
          transactionCode: transactionCode,
          amount: amount,
          recipientName: recipientName,
          rawSmsText: rawSmsText,
        );
      });
    } catch (e, stackTrace) {
      debugPrint('FCMNotificationService initialization error: $e\n$stackTrace');
    }
  }

  // Display System Tray Notification
  static Future<void> _showLocalNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'mpesa_channel',
        'M-PESA Notifications',
        channelDescription: 'Channel for M-PESA transaction alerts',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: platformDetails,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // Static helper method to parse real names directly out of formatted M-PESA SMS text
  static String _extractRecipientFromSms(String sms, String transactionType) {
    if (sms.isEmpty) return '';

    try {
      // 1. Paybill Pattern: "sent to [RECIPIENT] for account"
      if (sms.contains(' sent to ') && sms.contains(' for account ')) {
        final match = RegExp(r'sent to (.+?) for account').firstMatch(sms);
        if (match != null && match.group(1)!.trim().isNotEmpty) {
          return match.group(1)!.trim();
        }
      }

      // 2. Buy Goods Pattern: "paid to [MERCHANT] on"
      if (sms.contains(' paid to ')) {
        final match = RegExp(r'paid to (.+?)(?: on|\.)').firstMatch(sms);
        if (match != null && match.group(1)!.trim().isNotEmpty) {
          return match.group(1)!.trim();
        }
      }

      // 3. Pochi Pattern: "sent to Pochi la Biashara [NAME] on"
      if (sms.contains('Pochi la Biashara')) {
        final match = RegExp(r'Pochi la Biashara (.+?)(?: on|\.)').firstMatch(sms);
        if (match != null && match.group(1)!.trim().isNotEmpty) {
          return match.group(1)!.trim();
        }
      }
    } catch (e) {
      debugPrint('Error parsing recipient from raw SMS text: $e');
    }

    return '';
  }

  // Launch Truecaller Overlay Dialog using top-level Navigator Context
  static void _triggerTruecallerBanner({
    required String transactionCode,
    required double amount,
    required String recipientName,
    required String rawSmsText,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('NavigatorContext is null. Cannot show Truecaller banner overlay.');
      return;
    }

    showTruecallerMpesaOverlay(
      context: context,
      transactionCode: transactionCode,
      amount: amount,
      recipientName: recipientName,
      rawSmsText: rawSmsText,
      onMarkAsRead: () {
        debugPrint('Marked message as read for transaction: $transactionCode');
      },
    );
  }
}