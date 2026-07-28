import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'fcm_config.dart';

class FcmService {
  static final _credentials = ServiceAccountCredentials.fromJson({
    'type': 'service_account',
    'project_id': FcmConfig.projectId,
    'private_key_id': FcmConfig.privateKeyId,
    'private_key': FcmConfig.privateKey,
    'client_email': FcmConfig.clientEmail,
    'client_id': FcmConfig.clientId,
    'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
    'token_uri': 'https://oauth2.googleapis.com/token',
    'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs',
    'client_x509_cert_url':
        'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40chatcito-9515e.iam.gserviceaccount.com',
    'universe_domain': 'googleapis.com',
  });

  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  Future<void> enviarNotificacionPush({
    required String tokenDestino,
    required String titulo,
    required String cuerpo,
    required String chatId,
    required String otroUid,
    required String otroNombre,
  }) async {
    try {
      final authClient = await clientViaServiceAccount(_credentials, _scopes);
      final accessToken = authClient.credentials.accessToken.data;
      authClient.close();

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/${FcmConfig.projectId}/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': tokenDestino,
            'notification': {
              'title': titulo,
              'body': cuerpo,
            },
            'data': {
              'chatId': chatId,
              'otroUid': otroUid,
              'otroNombre': otroNombre,
            },
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'high_importance_channel',
                'sound': 'default',
              },
            },
          },
        }),
      );
      debugPrint('FCM response: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('FCM error: $e');
    }
  }
}
