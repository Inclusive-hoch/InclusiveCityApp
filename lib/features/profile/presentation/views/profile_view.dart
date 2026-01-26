import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/profile_menu_item.dart';


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
                //Bototon de perfil
                _buildUserSection(context, userName, photoUrl),
                const SizedBox(height: 24),
                const Divider(color: AppColor.primaryLight),
                //Boton ajustes
                ProfileMenuItem(icon: Icons.settings, label: 'Ajustes', onTap: () {}),
                //Boton ayuda
                ProfileMenuItem(icon: Icons.help, label: 'Ayuda', onTap: () {}),
                //Boton cerrar sesion
                ProfileMenuItem(icon: Icons.logout, label: 'Cerrar sesión', onTap: () => _showLogoutDialog(context)),
              ],
            );
          }
        ),
      );
  }


  /// Construye la sección de usuario con avatar y nombre
  Widget _buildUserSection(
    BuildContext context,
    String userName,
    String? photoUrl,
  ) {
    return InkWell(
        onTap: () => context.push('/profile/details'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal:24),
          child: Row(
            children: [
              // Avatar circular del usuario
              ProfileAvatar(
                photoUrl: photoUrl,
                size: 100,
              ),
              const SizedBox(width: 20),
              
              // Nombre del usuario
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondaryNormal,
                  ),
                ),
              ),
              
              // Flecha indicando que es clickeable
              const Icon(
                Icons.chevron_right,
                color: AppColor.primaryNormal,
                size: 32,
              ),
            ],
          ),
        ),
      );
    
  }

//modal logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Dispara el evento de logout en el AuthBloc
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColor.redNormal),
            ),
          ),
        ],
      ),
    );
  }
}

