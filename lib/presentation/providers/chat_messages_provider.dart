import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mensaje.dart';
import 'auth_provider.dart';

final chatMessagesProvider =
    StreamProvider.family<List<Mensaje>, String>((ref, chatId) {
  final service = ref.read(firebaseServiceProvider);
  return service.recibirMensajes(chatId);
});
