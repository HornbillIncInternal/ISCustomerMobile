import 'dart:math' as math;

import 'dart:ui' as ui;
import 'package:hb_booking_mobile_app/home/content_sheet/widget/asset_mapview.dart';
import 'package:hb_booking_mobile_app/home/mapview/assetcard_mapview.dart';


import 'package:hb_booking_mobile_app/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

import '../../utils/is_loader.dart';
import '../asset_bloc/asset_bloc.dart';
import '../asset_bloc/asset_event.dart';
import '../asset_bloc/asset_state.dart';
class AssetMapView extends StatelessWidget {
  final String? location;
  final String? asset;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  const AssetMapView({
    Key? key,
    this.location,
    this.asset,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        if (state is AssetLoading) {
          return Center(child: OfficeLoader(
            size: 70,


          ));
        } else if (state is AssetError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is AssetLoaded) {
          return Stack(
            children: [
              GoogleMapWidget(
                markers: state.markers,
                initialPosition: state.markers.isNotEmpty
                    ? state.markers.first.position
                    : LatLng(10.1632, 76.6413),
                onMapCreated: (controller) {
                  // Save the controller reference if needed
                },
              ),
              if (state.selectedAsset != null)
                Positioned(
                  bottom: 60,
                  left: 20,
                  right: 20,
                  child: AssetCard(
                    asset: state.selectedAsset!,
                    index: state.selectedIndex!,
                    selectedDate: selectedDate,
                    selectedStartTime: selectedStartTime,
                    selectedEndTime: selectedEndTime,
                    selectedEndDate: selectedEndDate,
                    onClose: () {
                      // Refresh data
                      context.read<AssetBloc>().add(FetchAssetsEvent(
                        location: location ?? '',
                        asset: asset ?? '',
                        startDate: selectedDate,
                        startTime: selectedStartTime,
                        endDate: selectedEndDate,
                        endTime: selectedEndTime,
                        context: context,
                      ));
                    },
                  ),
                ),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
/*class AssetMapView extends StatelessWidget {
  final String? location;
  final String? asset;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  const AssetMapView({
    Key? key,
    this.location,
    this.asset,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AssetMapBloc()
        ..add(FetchAssetsEvent(
          location: location ?? '',
          asset: asset ?? '',
          startDate: selectedDate,
          startTime: selectedStartTime, // Can be null
          endDate: selectedEndDate,
          endTime: selectedEndTime,     // Can be null
          context: context,
        )),
      child: SafeArea(
        child: BlocBuilder<AssetMapBloc, AssetMapState>(
          builder: (context, state) {
            if (state is AssetMapLoading) {
              return Center(child: CircularProgressIndicator(color: primary_color));
            } else if (state is AssetMapError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is AssetMapLoaded) {
              return Stack(
                children: [
                  GoogleMapWidget(
                    markers: state.markers,
                    initialPosition: state.markers.isNotEmpty
                        ? state.markers.first.position
                        : LatLng(10.1632, 76.6413),
                    onMapCreated: (controller) {
                      // Save the controller reference if needed
                    },
                  ),
                  if (state.selectedAsset != null)
                    Positioned(
                      bottom: 60,
                      left: 20,
                      right: 20,
                      child: AssetCard(
                        asset: state.selectedAsset!,
                        index: state.selectedIndex!,
                        selectedDate: selectedDate,
                        selectedStartTime: selectedStartTime, // Can be null
                        selectedEndTime: selectedEndTime,     // Can be null
                        selectedEndDate: selectedEndDate,
                        onClose: () {
                          context.read<AssetMapBloc>().add(FetchAssetsEvent(
                            location: location ?? '',
                            asset: asset ?? '',
                            startDate: selectedDate,
                            startTime: selectedStartTime, // Can be null
                            endDate: selectedEndDate,
                            endTime: selectedEndTime,     // Can be null
                            context: context,
                          ));
                        },
                      ),
                    ),
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}*/
/*class AssetMapView extends StatelessWidget {
  final String? location;
  final String? asset;
  final String? start;
  final String? end;

  const AssetMapView({
    Key? key,
    this.location,
    this.asset,
    this.start,
    this.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current date and set default time range if not provided
    final DateTime now = DateTime.now();
    final String isoStartToday = start ?? DateTime(now.year, now.month, now.day, 9, 0, 0).toIso8601String();
    final String isoEndToday = end ?? DateTime(now.year, now.month, now.day, 18, 0, 0).toIso8601String();

    return BlocProvider(
      create: (context) => AssetMapBloc()
        ..add(FetchAssetsEvent(
          location: location ?? '',
          asset: asset ?? '',
          start: isoStartToday,
          end: isoEndToday,
          context: context,
        )),
      child: SafeArea(
        child: BlocBuilder<AssetMapBloc, AssetMapState>(
          builder: (context, state) {
            if (state is AssetMapLoading) {
              return Center(child: CircularProgressIndicator(color: primary_color));
            } else if (state is AssetMapError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is AssetMapLoaded) {
              return Stack(
                children: [
                  GoogleMapWidget(
                    markers: state.markers,
                    initialPosition: state.markers.isNotEmpty
                        ? state.markers.first.position
                        : LatLng(10.1632, 76.6413), // Default position if no markers
                    onMapCreated: (controller) {
                      // Save the controller reference if needed
                    },
                  ),
                  if (state.selectedAsset != null)
                    Positioned(
                      bottom: 60,
                      left: 20,
                      right: 20,
                      child: AssetCard(
                        asset: state.selectedAsset!,
                        index: state.selectedIndex!,
                        isoStart: isoStartToday, // Use formatted date
                        isoEnd: isoEndToday, // Use formatted date
                        onClose: () {
                          // Close the card and deselect the marker
                          context.read<AssetMapBloc>().add(FetchAssetsEvent(
                            location: location ?? '',
                            asset: asset ?? '',
                            start: isoStartToday, // Use formatted date
                            end: isoEndToday, // Use formatted date
                            context: context,
                          ));
                        },
                      ),
                    ),
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}*/
class GoogleMapWidget extends StatefulWidget {
  final Set<Marker> markers;
  final LatLng initialPosition;
  final void Function(GoogleMapController) onMapCreated;

  const GoogleMapWidget({
    Key? key,
    required this.markers,
    required this.initialPosition,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _controller;
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _isMapReady = true;
          widget.onMapCreated(controller);

          // If you have markers, fit them in the view
          if (widget.markers.isNotEmpty) {
            _fitMarkersInView();
          }
        },
        markers: widget.markers,
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 14.0, // Increased zoom for better visibility
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: true,
        onTap: (LatLng position) {
          // Handle map tap if needed
          print('Map tapped at: ${position.latitude}, ${position.longitude}');
        },
      ),
    );
  }

  void _fitMarkersInView() {
    if (_controller != null && widget.markers.isNotEmpty) {
      double minLat = widget.markers.first.position.latitude;
      double maxLat = widget.markers.first.position.latitude;
      double minLng = widget.markers.first.position.longitude;
      double maxLng = widget.markers.first.position.longitude;

      for (Marker marker in widget.markers) {
        minLat = math.min(minLat, marker.position.latitude);
        maxLat = math.max(maxLat, marker.position.latitude);
        minLng = math.min(minLng, marker.position.longitude);
        maxLng = math.max(maxLng, marker.position.longitude);
      }

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _controller!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }
}

/*class GoogleMapWidget extends StatefulWidget {
  final Set<Marker> markers;
  final LatLng initialPosition;
  final void Function(GoogleMapController) onMapCreated;

  const GoogleMapWidget({
    required this.markers,
    required this.initialPosition,
    required this.onMapCreated,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
  }

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
}*/

Future<BitmapDescriptor> _createPriceMarkerIcon(BuildContext context, String price) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(200, 100); // Adjust the size as needed

  // Draw the background
  final paint = Paint()..color = Colors.white;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

  // Draw the price text
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );
  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: 40.0, // Adjust the text size as needed
  );
  textPainter.text = TextSpan(
    text: price,
    style: textStyle,
  );
  textPainter.layout(
    minWidth: 0,
    maxWidth: size.width,
  );
  final offset = Offset(
    (size.width - textPainter.width) / 2,
    (size.height - textPainter.height) / 2,
  );
  textPainter.paint(canvas, offset);

  // Convert the canvas to an image
  final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(bytes);
}


