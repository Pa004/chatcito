import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'presentation/views/splash_view.dart';
import 'presentation/views/chat_view.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/widgets/in_app_notification.dart';
import 'domain/models/usuario.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode') ?? 'system';

  runApp(
    ProviderScope(
      overrides: [
        initialThemeModeProvider.overrideWithValue(savedTheme),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final FlutterLocalNotificationsPlugin _localNotifications;

  @override
  void initState() {
    super.initState();
    _initLocalNotifications();
    _setupFcmListeners();
    _saveFcmTokenOnInit();
  }

  void _initLocalNotifications() {
    _localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'high_importance_channel',
        'Notificaciones',
        description: 'Notificaciones de chats',
        importance: Importance.high,
        playSound: true,
      ),
    );
    androidPlugin?.requestNotificationsPermission();
  }

  void _saveFcmTokenOnInit() {
    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint('FCM registration token: $token');
      if (token == null) return;
      FirebaseAuth.instance.authStateChanges().first.then((user) {
        if (user != null) {
          ref.read(authServiceProvider).actualizarFcmToken(token);
        }
      });
    });
  }

  void _setupFcmListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      final senderUid = message.data['otroUid'] as String?;
      if (senderUid == FirebaseAuth.instance.currentUser?.uid) return;

      inAppNotificationNotifier.value = InAppNotificationData(
        title: notification.title ?? '',
        body: notification.body ?? '',
        chatId: message.data['chatId'] as String? ?? '',
        otroUid: message.data['otroUid'] as String? ?? '',
        otroNombre: message.data['otroNombre'] as String? ?? '',
      );

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Notificaciones',
            channelDescription: 'Notificaciones de chats',
            importance: Importance.high,
            priority: Priority.high,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateToChat(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToChat(message.data);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    ref.listen(authStateProvider, (_, authState) {
      final user = authState.asData?.value;
      if (user != null) {
        FirebaseMessaging.instance.getToken().then((token) {
          ref.read(authServiceProvider).actualizarFcmToken(token);
        });
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SplashView(),
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            const InAppNotificationBanner(),
          ],
        );
      },
    );
  }
}

void _navigateToChat(Map<String, dynamic> data) {
  final chatId = data['chatId'] as String?;
  final otroUid = data['otroUid'] as String?;
  final otroNombre = data['otroNombre'] as String?;
  if (chatId == null || otroUid == null || otroNombre == null) return;

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => ChatView(
        chatId: chatId,
        otherUser: Usuario(uid: otroUid, nombre: otroNombre, email: ''),
      ),
    ),
  );
}
