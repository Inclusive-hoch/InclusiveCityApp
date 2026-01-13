import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        heightFactor: 1,
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              GoRouter.of(context).push('/map');
            }
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
              const Text('Empodérate de autonomía, disfruta tu ciudad'),
              Column(
                spacing: 10,
                children: [
                  FilledButton(
                    onPressed: () => {GoRouter.of(context).push('/login_form')},
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
                  FilledButton(
                    onPressed: () => {
                      //context.read<AuthBloc>().add(LoginWithGoogleRequested()),
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
                        AppColor.neutralLight,
                      ),
                    ),
                    child: Text(
                      'Registrarse',
                      style: TextStyle(color: AppColor.primaryNormal),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => {
                      context.read<AuthBloc>().add(LoginWithGoogleRequested()),
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
                        AppColor.primaryShadow,
                      ),
                    ),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/logo/google_logo.svg',
                          width: 20,
                          height: 20,
                        ),
                        Text(
                          'Continuar con Google',
                          style: TextStyle(color: AppColor.secondaryDark),
                        ),
                      ],
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
