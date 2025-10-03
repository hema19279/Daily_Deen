import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../themes/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: AppColors.theme)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settingsViewModel.isDarkMode,
            onChanged: (value) => settingsViewModel.toggleDarkMode(value),
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: settingsViewModel.notificationsEnabled,
            onChanged: (value) => settingsViewModel.toggleNotifications(value),
          ),
        ],
      ),
    );
  }

}