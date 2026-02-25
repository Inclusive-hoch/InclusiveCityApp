import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/user_evaluations_list.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_bloc.dart';
import 'package:inclusive_app/injection_container.dart';

class ProfileDetailsView extends StatelessWidget {
  const ProfileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UserEvaluationBloc>(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text(
            'Mi perfil',
            style: TextStyle(
              color: AppColor.secondaryNormal,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColor.primaryNormal, size: 30),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.go('/map');
              },
              icon: const Icon(Icons.close, color: AppColor.primaryNormal, size: 30),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;
            final userName = user?.name ?? 'Usuario';
            final photoUrl = user?.profilePictureUrl;

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: AppColor.primaryLight, height: 1),
                  // Avatar y nombre
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                    child: Column(
                      children: [
                        ProfileAvatar(
                          photoUrl: photoUrl,
                          size: 120,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondaryNormal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Lista de evaluaciones
                  const UserEvaluationsList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
