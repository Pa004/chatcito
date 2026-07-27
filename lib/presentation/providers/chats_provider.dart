import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chat.dart';
import 'auth_provider.dart';

final chatsProvider = StreamProvider<List<Chat>>((ref) {
  final service = ref.read(firebaseServiceProvider);
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  return service.obtenerChatsDeUsuario(uid);
});
