import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/usuarios_provider.dart';
import '../../domain/models/usuario.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_background.dart';
import 'chat_view.dart';
import 'login_view.dart';

class UsuariosView extends ConsumerStatefulWidget {
  const UsuariosView({super.key});

  @override
  ConsumerState<UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends ConsumerState<UsuariosView> {
  void _seleccionarUsuario(Usuario otroUsuario) {
    final miUid = ref.read(currentUserProvider)?.uid;
    if (miUid == null) return;

    final service = ref.read(firebaseServiceProvider);
    service.obtenerOCrearChat(miUid, otroUsuario.uid).then((chatId) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatView(chatId: chatId, otherUser: otroUsuario),
        ),
      );
    });
  }

  void _cerrarSesion() async {
    await ref.read(authServiceProvider).cerrarSesion();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuariosProvider);
    final themeMode = ref.watch(themeModeProvider);
    final connectionAsync = ref.watch(connectionStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.forum_rounded, size: 18, color: Colors.white),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: connectionAsync.when(
                    data: (connected) => Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: connected ? AppTheme.whatsappGreen : Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Text('Chatcito', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: ChatBackground(
        child: usuariosAsync.when(
          data: (usuarios) => usuarios.isEmpty
              ? _buildEmptyState(isDark)
              : _buildUserList(usuarios, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorState(e, isDark),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 72,
              color: isDark ? Colors.grey.shade700 : AppTheme.lightSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'No hay usuarios registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invita a alguien a crear una cuenta',
              style: TextStyle(
                fontSize: 14,
                              color: isDark ? Colors.grey.shade600 : AppTheme.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<Usuario> usuarios, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Icon(
                Icons.people_rounded,
                size: 16,
                color: isDark ? Colors.grey.shade500 : AppTheme.lightIconColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Contactos disponibles',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.incomingDark
                      : AppTheme.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.whatsappDarkTeal.withValues(alpha: 0.3)
                        : AppTheme.whatsappTeal.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${usuarios.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: usuarios.length,
            itemBuilder: (_, i) {
              final usuario = usuarios[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.incomingDark.withValues(alpha: 0.85)
                      : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _seleccionarUsuario(usuario),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.whatsappDarkTeal.withValues(alpha: 0.5)
                                      : AppTheme.whatsappTeal.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: isDark
                                    ? AppTheme.whatsappDarkTeal.withValues(alpha: 0.3)
                                    : AppTheme.whatsappTeal.withValues(alpha: 0.2),
                                child: Text(
                                  usuario.nombre.isNotEmpty
                                      ? usuario.nombre[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppTheme.whatsappDarkTeal
                                        : AppTheme.whatsappTeal,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    usuario.nombre,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    usuario.email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey.shade600 : AppTheme.lightTextTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object e, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: isDark ? Colors.grey.shade600 : AppTheme.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar usuarios',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.grey.shade300 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
