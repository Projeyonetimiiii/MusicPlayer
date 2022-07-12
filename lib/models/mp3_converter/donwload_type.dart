// ignore_for_file: public_member_api_docs, sort_constructors_first
class DonwloadType {
  String url;
  AudioType type;
  DonwloadType({
    required this.url,
    required this.type,
  });
}

enum AudioType { mp3, m4a }
