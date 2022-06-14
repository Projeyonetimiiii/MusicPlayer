import 'package:onlinemusic/widgets/my_overlay_notification.dart';

void showErrorNotification({
  String description = "description",
}) {
  showMyOverlayNotification(
    message: description,
    isDismissible: true,
    duration: Duration(seconds: 2),
  );
}
