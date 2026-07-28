import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../../domain/models/usuario.dart';
import '../views/chat_view.dart';

class InAppNotificationBanner extends StatefulWidget {
  const InAppNotificationBanner({super.key});

  @override
  State<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;
  InAppNotificationData? _currentData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    inAppNotificationNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    final data = inAppNotificationNotifier.value;
    if (data != null) {
      setState(() => _currentData = data);
      _controller.forward();
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 4), () {
        inAppNotificationNotifier.value = null;
      });
    } else if (_currentData != null) {
      _controller.reverse().then((_) {
        if (mounted) setState(() => _currentData = null);
      });
    }
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    inAppNotificationNotifier.value = null;
  }

  void _onTap() {
    final data = _currentData;
    if (data == null) return;
    _dismiss();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ChatView(
          chatId: data.chatId,
          otherUser: Usuario(
            uid: data.otroUid,
            nombre: data.otroNombre,
            email: '',
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    inAppNotificationNotifier.removeListener(_onDataChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData;
    if (data == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: _buildBanner(data, isDark),
    );
  }

  Widget _buildBanner(InAppNotificationData data, bool isDark) {
    return GestureDetector(
      onTap: _onTap,
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -200) {
          _dismiss();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2C33) : Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.whatsappTeal.withValues(alpha: 0.2),
              child: Text(
                data.title.isNotEmpty ? data.title[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.whatsappTeal,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.body,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? Colors.grey.shade300 : AppTheme.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color:
                    isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
              ),
              onPressed: _dismiss,
            ),
          ],
        ),
      ),
    );
  }
}

