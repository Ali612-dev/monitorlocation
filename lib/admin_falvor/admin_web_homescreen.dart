// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:latlong2/latlong.dart' as latLng;
//
//
// class AdminWebHomeScreen extends StatefulWidget {
//   const AdminWebHomeScreen({super.key});
//
//   @override
//   State<StatefulWidget> createState() {
//     return _AdminWebHomeScreenState();
//   }
// }
//
// class _AdminWebHomeScreenState extends State<AdminWebHomeScreen> {
//   final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
//   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("geolocation/user_location");
//
//   static const CameraPosition _initialCameraPosition = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//
//   LatLng? _userLocation;
//   LatLng? _previousLocation;
//   double _userHeading = 0.0; // Heading angle
//   Set<Marker> _markers = {}; // Set to hold markers (user arrow)
//   bool _isConnected = false; // Connection status
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAndListenToLocationUpdates();
//     _checkFirebaseConnection();
//   }
//
//   // Listen for updates from Firebase Realtime Database
//   void _fetchAndListenToLocationUpdates() {
//     _dbRef.onValue.listen((DatabaseEvent event) {
//       final data = event.snapshot.value as Map?;
//       if (data != null) {
//         final double latitude = data['lat'];
//         final double longitude = data['lon'];
//         final double heading = data['heading'] ?? -1; // Optional heading
//
//         final newLocation = LatLng(latitude, longitude);
//
//         // If there's a previous location, calculate the distance
//         if (_previousLocation != null) {
//           double distanceInMeters = _calculateDistance(_previousLocation!, newLocation);
//
//           // Update location only if the distance is more than 1 meter
//           if (distanceInMeters >= 1) {
//             setState(() {
//               _userLocation = newLocation;
//               _userHeading = heading;
//               _updateMarkers(newLocation, heading); // Update markers (arrow)
//             });
//             _moveCameraToUserLocation(latitude, longitude);
//           }
//         } else {
//           // Set the first location if no previous location exists
//           setState(() {
//             _userLocation = newLocation;
//             _userHeading = heading;
//             _updateMarkers(newLocation, heading); // Set first marker
//           });
//           _moveCameraToUserLocation(latitude, longitude);
//         }
//
//         // Update the previous location to the new one for the next check
//         _previousLocation = newLocation;
//       }
//     });
//   }
//
//   // Calculate distance between two locations in meters
//   double _calculateDistance(LatLng start, LatLng end) {
//     final distance = latLng.LatLng(start.latitude, start.longitude);
//     final endPoint = latLng.LatLng(end.latitude, end.longitude);
//     final distanceInMeters = latLng.Distance().as(latLng.LengthUnit.Meter, distance, endPoint);
//     return distanceInMeters;
//   }
//
//   Future<BitmapDescriptor> _getCustomMarkerIcon() async {
//     return await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(48, 48)), // Set the size of the marker icon
//       'assets/phone.jpg',
//     );
//   }
//
//
//   // Update the markers (user arrow) on the map
//   void _updateMarkers(LatLng location, double heading)async {
//     BitmapDescriptor customIcon = await _getCustomMarkerIcon();
//
//     setState(() {
//       _markers = {
//         Marker(
//           markerId: const MarkerId("user_arrow"),
//           position: location,
//           icon:customIcon, // Use default yellow marker
//           rotation: heading, // Rotate marker to match the heading (direction)
//           anchor: const Offset(-5, 5),
//           infoWindow: InfoWindow(
//             title:"device status : ${_isConnected?'online':"offline"}\n"
//                 "user name :Ali Adel "
//
//           )// Center anchor for accurate rotation
//         ),
//       };
//     });
//   }
//
//   // Move camera to the new user location
//   Future<void> _moveCameraToUserLocation(double latitude, double longitude) async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
//   }
//
//   // Check Firebase Realtime Database connection status
//   void _checkFirebaseConnection() {
//     final DatabaseReference connectedRef = FirebaseDatabase.instance.ref(".info/connected");
//
//     connectedRef.onValue.listen((event) {
//       final bool isConnected = event.snapshot.value as bool;
//       setState(() {
//         _isConnected = isConnected;
//       });
//
//       // Display a message based on connection status
//       if (_isConnected) {
//         print("Device is connected to Firebase Realtime Database.");
//       } else {
//         print("Device is disconnected from Firebase Realtime Database.");
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.0,
//         title: const Text("Real-Time Device Position"),
//         centerTitle: true,
//         actions: [
//           // Display connection status in the app bar
//           IconButton(
//             icon: Icon(
//               _isConnected ? Icons.check_circle : Icons.error,
//               color: _isConnected ? Colors.green : Colors.red,
//             ),
//             onPressed: () {
//               // Optionally, show an alert or perform some action when the icon is clicked
//             },
//           ),
//         ],
//       ),
//       body: GoogleMap(
//         mapType: MapType.normal,
//         initialCameraPosition: _initialCameraPosition,
//         markers: _markers, // Add markers (user arrow)
//         circles: _userLocation != null
//             ? {
//           Circle(
//             circleId: const CircleId("user_circle"),
//             center: _userLocation!,
//             radius: 20, // Small radius for the blue dot
//             fillColor: Colors.blue.withOpacity(0.6),
//             strokeColor: Colors.blue.withOpacity(0.8),
//             strokeWidth: 10,
//           ),
//         }
//             : {},
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ),
//     );
//   }
// }
