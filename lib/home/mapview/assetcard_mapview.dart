import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:hb_booking_mobile_app/home/workspcae_detail/screen_workspacedetail.dart';
import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:flutter/material.dart';



class AssetCard extends StatelessWidget {
  final Datum asset;
  final VoidCallback onClose;
  final int index;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  const AssetCard({
    Key? key,
    required this.asset,
    required this.onClose,
    required this.index,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  // Helper method to combine date and time into ISO string for WorkspaceDetailScreen
  String? _combineDateTime(String? date, String? time) {
    if (date == null) return null;

    if (time != null) {
      // Combine date and time into ISO format
      return '${date}T$time';
    } else {
      // Return just the date if no time specified
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkspaceDetailScreen(
              apiResponse: asset,
              index: index,
              // Pass separate date/time parameters as-is (null times will remain null)
              selectedDate: selectedDate,
              selectedStartTime: selectedStartTime, // Can be null
              selectedEndTime: selectedEndTime,     // Can be null
              selectedEndDate: selectedEndDate,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  asset.thumbnail!.path!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.close, size: 20, color: Colors.white),
                    onPressed: onClose,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    capitalize(asset.familyTitle!),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Rating: ${asset.branch!.averageRating!.toStringAsFixed(1).toString()}'),
                      SizedBox(width: 8),
                      Text('Price: \₹${asset.rate!.effectivePrice!.toStringAsFixed(2).toString()}')
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function for text capitalization (if not already defined elsewhere)
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/*
class AssetCard extends StatelessWidget {
  final Datum asset;
  final VoidCallback onClose;
  final int index;
  final String? isoStart;  // Add these parameters
  final String? isoEnd;
  const AssetCard({
    required this.asset,
    required this.onClose,
    required this.index, this.isoStart, this.isoEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkspaceDetailScreen(
              apiResponse: asset,
              index: index,
              isoStart: isoStart, // Pass the dates here
              isoEnd: isoEnd,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  asset.thumbnail!.path!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.close, size: 20, color: Colors.white),
                    onPressed: onClose,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    capitalize(asset.familyTitle!),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [

                      Text('Rating: ${asset.branch!.averageRating!.toStringAsFixed(1).toString()}'),
                      SizedBox(width: 8),
                      Text('Price: \₹${ asset.rate!.effectivePrice!.toStringAsFixed(2).toString()}')


                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
