import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildCustomImage(
  String url, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  final String viewType = 'img_${url.hashCode}_${height.hashCode}_${width.hashCode}';

  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = fit == BoxFit.cover ? 'cover' : 'contain';
      return img;
    },
  );

  return SizedBox(
    height: height,
    width: width,
    child: HtmlElementView(viewType: viewType),
  );
}
