import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'aesthetics/themes.dart';


class DarkModeSettingsPage extends StatelessWidget {
  const DarkModeSettingsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode Settings'),
      ),
      body: Center(
        child: Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, _) {
            bool isDarkMode = themeNotifier.getTheme() == darkTheme;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SwitchListTile(
                  title: Text(
                    'Enable Dark Mode',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  value: isDarkMode,
                  onChanged: (value) {
                    themeNotifier.toggleTheme();
                  },
                  activeTrackColor: const Color.fromARGB(255, 54, 54, 114),
                  activeColor: isDarkMode ? Colors.white : Colors.black45,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

