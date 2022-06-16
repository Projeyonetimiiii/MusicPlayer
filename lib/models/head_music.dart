import 'dart:convert';

class HeadMusic {
  String? title;
  String? type;
  String? count;
  String? description;
  String? playlistId;
  String? firstItemId;
  String? image;
  String? imageMedium;
  String? imageStandart;
  String? imageMax;
  HeadMusic({
    this.title,
    this.type,
    this.count,
    this.description,
    this.playlistId,
    this.firstItemId,
    this.image,
    this.imageMedium,
    this.imageStandart,
    this.imageMax,
  });

  HeadMusic copyWith({
    String? title,
    String? type,
    String? count,
    String? description,
    String? playlistId,
    String? firstItemId,
    String? image,
    String? imageMedium,
    String? imageStandart,
    String? imageMax,
  }) {
    return HeadMusic(
      title: title ?? this.title,
      type: type ?? this.type,
      count: count ?? this.count,
      description: description ?? this.description,
      playlistId: playlistId ?? this.playlistId,
      firstItemId: firstItemId ?? this.firstItemId,
      image: image ?? this.image,
      imageMedium: imageMedium ?? this.imageMedium,
      imageStandart: imageStandart ?? this.imageStandart,
      imageMax: imageMax ?? this.imageMax,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'count': count,
      'description': description,
      'playlistId': playlistId,
      'firstItemId': firstItemId,
      'image': image,
      'imageMedium': imageMedium,
      'imageStandart': imageStandart,
      'imageMax': imageMax,
    };
  }

  factory HeadMusic.fromMap(Map<String, dynamic> map) {
    return HeadMusic(
      title: map['title'],
      type: map['type'],
      count: map['count'],
      description: map['description'],
      playlistId: map['playlistId'],
      firstItemId: map['firstItemId'],
      image: map['image'],
      imageMedium: map['imageMedium'],
      imageStandart: map['imageStandart'],
      imageMax: map['imageMax'],
    );
  }

  String toJson() => json.encode(toMap());

  factory HeadMusic.fromJson(String source) =>
      HeadMusic.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HeadMusic(title: $title, type: $type, count: $count, description: $description, playlistId: $playlistId, firstItemId: $firstItemId, image: $image, imageMedium: $imageMedium, imageStandart: $imageStandart, imageMax: $imageMax)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HeadMusic &&
        other.title == title &&
        other.type == type &&
        other.count == count &&
        other.description == description &&
        other.playlistId == playlistId &&
        other.firstItemId == firstItemId &&
        other.image == image &&
        other.imageMedium == imageMedium &&
        other.imageStandart == imageStandart &&
        other.imageMax == imageMax;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        type.hashCode ^
        count.hashCode ^
        description.hashCode ^
        playlistId.hashCode ^
        firstItemId.hashCode ^
        image.hashCode ^
        imageMedium.hashCode ^
        imageStandart.hashCode ^
        imageMax.hashCode;
  }

  String get getMaxImageQuality {
    if (imageMax != null) {
      return imageMax!;
    }
    if (imageMedium != null) {
      return imageMedium!;
    }
    if (imageStandart != null) {
      return imageStandart!;
    }
    return image!;
  }

  String get getLowImageQuality {
    if (image != null) {
      return image!;
    }
    if (imageStandart != null) {
      return imageStandart!;
    }
    if (imageMedium != null) {
      return imageMedium!;
    }
    return imageMax!;
  }

  String get getNormalImage {
    if (image != null) {
      return image!;
    }
    return getLowImageQuality;
  }

  String imageQuality(bool maxQuality) {
    if (maxQuality) {
      return getMaxImageQuality;
    } else {
      return getLowImageQuality;
    }
  }
}
