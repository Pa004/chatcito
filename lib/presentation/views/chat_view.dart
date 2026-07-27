import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_messages_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/theme_provider.dart';
import '../../domain/models/mensaje.dart';
import '../../domain/models/usuario.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_background.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key, required this.chatId, required this.otherUser});

  final String chatId;
  final Usuario otherUser;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isNearBottom = true;
  String? _mensajeSeleccionadoId;
  String? _editandoId;
  final FocusNode _focusNode = FocusNode();
  List<Mensaje> _prevMensajes = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final nearBottom = (maxScroll - currentScroll) < 120;
    if (nearBottom != _isNearBottom) {
      setState(() => _isNearBottom = nearBottom);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _dateSeparator(int timestamp) {
    final msgDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(msgDate.year, msgDate.month, msgDate.day);

    final diff = today.difference(msgDay).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return '${msgDate.day.toString().padLeft(2, '0')}/${msgDate.month.toString().padLeft(2, '0')}/${msgDate.year}';
  }

  String _formatearHora(int timestamp) {
    final t = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _cancelEdit() {
    setState(() {
      _editandoId = null;
    });
    _controller.clear();
  }

  void _onSend(String text) async {
    if (text.trim().isEmpty) return;
    try {
      final service = ref.read(firebaseServiceProvider);
      final miUid = ref.read(currentUserProvider)?.uid ?? '';
      final miNombre = ref.read(currentUserProvider)?.displayName ?? '';

      final miNombreReal = miNombre.isNotEmpty
          ? miNombre
          : await service.obtenerNombreUsuario(miUid) ?? '';

      if (_editandoId != null) {
        await service.editarMensaje(widget.chatId, _editandoId!, text.trim());
        _cancelEdit();
      } else {
        final mensaje = Mensaje(
          texto: text.trim(),
          autor: miNombreReal,
          autorId: miUid,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        await service.enviarMensaje(widget.chatId, mensaje);
        _controller.clear();

        final token = await service.obtenerFcmToken(widget.otherUser.uid);
        if (token != null) {
          ref.read(fcmServiceProvider).enviarNotificacionPush(
                tokenDestino: token,
                titulo: miNombreReal,
                cuerpo: text.trim(),
                chatId: widget.chatId,
                otroUid: miUid,
                otroNombre: miNombreReal,
              );
        } else {
          debugPrint('No FCM token found for user ${widget.otherUser.uid}');
        }
      }
      HapticFeedback.lightImpact();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editandoId != null
              ? 'Error al editar mensaje'
              : 'Error al enviar mensaje'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onMessageLongPress(Mensaje m) {
    if (m.id == null) return;
    setState(() => _mensajeSeleccionadoId = m.id);
  }

  void _onEditSelected() {
    final mensajes = ref.read(chatMessagesProvider(widget.chatId)).asData?.value ?? [];
    final msj = mensajes.where((m) => m.id == _mensajeSeleccionadoId).firstOrNull;
    if (msj == null) return;
    setState(() {
      _editandoId = msj.id;
      _mensajeSeleccionadoId = null;
    });
    _controller.text = msj.texto;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: msj.texto.length),
    );
    _focusNode.requestFocus();
  }

  void _onDeleteSelected() {
    final mensajes = ref.read(chatMessagesProvider(widget.chatId)).asData?.value ?? [];
    final msj = mensajes.where((m) => m.id == _mensajeSeleccionadoId).firstOrNull;
    if (msj == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar mensaje'),
        content: const Text('Estas seguro de que deseas eliminar este mensaje?'),
        actions: [
          TextButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(ctx);
              setState(() => _mensajeSeleccionadoId = null);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () {
              FocusScope.of(context).unfocus();
              ref.read(firebaseServiceProvider).eliminarMensaje(widget.chatId, msj.id!);
              Navigator.pop(ctx);
              setState(() => _mensajeSeleccionadoId = null);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mensajesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final themeMode = ref.watch(themeModeProvider);
    final connectionAsync = ref.watch(connectionStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final miUid = ref.read(currentUserProvider)?.uid ?? '';

    final incomingColor = isDark ? AppTheme.incomingDark : AppTheme.incomingLight;
    final outgoingColor = isDark ? AppTheme.outgoingDark : AppTheme.outgoingLight;

    return Scaffold(
      appBar: _mensajeSeleccionadoId != null
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _mensajeSeleccionadoId = null),
              ),
              title: const Text('1 seleccionado'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: _onEditSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: _onDeleteSelected,
                ),
              ],
            )
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          widget.otherUser.nombre.isNotEmpty
                              ? widget.otherUser.nombre[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: connectionAsync.when(
                          data: (connected) => Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color:
                                  connected ? AppTheme.whatsappGreen : Colors.orange,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.otherUser.nombre,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16)),
                        connectionAsync.when(
                          data: (connected) => Text(
                            connected ? 'Conectado' : 'Sin conexion',
                            style: TextStyle(
                              fontSize: 11,
                              color: connected
                                  ? Colors.white70
                                  : Colors.orange.shade200,
                            ),
                          ),
                          loading: () => const Text('Conectando...',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white70)),
                          error: (_, _) => const Text('Sin conexion',
                              style: TextStyle(fontSize: 11, color: Colors.orange)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                  onPressed: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
              ],
            ),
      body: ChatBackground(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: mensajesAsync.when(
                      data: (mensajes) {
                        if (mensajes.isEmpty) {
                          _prevMensajes = mensajes;
                          return _buildEmptyState(isDark);
                        }
                        return _buildChatList(
                            mensajes, incomingColor, outgoingColor, isDark, miUid);
                      },
                      loading: () => _buildLoadingState(isDark),
                      error: (e, _) => _buildErrorState(e, isDark),
                    ),
                  ),
                ),
                _buildInput(isDark),
              ],
            ),
            if (!_isNearBottom)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 66,
                right: 16,
                child: GestureDetector(
                  onTap: _scrollToBottom,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: 20,
                        color: isDark ? Colors.grey.shade300 : AppTheme.lightTextPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_rounded,
              size: 72,
              color: isDark ? Colors.grey.shade700 : AppTheme.lightTextTertiary,
            ),
            const SizedBox(height: 20),
            Text(
              'No hay mensajes aun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribe el primero!',
              style: TextStyle(
                fontSize: 14,
              color: isDark ? Colors.grey.shade600 : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(
    List<Mensaje> mensajes,
    Color incomingColor,
    Color outgoingColor,
    bool isDark,
    String miUid,
  ) {
    if (mensajes.length > _prevMensajes.length && _isNearBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    _prevMensajes = mensajes;

    final items = <Widget>[];
    String? lastDate;

    for (final m in mensajes) {
      final dateStr = _dateSeparator(m.timestamp);
      if (dateStr != lastDate) {
        items.add(_DateSeparator(date: dateStr));
        lastDate = dateStr;
      }
      final esMio = m.autorId == miUid;
      final isSelected = _mensajeSeleccionadoId != null && _mensajeSeleccionadoId == m.id;
      items.add(_MessageBubble(
        mensaje: m,
        esMio: esMio,
        incomingColor: incomingColor,
        outgoingColor: outgoingColor,
        isDark: isDark,
        formatoHora: _formatearHora(m.timestamp),
        isSelected: isSelected,
        onLongPress: esMio ? () => _onMessageLongPress(m) : null,
        onTap: _mensajeSeleccionadoId != null
            ? () => setState(() => _mensajeSeleccionadoId = null)
            : null,
      ));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) => items[i],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, i) => _ShimmerBubble(isMine: i.isOdd, isDark: isDark),
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
              'Error de conexion',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.grey.shade300 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(bool isDark) {
    final isEditing = _editandoId != null;
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey.shade800 : AppTheme.lightDividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_rounded,
                      size: 16, color: AppTheme.whatsappTeal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Editando mensaje',
                      style: TextStyle(
                        fontSize: 13,
                      color: isDark ? Colors.grey.shade300 : AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelEdit,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                color: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: 8 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : AppTheme.lightDividerColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppTheme.telegramLightBlue
                              : AppTheme.telegramBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) => _onSend(value),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (_, val, _) {
                    final hasText = val.text.trim().isNotEmpty;
                    final lightEnabled = const Color(0xFF005A8C);
                    final lightDisabled = AppTheme.lightTextSecondary.withValues(alpha: 0.5);
                    return Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasText
                                ? (isDark
                                    ? AppTheme.telegramLightBlue
                                    : lightEnabled)
                                : (isDark
                                    ? Colors.grey.shade600.withValues(alpha: 0.5)
                                    : lightDisabled),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: hasText
                              ? (isDark
                                  ? AppTheme.telegramLightBlue
                                  : lightEnabled)
                              : (isDark ? Colors.grey.shade600 : AppTheme.lightDividerColor),
                          child: IconButton(
                            icon: Icon(
                              isEditing ? Icons.check_rounded : Icons.send_rounded,
                              size: 20,
                            ),
                            color: Colors.white,
                            onPressed: hasText ? () => _onSend(val.text) : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
  }
}

class _MessageBubble extends StatelessWidget {
  final Mensaje mensaje;
  final bool esMio;
  final Color incomingColor;
  final Color outgoingColor;
  final bool isDark;
  final String formatoHora;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const _MessageBubble({
    required this.mensaje,
    required this.esMio,
    required this.incomingColor,
    required this.outgoingColor,
    required this.isDark,
    required this.formatoHora,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esMio ? outgoingColor : incomingColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: esMio
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: esMio
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                border: isSelected
                    ? Border.all(color: AppTheme.whatsappTeal, width: 2)
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : esMio
                                ? AppTheme.lightTextSecondary.withValues(alpha: 0.4)
                                : Colors.grey.shade400,
                        width: 1,
                      ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment:
                    esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    mensaje.texto,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mensaje.editado ? 'editado \u00b7 $formatoHora' : formatoHora,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Color(0xFF1A3B2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.incomingDark.withValues(alpha: 0.8)
                : AppTheme.lightSurfaceVariant.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerBubble extends StatefulWidget {
  final bool isMine;
  final bool isDark;
  const _ShimmerBubble({required this.isMine, required this.isDark});

  @override
  State<_ShimmerBubble> createState() => _ShimmerBubbleState();
}

class _ShimmerBubbleState extends State<_ShimmerBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              final baseColor = widget.isDark
                  ? Colors.grey.shade800
                  : AppTheme.lightSurfaceVariant;
              final lightColor = widget.isDark
                  ? Colors.grey.shade700
                  : AppTheme.lightDividerColor;
              return Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [baseColor, lightColor, baseColor],
                    stops: [
                      _anim.value - 0.2,
                      _anim.value,
                      _anim.value + 0.2,
                    ].map((s) => s.clamp(0.0, 1.0)).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


