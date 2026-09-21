import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/formatters.dart';
import '../../components/login_input.dart';
import '../../components/animated_primary_button.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _fullNameController = TextEditingController();
  final _documentController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _fullNameError;
  String? _documentError;
  String? _emailError;
  String? _passwordError;

  final _cpfFormatter = CpfInputFormatter();

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _fullNameError = Validators.validateRequired(
          _fullNameController.text, 'Nome completo');
      _documentError = Validators.validateCPF(_documentController.text);
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
    });

    if (_fullNameError == null &&
        _documentError == null &&
        _emailError == null &&
        _passwordError == null) {
      context.read<AuthCubit>().register(
            _emailController.text.trim(),
            _passwordController.text,
            _fullNameController.text.trim(),
            _documentController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
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
                label: 'Nome Completo',
                icon: Icons.person_outline,
                placeholder: 'Digite seu nome completo',
                controller: _fullNameController,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                errorText: _fullNameError,
              ),
              const SizedBox(height: 12),
              LoginInput(
                label: 'CPF',
                icon: Icons.badge_outlined,
                placeholder: '000.000.000-00',
                controller: _documentController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [_cpfFormatter],
                errorText: _documentError,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              LoginInput(
                label: 'Senha',
                icon: Icons.lock_outline,
                placeholder: 'Crie uma senha forte',
                controller: _passwordController,
                isPassword: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                errorText: _passwordError,
              ),
              const SizedBox(height: 16),
              AnimatedPrimaryButton(
                isLoading: state is AuthLoading,
                onPressed: _submit,
                text: 'Criar minha conta',
              ),
            ],
          ),
        );
      },
    );
  }
}
