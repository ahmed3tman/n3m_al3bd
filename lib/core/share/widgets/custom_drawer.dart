import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/core/theme/theme_cubit.dart';

class OpenDrawerNotification extends Notification {}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
            ),
            child: Center(
              child: Image.asset('assets/logo.PNG', height: 150, width: 150),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0, bottom: 8.0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'المظهر',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'GeneralFont',
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, currentTheme) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildThemeOption(
                      context,
                      label: 'فاتح',
                      mode: ThemeMode.light,
                      currentMode: currentTheme,
                      icon: Icons.wb_sunny_rounded,
                    ),
                    _buildThemeOption(
                      context,
                      label: 'داكن',
                      mode: ThemeMode.dark,
                      currentMode: currentTheme,
                      icon: Icons.nightlight_round,
                    ),
                    _buildThemeOption(
                      context,
                      label: 'تلقائي',
                      mode: ThemeMode.system,
                      currentMode: currentTheme,
                      icon: Icons.brightness_auto_rounded,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
  }) {
    final isSelected = mode == currentMode;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        context.read<ThemeCubit>().updateTheme(mode);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceVariant.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : colorScheme.onSurface,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
