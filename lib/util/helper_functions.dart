import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void showErrorNotification({
  String description = "description",
}) {
  showSimpleNotification(
    Text(
      description,
      maxLines: 2,
      style: TextStyle(
        color: Colors.white70,
      ),
    ),
    background: Colors.red.shade400,
    slideDismissDirection: DismissDirection.horizontal,
  );
}
