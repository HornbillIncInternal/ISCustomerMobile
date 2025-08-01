// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:booking_hb_app/home/model/model_assets.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class AssetMapView extends StatefulWidget {
//   final AssetData assetData;
//   const AssetMapView({required this.assetData});
//
//   @override
//   _AssetMapViewState createState() => _AssetMapViewState();
// }
//
// class _AssetMapViewState extends State<AssetMapView> {
//   late GoogleMapController mapController;
//   final Set<Marker> _markers = {};
//   final ValueNotifier<Datum?> _selectedAsset = ValueNotifier<Datum?>(null);
//   final ValueNotifier<int?> _selectedIndex = ValueNotifier<int?>(null);
//
//   @override
//   void initState() {
//     super.initState();
//     _setMarkers();
//   }
//
//   void _setMarkers() {
//     final assets = widget.assetData.data;
//     _markers.clear();
//     for (var entry in assets.asMap().entries) {
//       final asset = entry.value;
//       final index = entry.key;
//       _markers.add(
//         Marker(
//           markerId: MarkerId(asset.id),
//           position: LatLng(
//             asset.branch.address.location.lat,
//             asset.branch.address.location.lng,
//           ),
//           infoWindow: InfoWindow(
//             title: asset.title,
//             snippet: 'Rating: ${asset.rating}  Price: ${asset.price}',
//           ),
//           onTap: () => _onMarkerTapped(asset, index),
//         ),
//       );
//     }
//   }
//
//   void _onMarkerTapped(Datum asset, int index) {
//     _selectedAsset.value = asset;
//     _selectedIndex.value = index;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final assets = widget.assetData.data;
//     return Stack(
//       children: [
//         GoogleMapWidget(
//           markers: _markers,
//           initialPosition: LatLng(
//             assets[0].branch.address.location.lat,
//             assets[0].branch.address.location.lng,
//           ),
//           onMapCreated: (controller) => mapController = controller,
//         ),
//         /*ValueListenableBuilder<Datum?>(
//           valueListenable: _selectedAsset,
//           builder: (context, asset, child) {
//             if (asset == null) {
//               return SizedBox.shrink();
//             }
//             return Positioned(
//               bottom: 60,
//               left: 20,
//               right: 20,
//               child: ValueListenableBuilder<int?>(
//                 valueListenable: _selectedIndex,
//                 builder: (context, index, child) {
//                   return AssetCard(
//                     asset: asset,
//                     index: index ?? 0,
//                     onClose: () {
//                       _selectedAsset.value = null;
//                     },
//                   );
//                 },
//               ),
//             );
//           },
//         ),*/
//       ],
//     );
//   }
// }
// class GoogleMapWidget extends StatefulWidget {
//   final Set<Marker> markers;
//   final LatLng initialPosition;
//   final void Function(GoogleMapController) onMapCreated;
//
//   const GoogleMapWidget({
//     required this.markers,
//     required this.initialPosition,
//     required this.onMapCreated,
//   });
//
//   @override
//   State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
// }
//
// class _GoogleMapWidgetState extends State<GoogleMapWidget> {
//   BitmapDescriptor? _customMarkerIcon;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCustomMarkerIcon();
//   }
//
//   Future<void> _loadCustomMarkerIcon() async {
//     final BitmapDescriptor markerIcon = await _createCustomMarkerIcon(context);
//     setState(() {
//       _customMarkerIcon = markerIcon;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final Set<Marker> customMarkers = widget.markers.map((marker) {
//       return marker.copyWith(
//         iconParam: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
//       );
//     }).toSet();
//     return GoogleMap(
//       onMapCreated: widget.onMapCreated,
//       markers: customMarkers,
//       initialCameraPosition: CameraPosition(
//         target: widget.initialPosition,
//         zoom: 10,
//       ),
//     );
//   }
// }
// Future<BitmapDescriptor> _createCustomMarkerIcon(BuildContext context) async {
//   // Load the image from assets
//   final ByteData assetByteData = await DefaultAssetBundle.of(context)
//       .load('assets/icons/innerspace_logo.png');
//   final Uint8List imageBytes = assetByteData.buffer.asUint8List();
//
//   // Decode the image to a codec
//   final ui.Codec codec = await ui.instantiateImageCodec(imageBytes,
//       targetWidth: 100); // Adjust targetWidth as needed
//   final ui.FrameInfo frameInfo = await codec.getNextFrame();
//
//   // Convert the frame to ByteData
//   final ByteData? frameByteData =
//   await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
//   final Uint8List markerBytes = frameByteData!.buffer.asUint8List();
//
//   // Create a BitmapDescriptor from the marker bytes
//   return BitmapDescriptor.fromBytes(markerBytes);
// }
