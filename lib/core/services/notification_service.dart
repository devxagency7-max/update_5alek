import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:motareb/core/models/property_model.dart';
import 'package:motareb/features/home/screens/home_screen.dart';
import 'package:motareb/features/property_details/screens/property_details_screen.dart';

/// Topic that every user app instance subscribes to so the admin can
/// broadcast a single push notification to all users.
const String kAllUsersTopic = 'all_users';

/// Handles FCM setup for the user app: permissions, topic subscription,
/// and routing the user to the right screen when a notification is tapped.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.subscribeToTopic(kAllUsersTopic);

    // Notification tapped while the app was in background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // App was opened from a terminated state via a notification tap.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }

    // Foreground messages: show a lightweight in-app banner.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final context = _navigatorKey?.currentState?.overlay?.context;
    if (context == null) return;

    final notification = message.notification;
    if (notification == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          notification.title ?? notification.body ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: 'فتح',
          onPressed: () => _handleMessageTap(message),
        ),
      ),
    );
  }

  Future<void> _handleMessageTap(RemoteMessage message) async {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    final route = message.data['route'];
    switch (route) {
      case 'property':
        final propertyId = message.data['propertyId'];
        if (propertyId == null || propertyId.isEmpty) return;
        await _openProperty(navigator, propertyId);
        break;
      case 'home':
      default:
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
    }
  }

  Future<void> _openProperty(NavigatorState navigator, String propertyId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .get();
      if (!doc.exists) return;

      final property = Property.fromMap(doc.data()!, doc.id);
      navigator.push(
        MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)),
      );
    } catch (_) {
      // Ignore navigation errors triggered by malformed notification data.
    }
  }
}
