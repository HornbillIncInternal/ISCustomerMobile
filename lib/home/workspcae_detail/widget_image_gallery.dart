import 'package:hb_booking_mobile_app/home/model/model_assets.dart';
import 'package:flutter/material.dart';

class ImageGalleryScreen extends StatelessWidget {
  final List<DataImage> images;
  final int initialIndex;

  const ImageGalleryScreen({
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text("Gallery"),
      ),
      body: ListView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Image.network(
                images[index].path!,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
