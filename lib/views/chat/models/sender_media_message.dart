import 'package:onlinemusic/models/media_reference.dart';
import 'package:onlinemusic/util/enums.dart';

class SenderMediaMessage {
  final List<MediaReference?>? refs;
  final String? message;
  final ChatMessageType? type;
  SenderMediaMessage({
    this.refs,
    this.message,
    this.type,
  });
}
