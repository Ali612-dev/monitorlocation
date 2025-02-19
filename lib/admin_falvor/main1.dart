import 'dart:async';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart'as gmfw;
import 'dart:convert';
import 'package:http/http.dart' as http;

void main(){
 runApp(MaterialApp(
   home: MapSample(),
 ));
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  var apiKey="AIzaSyB7mtSHZ5tjIOiYXsnal4WwqZSO4wHv8xw";
  final Completer<gmfw.GoogleMapController> _controller =
  Completer<gmfw.GoogleMapController>();

  Future<void> fetchDirections() async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=30.5816691,31.4847139&destination=30.5816677,31.4847143"
        "&mode=driving&key=$apiKey";

    final request = html.HttpRequest();
    request.open("GET", url, async: true);
    request.onLoadEnd.listen((event) {
      if (request.status == 200) {
        final data = jsonDecode(request.responseText!);
        print("✅ Directions: ${data['routes']}");
      } else {
        print("❌ Failed to fetch: ${request.status}");
      }
    });

    request.send();
  }

  Future<String> getRouteCoordinates()async{
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=30.5816691,31.4847139&destination=30.5816691,31.4847139&key=$apiKey";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    return values["routes"][0]["overview_polyline"]["points"];
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller as FutureOr<gmfw.GoogleMapController>?);
        },
      ),
      floatingActionButton: FutureBuilder(future: getRouteCoordinates(), builder: (context,snap)
      =>TextButton(onPressed: (){
        snap.data;
        print(snap.connectionState);
        print(snap.data);
      }, child: Text('data')))
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = (await _controller.future) as GoogleMapController;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}