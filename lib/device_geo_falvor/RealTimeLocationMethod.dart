import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

Future<void> sendLocationToRealtimeDatabase(bg.Location location) async {
  try {
    final database = FirebaseDatabase.instance.ref();


    // Use the relative path in the Realtime Database
    await database.child('geolocation').child('user_location').set({
      'lat': location.coords.latitude,
      'lon': location.coords.longitude,
      'timestamp': location.timestamp,
      'battery': location.battery.level,// Assuming battery info is available
      'heading':location.coords.heading
    });

    print('Location sent to Realtime Database: ${location.coords.latitude}, ${location.coords.longitude}');
  } catch (e) {
    print('Error sending location to Realtime Database: $e');
  }
}