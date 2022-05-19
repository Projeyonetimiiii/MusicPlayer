import 'dart:convert';

class QualityImage {
  String maxQualityImageUrl;
  String lowQualityImageUrl;
  QualityImage({
    required this.maxQualityImageUrl,
    required this.lowQualityImageUrl,
  });

  factory QualityImage.fromUrl(String url) {
    return QualityImage(maxQualityImageUrl: url, lowQualityImageUrl: url);
  }

  QualityImage copyWith({
    String? maxQualityImageUrl,
    String? lowQualityImageUrl,
  }) {
    return QualityImage(
      maxQualityImageUrl: maxQualityImageUrl ?? this.maxQualityImageUrl,
      lowQualityImageUrl: lowQualityImageUrl ?? this.lowQualityImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maxQualityImageUrl': maxQualityImageUrl,
      'lowQualityImageUrl': lowQualityImageUrl,
    };
  }

  factory QualityImage.fromMap(Map<String, dynamic> map) {
    return QualityImage(
      maxQualityImageUrl: map['maxQualityImageUrl'] ?? '',
      lowQualityImageUrl: map['lowQualityImageUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory QualityImage.fromJson(String source) =>
      QualityImage.fromMap(json.decode(source));

  @override
  String toString() =>
      'QualityImage(maxQualityImageUrl: $maxQualityImageUrl, lowQualityImageUrl: $lowQualityImageUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QualityImage &&
        other.maxQualityImageUrl == maxQualityImageUrl &&
        other.lowQualityImageUrl == lowQualityImageUrl;
  }

  @override
  int get hashCode => maxQualityImageUrl.hashCode ^ lowQualityImageUrl.hashCode;
}
