import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_google_maps_webservices/directions.dart' as gmaps_web;
import 'dart:convert';
import 'package:http/http.dart' as http;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      authDomain: "geolocation-d39fd.firebaseapp.com",
      databaseURL: "https://geolocation-d39fd-default-rtdb.firebaseio.com",
      projectId: "geolocation-d39fd",
      storageBucket: "geolocation-d39fd.firebasestorage.app",
      messagingSenderId: "731094034670",
      appId: "1:731094034670:web:d85b07e799462177136bff",
      measurementId: "G-SGR0LQNGZN",
    ),
  );
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: AdminWebHomeScreen()));
}

class AdminWebHomeScreen extends StatefulWidget {
  const AdminWebHomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AdminWebHomeScreenState();
}

class _AdminWebHomeScreenState extends State<AdminWebHomeScreen> {
  final Completer<gmaps.GoogleMapController> _controller = Completer();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("geolocation/user_location");

  static const gmaps.CameraPosition _initialCameraPosition = gmaps.CameraPosition(
    target: gmaps.LatLng(30.5816672, 31.4847989),
    zoom: 17,
  );

  gmaps.LatLng? _previousLocation;
  final String googleAPIKey = "AIzaSyB7mtSHZ5tjIOiYXsnal4WwqZSO4wHv8xw";
  Set<gmaps.Marker> _markers = {};
  Set<gmaps.Polyline> _polylines = {};
  List<gmaps.LatLng> _pathPoints = [];
  final gmaps_web.GoogleMapsDirections _directionsService =
  gmaps_web.GoogleMapsDirections(apiKey: "AIzaSyB7mtSHZ5tjIOiYXsnal4WwqZSO4wHv8xw");


  @override
  void initState() {
    super.initState();
    _fetchAndListenToLocationUpdates();
  }

  /// Listens to Firebase updates and fetches new location data
  void _fetchAndListenToLocationUpdates() {
    _dbRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final newLocation = gmaps.LatLng(
          data['lat'].toDouble(),
          data['lon'].toDouble(),
        );

        if (_previousLocation != null) {
          await _fetchRoute(_previousLocation!, newLocation);
        }

        _updateMap(newLocation, data['heading']?.toDouble() ?? -1);
        _previousLocation = newLocation;
      }
    });
  }

  /// Fetches route using Google Maps Web Services
  Future<void> _fetchRoute(gmaps.LatLng start, gmaps.LatLng end) async {

    final String directionsUrl = "http://localhost:3000/getDirections?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}";

    try {
      print("Fetching route from ${start.latitude},${start.longitude} to ${end.latitude},${end.longitude}");

      final response = await http.get(Uri.parse(directionsUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data["status"] == "OK") {
          List<gmaps.LatLng> newPolylinePoints = [];

          for (var route in data["routes"]) {
            for (var leg in route["legs"]) {
              for (var step in leg["steps"]) {
                final endLocation = step["end_location"];
                newPolylinePoints.add(gmaps.LatLng(endLocation["lat"], endLocation["lng"]));
              }
            }
          }

          setState(() {
            _pathPoints.addAll(newPolylinePoints);
            _polylines = {
              gmaps.Polyline(
                polylineId: const gmaps.PolylineId('user_path'),
                points: _pathPoints,
                color: Colors.blue,
                width: 5,
                geodesic: true,
              ),
            };
          });

          print("Route updated successfully!");
        } else {
          print("No route found. API Response: ${data["status"]}");
        }
      } else {
        print("Failed to fetch directions: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Error fetching directions: $error");
    }
  }

  /// Updates the marker and moves the camera to the new location
  void _updateMap(gmaps.LatLng newLocation, double heading) async {
    final double bearing = heading >= 0
        ? heading
        : (_previousLocation != null ? _calculateBearing(_previousLocation!, newLocation) : 0);

    final gmaps.BitmapDescriptor rotatedIcon = await _getRotatedMarker(bearing);

    setState(() {
      _markers = {
        gmaps.Marker(
          markerId: const gmaps.MarkerId("user_marker"),
          position: newLocation,
          icon: rotatedIcon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: const gmaps.InfoWindow(title: "User is Moving"),
        ),
      };
    });

    _moveCameraToUserLocation(newLocation);
  }

  /// Rotates marker icon based on heading direction
  Future<gmaps.BitmapDescriptor> _getRotatedMarker(double heading) async {
    final ByteData data = await rootBundle.load('assets/direction_arrow.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetHeight: 40, targetWidth: 40);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image img = frameInfo.image;
    final double width = img.width.toDouble();
    final double height = img.height.toDouble();
    final recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.translate(width / 2, height / 2);
    canvas.rotate(heading * pi / 180);
    canvas.translate(-width / 2, -height / 2);
    final Paint paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImage(img, Offset.zero, paint);
    final ui.Image rotatedImg = await recorder.endRecording().toImage(img.width, img.height);
    final ByteData? rotatedData = await rotatedImg.toByteData(format: ui.ImageByteFormat.png);
    return gmaps.BitmapDescriptor.fromBytes(rotatedData!.buffer.asUint8List());
  }

  /// Moves the camera smoothly to the new user location
  Future<void> _moveCameraToUserLocation(gmaps.LatLng location) async {
    final controller = await _controller.future;
    controller.animateCamera(
      gmaps.CameraUpdate.newLatLngZoom(location, 17),
    );
  }

  /// Calculates the bearing between two locations
  double _calculateBearing(gmaps.LatLng start, gmaps.LatLng end) {
    final startLat = start.latitude * pi / 180;
    final startLng = start.longitude * pi / 180;
    final endLat = end.latitude * pi / 180;
    final endLng = end.longitude * pi / 180;
    final y = sin(endLng - startLng) * cos(endLat);
    final x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(endLng - startLng);
    var bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking with Road-Following Polyline")),
      body: gmaps.GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) => _controller.complete(controller),
        myLocationEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: true,
      ),
    );
  }
}
