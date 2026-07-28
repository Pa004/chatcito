import 'package:flutter/foundation.dart';

class InAppNotificationData {
  final String title;
  final String body;
  final String chatId;
  final String otroUid;
  final String otroNombre;

  const InAppNotificationData({
    required this.title,
    required this.body,
    required this.chatId,
    required this.otroUid,
    required this.otroNombre,
  });
}

final ValueNotifier<InAppNotificationData?> inAppNotificationNotifier =
    ValueNotifier(null);
