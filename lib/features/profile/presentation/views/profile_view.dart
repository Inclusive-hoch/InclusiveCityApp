import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/profile_user_section.dart';


class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
      body:  BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state){
            final user = state is AuthAuthenticated ? state.user : null;
            final userName = user?.name ?? 'Usuario';
            final photoUrl = user?.profilePictureUrl;

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileUserSection(userName: userName, photoUrl: photoUrl),
                const Divider(color: AppColor.primaryLight),
                //Boton ajustes
                ProfileMenuItem(icon: Icons.settings, label: 'Ajustes', onTap: () {}),
                //Boton ayuda
                ProfileMenuItem(icon: Icons.help, label: 'Ayuda', onTap: () {}),
                //Boton cerrar sesion
                ProfileMenuItem(icon: Icons.logout, label: 'Cerrar sesión', onTap: () => LogoutDialog.show(context)),
              ],
            );
          }
        ),
      );
  }
}

