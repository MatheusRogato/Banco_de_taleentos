import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../components/animated_gradient_background.dart';
import '../components/staggered_entry_animation.dart';
import '../components/custom_toast.dart';
import '../widgets/register/register_header.dart';
import '../widgets/register/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: AnimatedGradientBackground(
          child: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                CustomToast.show(
                  context,
                  message: state.message,
                  type: ToastType.error,
                );
              } else if (state is AuthAuthenticated) {
                context.go('/home');
              }
            },
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const RegisterHeader(),
                          const SizedBox(height: 16),
                          StaggeredWidget(
                            index: 2,
                            child: const RegisterForm(),
                          ),
                          const Spacer(flex: 1),
                          const SizedBox(height: 8),
                          StaggeredWidget(
                            index: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Já tem uma conta? ',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.pop(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text(
                                    'Fazer Login',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
