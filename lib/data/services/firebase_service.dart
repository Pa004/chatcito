import 'package:firebase_database/firebase_database.dart';
import '../../domain/models/mensaje.dart';
import '../../domain/models/usuario.dart';
import '../../domain/models/chat.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  DatabaseReference _mensajesRef(String chatId) =>
      _db.child('chats/$chatId/mensajes');

  DatabaseReference _chatRef(String chatId) =>
      _db.child('chats/$chatId');

  // --- Usuarios ---
  Future<void> guardarUsuario(String uid, String email, String nombre) async {
    await _db.child('users/$uid').set({
      'email': email,
      'nombre': nombre,
    });
  }

  Future<void> actualizarFcmToken(String uid, String token) async {
    await _db.child('users/$uid').update({'fcmToken': token});
  }

  Future<String?> obtenerFcmToken(String uid) async {
    final snap = await _db.child('users/$uid/fcmToken').get();
    return snap.value as String?;
  }

  Future<String?> obtenerNombreUsuario(String uid) async {
    final snap = await _db.child('users/$uid/nombre').get();
    return snap.value as String?;
  }

  Stream<List<Usuario>> obtenerUsuarios() {
    return _db.child('users').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        return Usuario.fromJson(
          e.value as Map<dynamic, dynamic>,
          uid: e.key as String,
        );
      }).toList();
    });
  }

  // --- Chats ---
  String generarChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<String> obtenerOCrearChat(String uid1, String uid2) async {
    final chatId = generarChatId(uid1, uid2);
    final snap = await _db.child('chats/$chatId').get();
    if (!snap.exists) {
      await _db.child('chats/$chatId/participantes').update({
        uid1: true,
        uid2: true,
      });
    }
    return chatId;
  }

  Stream<List<Chat>> obtenerChatsDeUsuario(String uid) {
    return _db.child('chats').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final chats = <Chat>[];
      for (final entry in data.entries) {
        final chatData = entry.value as Map<dynamic, dynamic>;
        final participantes = chatData['participantes'] as Map<dynamic, dynamic>? ?? {};
        if (participantes.containsKey(uid)) {
          chats.add(Chat.fromJson(chatData, id: entry.key as String));
        }
      }
      chats.sort((a, b) =>
          (b.ultimoTimestamp ?? 0).compareTo(a.ultimoTimestamp ?? 0));
      return chats;
    });
  }

  // --- Mensajes ---
  Future<void> enviarMensaje(String chatId, Mensaje mensaje) async {
    final msgRef = _mensajesRef(chatId).push();
    await msgRef.set(mensaje.toJson());
    await _chatRef(chatId).update({
      'ultimoMensaje': mensaje.texto,
      'ultimoTimestamp': mensaje.timestamp,
    });
  }

  Stream<List<Mensaje>> recibirMensajes(String chatId) {
    return _mensajesRef(chatId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final mensajes = data.entries
          .map((e) => Mensaje.fromJson(
                e.value as Map<dynamic, dynamic>,
                id: e.key as String,
              ))
          .toList();
      mensajes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return mensajes;
    });
  }

  Future<void> editarMensaje(String chatId, String id, String nuevoTexto) async {
    await _mensajesRef(chatId).child(id).update({
      'texto': nuevoTexto,
      'editado': true,
    });
  }

  Future<void> eliminarMensaje(String chatId, String id) async {
    await _mensajesRef(chatId).child(id).remove();
  }
}
