import 'package:flutter/material.dart';

Widget buildCustomImage(
  String url, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.network(
    url,
    height: height,
    width: width,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
