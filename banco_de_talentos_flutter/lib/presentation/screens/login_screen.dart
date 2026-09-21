import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../components/animated_gradient_background.dart';
import '../components/staggered_entry_animation.dart';
import '../components/custom_toast.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
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
                    padding: const EdgeInsets.all(24.0),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 2),
                          const LoginHeader(),
                          const Spacer(flex: 2),
                          StaggeredWidget(
                            index: 3,
                            child: const LoginForm(),
                          ),
                          const Spacer(flex: 3),
                          const SizedBox(height: 16),
                          StaggeredWidget(
                            index: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Novo por aqui? ',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/register'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text(
                                    'Criar minha conta',
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
