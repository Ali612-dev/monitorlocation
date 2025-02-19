// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
// import 'package:firebase_database/firebase_database.dart';
//
// void main() {
//   runApp(MyApp());
//   // Register the headless task for background execution.
//   bg.BackgroundGeolocation.registerHeadlessTask(backgroundGeolocationHeadlessTask);
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Background Geolocation',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     initBackgroundGeolocation();
//   }
//
//   void initBackgroundGeolocation() async {
//     // Firebase Database reference
//     final DatabaseReference dbRef = FirebaseDatabase.instance.ref("locations");
//
//     // Configure BackgroundGeolocation
//     bg.BackgroundGeolocation.ready(bg.Config(
//       desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
//       distanceFilter: 10,
//       stopOnTerminate: false,
//       startOnBoot: true,
//       enableHeadless: true,
//       notification: bg.Notification(
//         title: "Location Tracking",
//         text: "Tracking your location in the background.",
//         sticky: true,
//       ),
//       logLevel: bg.Config.LOG_LEVEL_VERBOSE,
//     )).then((bg.State state) {
//       if (!state.enabled) {
//         bg.BackgroundGeolocation.start();
//       }
//     });
//
//     // Listen for location updates
//     bg.BackgroundGeolocation.onLocation((bg.Location location) {
//       double? latitude = location.coords.latitude;
//       double? longitude = location.coords.longitude;
//
//       // Save location to Firebase Realtime Database
//       dbRef.push().set({
//         'latitude': latitude,
//         'longitude': longitude,
//         'timestamp': DateTime.now().toIso8601String()
//       });
//
//       print("[onLocation] Lat: $latitude, Long: $longitude");
//     });
//
//     // // Listen for errors
//     // bg.BackgroundGeolocation.((bg.Error error) {
//     //   print("[onError] code: ${error.code}, message: ${error.message}");
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Background Geolocation"),
//       ),
//       body: Center(
//         child: Text("Tracking location in the background..."),
//       ),
//     );
//   }
// }
//
// // Headless task callback
// void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
//   switch (headlessEvent.name) {
//     case bg.Event.LOCATION:
//       bg.Location location = headlessEvent.event;
//       double? latitude = location.coords.latitude;
//       double? longitude = location.coords.longitude;
//
//       // Firebase Database reference
//       final DatabaseReference dbRef = FirebaseDatabase.instance.ref("locations");
//
//       // Save location to Firebase Realtime Database
//       dbRef.push().set({
//         'latitude': latitude,
//         'longitude': longitude,
//         'timestamp': DateTime.now().toIso8601String()
//       });
//
//       print("[HeadlessTask] Lat: $latitude, Long: $longitude");
//       break;
//
//     case bg.Event.TERMINATE:
//       print("[HeadlessTask] App terminated.");
//       break;
//
//     default:
//       print("[HeadlessTask] Event: ${headlessEvent.name}");
//       break;
//   // }
// }
