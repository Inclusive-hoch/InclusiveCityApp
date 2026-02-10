import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

class IncidentItem extends StatelessWidget {
  const IncidentItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primaryNormalActive
                : const Color.fromARGB(255, 231, 230, 230),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                spreadRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 48,
            color: isSelected ? Colors.white : AppColor.secondaryNormal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isSelected
                ? AppColor.primaryNormalActive
                : AppColor.secondaryNormal,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    ),
  );
}
