import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  final String location;
  final double latitude;
  final double longitude;

  const MapPage({
    Key? key,
    required this.location,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId(location),
            position: LatLng(latitude, longitude),
          ),
        },
      ),
    );
  }
}
