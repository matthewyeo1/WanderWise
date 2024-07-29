import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'localization/locales.dart';

class MapInfoPage extends StatelessWidget {
  const MapInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.mapInfoTitle.getString(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleData.mapInfoHeader.getString(context),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              LocaleData.info1.getString(context),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Text(
              LocaleData.info2.getString(context),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Text(
              LocaleData.info3.getString(context),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Image.asset(
              'images/map_info_3.png',
              height: 500,
              width: 500,
            ),
            const SizedBox(height: 50),
            Text(LocaleData.info4.getString(context),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Image.asset(
              'images/map_info_4.png',
              height: 500,
              width: 500,
            ),
            const SizedBox(height: 10),
            Image.asset(
              'images/map_info_4.1.png',
              height: 500,
              width: 500,
            ),
            const SizedBox(height: 50),
            Text(
              LocaleData.info5.getString(context),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Image.asset(
              'images/map_info_6.png',
              height: 500,
              width: 500,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
