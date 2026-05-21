import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BottomNavTabs extends StatelessWidget {
  const BottomNavTabs({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.labels,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;

  static const _icons = [
    Icons.home_rounded,
    Icons.nfc_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: List.generate(3, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.red.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[i],
                            size: 22,
                            color: active ? AppColors.red : AppColors.text3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                              color: active ? AppColors.red : AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
