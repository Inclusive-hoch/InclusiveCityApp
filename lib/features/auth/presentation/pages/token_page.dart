import 'package:flutter/material.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TokenPage extends StatelessWidget {
  const TokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state as AuthAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('ID Token')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SelectableText(
              state.user.uid,
              style: const TextStyle(fontSize: 12),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
