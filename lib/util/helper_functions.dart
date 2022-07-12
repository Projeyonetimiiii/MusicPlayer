import 'package:audio_service/audio_service.dart';
import 'package:onlinemusic/widgets/my_overlay_notification.dart';
import 'package:onlinemusic/widgets/short_popupbutton.dart';

void showErrorNotification({
  String description = "description",
}) {
  showMessage(
    message: description,
  );
}

List<MediaItem> sortItems(
    List<MediaItem> items, SortType sortType, OrderType orderType) {
  switch (sortType) {
    case SortType.Name:
      items.sort((a, b) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
      break;
    case SortType.DateAdded:
      items.sort((a, b) {
        return (a.extras!["dateAdded"] ?? 0)
            .compareTo(b.extras!["dateAdded"] ?? 0);
      });
      break;
    case SortType.Album:
      items.sort((a, b) {
        return (a.album ?? "")
            .toLowerCase()
            .compareTo((b.album ?? "").toLowerCase());
      });
      break;
    case SortType.Artist:
      items.sort((a, b) {
        return (a.artist ?? "")
            .toLowerCase()
            .compareTo((b.artist ?? "").toLowerCase());
      });
      break;
    case SortType.Time:
      items.sort((a, b) {
        return (a.duration?.inMilliseconds ?? 0)
            .compareTo(b.duration?.inMilliseconds ?? 0);
      });
      break;
    case SortType.DownloadTime:
      items.sort((a, b) {
        return (a.extras!["downloadTime"] ?? 0)
            .compareTo(b.extras!["downloadTime"] ?? 0);
      });
      break;
    default:
  }

  if (orderType == OrderType.Descending) {
    items = items.reversed.toList();
  }

  return items;
}
