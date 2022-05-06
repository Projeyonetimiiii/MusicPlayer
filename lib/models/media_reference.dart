import 'dart:convert';

class MediaReference {
  // silmek için kullanılacak referans
  final String? ref;

  // firebase deki dosya url'i
  final String? downloadURL;
  MediaReference({
    required this.ref,
    required this.downloadURL,
  });

  MediaReference copyWith({
    String? ref,
    String? downloadURL,
  }) {
    return MediaReference(
      ref: ref ?? this.ref,
      downloadURL: downloadURL ?? this.downloadURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ref': ref,
      'downloadURL': downloadURL,
    };
  }

  factory MediaReference.fromMap(Map<String, dynamic> map) {
    return MediaReference(
      ref: map['ref'],
      downloadURL: map['downloadURL'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaReference.fromJson(String source) =>
      MediaReference.fromMap(json.decode(source));

  @override
  String toString() => 'MediaReference(ref: $ref, downloadURL: $downloadURL)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MediaReference &&
        other.ref == ref &&
        other.downloadURL == downloadURL;
  }

  @override
  int get hashCode => ref.hashCode ^ downloadURL.hashCode;
}
