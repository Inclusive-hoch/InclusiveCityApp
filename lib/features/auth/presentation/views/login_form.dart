import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
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
        heightFactor: 1,
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // if (state is AuthAuthenticated) {
            //   GoRouter.of(context).go('/map');
            // }
          },
          child: Column(
            spacing: 40,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SvgPicture.asset(
                'assets/logo/title.svg',
                width: 200,
                height: 200,
              ),
              Column(
                spacing: 20,
                children: [
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Correo electrónico',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Contraseña',
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => {
                      context.read<AuthBloc>().add(
                        LoginWithEmailRequested(
                          emailController.text,
                          passwordController.text,
                        ),
                      ),
                    },
                    style: ButtonStyle(
                      elevation: WidgetStatePropertyAll(2),
                      fixedSize: WidgetStatePropertyAll(Size(300, 43)),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        AppColor.primaryNormal,
                      ),
                    ),
                    child: Text('Iniciar sesión'),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: AppColor.primaryNormal,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
