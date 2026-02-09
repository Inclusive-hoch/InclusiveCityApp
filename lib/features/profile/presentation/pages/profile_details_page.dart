import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/profile/presentation/views/profile_details_view.dart';
import 'package:inclusive_app/injection_container.dart' as sl;

class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value : sl.sl<AuthBloc>(),
      child: const ProfileDetailsView(),
    );
  }
}