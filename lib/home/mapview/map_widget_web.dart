import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as web_maps;

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
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    GoogleMapsFlutterPlatform.instance = web_maps.GoogleMapsPlugin();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        _controller = controller;
        widget.onMapCreated(controller);
      },
      markers: widget.markers,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: 10,
      ),
    );
  }
}