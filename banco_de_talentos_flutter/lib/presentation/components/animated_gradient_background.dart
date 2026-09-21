import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      const Color(0xFF088395),
      const Color(0xFF05BFDB),
      Theme.of(context).colorScheme.primary,
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
          ),
          // Animated Orbs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + 50 * math.sin(_controller.value * 2 * math.pi),
                    left: -100 + 50 * math.cos(_controller.value * 2 * math.pi),
                    child: _buildOrb(colors[1], 300),
                  ),
                  Positioned(
                    bottom:
                        -150 + 80 * math.cos(_controller.value * 2 * math.pi),
                    right: -50 + 30 * math.sin(_controller.value * 2 * math.pi),
                    child: _buildOrb(colors[2], 400),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.4 +
                        100 * math.sin(_controller.value * 4 * math.pi),
                    left: MediaQuery.of(context).size.width * 0.5 +
                        100 * math.cos(_controller.value * 3 * math.pi),
                    child: _buildOrb(const Color(0x66FFFFFF), 200),
                  ),
                ],
              );
            },
          ),
          // Blur Layer (Glass effect over the orbs)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: size / 2,
            spreadRadius: size / 4,
          )
        ],
      ),
    );
  }
}
