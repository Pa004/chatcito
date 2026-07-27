import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/usuario.dart';
import 'auth_provider.dart';

final usuariosProvider = StreamProvider<List<Usuario>>((ref) {
  final service = ref.read(firebaseServiceProvider);
  final currentUid = ref.watch(currentUserProvider)?.uid;
  return service.obtenerUsuarios().map((usuarios) {
    return usuarios.where((u) => u.uid != currentUid).toList();
  });
});
