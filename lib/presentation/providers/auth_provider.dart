import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/fcm_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());

final firebaseServiceProvider =
    Provider<FirebaseService>((ref) => FirebaseService());

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.read(authServiceProvider);
  return auth.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).asData?.value;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
