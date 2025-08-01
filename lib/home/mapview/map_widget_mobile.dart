import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlatformGoogleMap extends StatefulWidget {
  final Set<Marker> markers;
  final LatLng initialPosition;
  final void Function(GoogleMapController) onMapCreated;

  const PlatformGoogleMap({
    Key? key,
    required this.markers,
    required this.initialPosition,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  State<PlatformGoogleMap> createState() => _PlatformGoogleMapState();
}

class _PlatformGoogleMapState extends State<PlatformGoogleMap> {
  BitmapDescriptor? _customMarkerIcon;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      markers: widget.markers,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: 10,
      ),
    );
  }
}