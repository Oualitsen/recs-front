import 'package:flutter/material.dart';
import 'package:recs_front/src/utils/image_utils.dart';

class ImageWithOnlineCircleWidget extends StatelessWidget {
  final Widget child;
  final double? dimension;
  final String? imageUrl;
  const ImageWithOnlineCircleWidget({super.key, required this.child, this.dimension, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dimension ?? 40,
      height: dimension ?? 40,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            width: dimension ?? 40,
            child: ImageUtils.fromNetworkRounded(
              imageUrl,
              placeHolderWidget: ImageUtils.roundedAvatar(
                context: context,
                child: child,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
