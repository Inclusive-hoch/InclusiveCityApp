import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.primaryNormal,
            size: 30,
          ),
        ),
      ),
      body: Center(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              GoRouter.of(context).go('/map');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 40,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo/title.svg',
                    width: 200,
                    height: 200,
                  ),
                  const Text(
                    'Crear cuenta',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    spacing: 20,
                    children: [
                      // Name field
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nombre completo',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Email field
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Correo electrónico',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            // Email regex validation
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Por favor ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Password field
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Contraseña',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Confirm password field
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Confirmar contraseña',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor confirma tu contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Submit button
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              RegisterWithEmailRequested(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                              ),
                            );
                          }
                        },
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(2),
                          fixedSize: const WidgetStatePropertyAll(
                            Size(300, 43),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          backgroundColor: const WidgetStatePropertyAll(
                            AppColor.primaryNormal,
                          ),
                        ),
                        child: const Text('Registrarse'),
                      ),
                    ],
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
