import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImageDismissibleWidget extends StatelessWidget {
  final ValueChanged<DismissDirection>? onDismissed;
  final bool? isSelected;
  final PlatformFile? file;
  const ImageDismissibleWidget(
      {Key? key, this.onDismissed, this.isSelected, this.file})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.up,
      background: Container(
        child: Center(
          child: Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: onDismissed,
      key: Key(file!.path!),
      child: Container(
        width: 50,
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected!
                ? Colors.black.withOpacity(0.9)
                : Colors.transparent,
          ),
          image: DecorationImage(
              fit: BoxFit.cover, image: FileImage(File(file!.path!))),
        ),
      ),
    );
  }
}
