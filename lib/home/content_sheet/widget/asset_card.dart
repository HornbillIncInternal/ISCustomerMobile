import 'package:hb_booking_mobile_app/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/is_loader.dart';
import '../../model/model_assets.dart';
import '../../workspcae_detail/screen_workspacedetail.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({
    Key? key,
    required this.asset,
    required this.index,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedEndDate,
  }) : super(key: key);

  final Datum asset;
  final int index;
  final String? selectedDate;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final String? selectedEndDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryTextStyle =
    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final secondaryTextStyle = textTheme.titleMedium;
    final tertiaryTextStyle =
    textTheme.titleMedium?.copyWith(color: Colors.black54);
    print("ep--  ${asset.rate!.effectivePrice!}");

    // Image container with cached network image and office loader
    final image = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: asset.thumbnail?.path != null
            ? CachedNetworkImage(
          imageUrl: asset.thumbnail!.path!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[50],
            child: Center(
              child: CoworkingLoaders.progress(
                size: 30.0,
                value: null,
                text: null, // No text to keep it clean
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            : Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 8),
                Text(
                  'No image',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final rating = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: secondaryTextStyle?.color, size: 18),
        const SizedBox(width: 4),
        Text(
          asset.branch?.averageRating != null
              ? asset.branch!.averageRating!.toStringAsFixed(1)!.toString()
              : 'N/A',
          style: secondaryTextStyle,
        ),
      ],
    );

    final heading = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            capitalize(asset.familyTitle) ?? 'No Title',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: primaryTextStyle,
          ),
        ),
        const SizedBox(width: 8),
        rating,
      ],
    );

    final description = [
      if (asset.rate != null)
        Text(
          '\₹${asset.rate!.effectivePrice!.toStringAsFixed(2).toString()} total before taxes',
          style: secondaryTextStyle?.copyWith(
            decoration: TextDecoration.underline,
          ),
        )
    ];

    return InkWell(
      onTap: () {
        print("AssetCard navigation with:");
        print("selectedDate: $selectedDate");
        print("selectedStartTime: $selectedStartTime");
        print("selectedEndTime: $selectedEndTime");
        print("selectedEndDate: $selectedEndDate");

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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            const SizedBox(height: 16),
            heading,
            const SizedBox(height: 8),
            ...description,
          ],
        ),
      ),
    );
  }
}

// Helper function to capitalize the first letter of each word
String? capitalize(String? text) {
  if (text == null || text.isEmpty) return null;

  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/*
class AssetCard extends StatelessWidget {
  const AssetCard({
    Key? key,
    required this.asset,
    required this.index,
    this.isoStart,
    this.isoEnd,
  }) : super(key: key);

  final Datum asset; // Corrected to match the Datum type
  final int index;
  final String? isoStart;  // Add these parameters
  final String? isoEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryTextStyle =
    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final secondaryTextStyle = textTheme.titleMedium;
    final tertiaryTextStyle =
    textTheme.titleMedium?.copyWith(color: Colors.black54);

    final image = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: Image.network(
          asset.thumbnail?.path ?? 'https://via.placeholder.com/150', // Placeholder if thumbnail is null
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );

    final rating = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: secondaryTextStyle?.color, size: 18),
        const SizedBox(width: 4),
        Text(asset.branch?.averageRating.toStringAsFixed(1).toString() ?? 'N/A', style: secondaryTextStyle), // Handle null rating
      ],
    );

    final heading = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            capitalize(asset.familyTitle!) ?? 'No Title', // Handle null title
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: primaryTextStyle,
          ),
        ),
        const SizedBox(width: 8),
       rating,
      ],
    );

    final description = [
      // if (asset.price != null)
      //   // Only show if charge is not null
      //   Text(
      //     '\₹${asset.packages![0].rate} total before taxes',
      //     style: secondaryTextStyle?.copyWith(
      //       decoration: TextDecoration.underline,
      //     ),
      //   ),
    if (asset.rate != null)
    Text(
          '\₹${asset.rate.effectivePrice} total before taxes',
          style: secondaryTextStyle?.copyWith(
            decoration: TextDecoration.underline,
          ),)
    ];

    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           image,
            const SizedBox(height: 16),
           heading,
            const SizedBox(height: 8),
            ...description,
          ],
        ),
      ),
    );
  }
}*/

