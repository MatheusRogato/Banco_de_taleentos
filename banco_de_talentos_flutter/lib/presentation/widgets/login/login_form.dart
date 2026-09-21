import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../components/login_input.dart';
import '../../components/animated_primary_button.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoginInput(
                label: 'E-mail',
                icon: Icons.email_outlined,
                placeholder: 'exemplo@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                errorText: _emailError,
              ),
              const SizedBox(height: 20),
              LoginInput(
                label: 'Senha',
                icon: Icons.lock_outline,
                placeholder: 'senha',
                controller: _passwordController,
                isPassword: true,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                errorText: _passwordError,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Esqueci minha senha',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedPrimaryButton(
                isLoading: state is AuthLoading,
                onPressed: _submit,
                text: 'Entrar na plataforma',
              ),
            ],
          ),
        );
      },
    );
  }
}
