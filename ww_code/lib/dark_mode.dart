import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DarkModeSettingsPage extends StatelessWidget {
  const DarkModeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Dark Mode Settings Page',
              //style: Theme.of(context).textTheme.headline4,
            ),
            SwitchListTile(
              title: const Text('Enable Dark Mode'),
              value: false,
              onChanged: (value) {
                //Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }
}
