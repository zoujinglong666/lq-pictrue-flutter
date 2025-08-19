/// @author: jiangjunhui
/// @date: 2025/1/6
library;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'cache_image_manager.dart';



class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final CachedNetworkImageProvider? imageProvider;
  final void Function(Image image, String imageUrl)? onSuccess;
  final void Function(Object error, String imageUrl)? onError;


  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.imageProvider,
    this.onSuccess,
    this.onError,
  });





  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager:MyCustomCacheManager(),
      placeholder: (context, url) =>
          placeholder ?? Container(color: Colors.grey[300]),
      errorWidget: (context, url, error) {
        return  errorWidget ?? const Icon(Icons.error);
      },
      width: width,
      height: height,
      fit: fit,
      imageBuilder: (context, imageProvider) {
        final image = Image(
          image: imageProvider ?? CachedNetworkImageProvider(imageUrl),
          fit: fit,
          width: width,
          height: height,
        );
        if (onSuccess != null) {
          onSuccess!(image,imageUrl);
        }
        return image;
      },
      errorListener: (error) {
         if (onError != null) {
           onError!(error,imageUrl);
         }
      },
    );
  }
}
