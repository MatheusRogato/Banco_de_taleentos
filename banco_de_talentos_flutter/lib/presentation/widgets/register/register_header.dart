import 'package:flutter/material.dart';
import '../../components/staggered_entry_animation.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StaggeredWidget(
          index: 0,
          child: const Text(
            'Criar Conta',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        StaggeredWidget(
          index: 1,
          child: const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Junte-se a nós e impulsione sua carreira.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
