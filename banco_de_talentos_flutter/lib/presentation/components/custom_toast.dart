import 'package:flutter/material.dart';
import 'dart:ui';

enum ToastType { success, error, warning, info }

class CustomToast {
  static OverlayEntry? _currentOverlayEntry;

  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    dismiss();

    final overlayState = Overlay.of(context);

    _currentOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: ToastWidget(
            message: message,
            type: type,
            duration: duration,
            onDismiss: () {
              dismiss();
            },
          ),
        ),
      ),
    );

    overlayState.insert(_currentOverlayEntry!);
  }

  static void dismiss() {
    if (_currentOverlayEntry != null) {
      try {
        _currentOverlayEntry!.remove();
      } catch (_) {}
      _currentOverlayEntry = null;
    }
  }
}

class ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const ToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _slideController.forward().then((_) {
      if (mounted) {
        _progressController.forward().then((_) {
          if (mounted) {
            _dismiss();
          }
        });
      }
    });
  }

  void _dismiss() {
    if (_slideController.isAnimating) return;
    _slideController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color tintColor;
    final IconData icon;
    final String title;

    switch (widget.type) {
      case ToastType.success:
        tintColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        title = 'Sucesso';
        break;
      case ToastType.error:
        tintColor = const Color(0xFFE53E3E);
        icon = Icons.error_rounded;
        title = 'Erro';
        break;
      case ToastType.warning:
        tintColor = const Color(0xFFF59E0B);
        icon = Icons.warning_rounded;
        title = 'Aviso';
        break;
      case ToastType.info:
        tintColor = const Color(0xFF3B82F6);
        icon = Icons.info_rounded;
        title = 'Informação';
        break;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: tintColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: tintColor, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: tintColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.message,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white38, size: 18),
                          onPressed: _dismiss,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: 1.0 - _progressController.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(tintColor),
                        minHeight: 3.5,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
