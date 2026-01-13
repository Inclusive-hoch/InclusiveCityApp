import 'package:flutter/material.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';

class AuthRouterNotifier extends ChangeNotifier {
  final AuthBloc authBloc;

  AuthRouterNotifier(this.authBloc) {
    authBloc.stream.listen((_) {
      notifyListeners();
    });
  }
}
