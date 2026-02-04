import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/profile_avatar.dart';

class ProfileUserSection extends StatelessWidget {
  final String userName;
  final String? photoUrl;

  const ProfileUserSection({
    super.key,
    required this.userName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/profile/details'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Row(
          children: [
            ProfileAvatar(
              photoUrl: photoUrl,
              size: 100,
            ),
            const SizedBox(width: 20),
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
}