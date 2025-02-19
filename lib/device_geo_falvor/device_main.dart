import 'package:backlocation/device_geo_falvor/geolocation_configuration.dart';
import 'package:backlocation/device_geo_falvor/headlessMethod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core components
  await Firebase.initializeApp();
  await GeolocationConfiguration.getGeolocationReady();
  await bg.BackgroundGeolocation.start();

  // Register headless task
  bg.BackgroundGeolocation.registerHeadlessTask(
      HandleHeadlessEvents.backgroundGeolocationHeadlessTask
  );

  // Start service immediately

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text('Location Service Active'),
      ),
    ),
  ));
}