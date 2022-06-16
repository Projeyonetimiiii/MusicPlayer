import 'dart:convert';

class YoutubePlaylist {
  String? title;
  String? type;
  String? count;
  String? description;
  String? playlistId;
  String? firstItemId;
  String? videoId;
  String? image;
  String? imageMin;
  String? imageMedium;
  String? imageStandart;
  String? imageMax;
  YoutubePlaylist({
    this.title,
    this.type,
    this.count,
    this.description,
    this.playlistId,
    this.firstItemId,
    this.videoId,
    this.image,
    this.imageMin,
    this.imageMedium,
    this.imageStandart,
    this.imageMax,
  });

  bool get isChart => this.type == "chart";
  bool get isPlaylist => this.type == "playlist" || this.type == "chart";
  bool get isVideo => this.type == "video";

  String get getMaxQualityImageUrl {
    if (imageMax != null) {
      return imageMax!;
    } else if (imageMedium != null) {
      return imageMedium!;
    } else if (imageStandart != null) {
      return imageStandart!;
    } else if (image != null) {
      return image!;
    }
    return imageMin!;
  }

  String get getStandartImage {
    if (imageStandart != null) {
      return imageStandart!;
    }
    return getLowQualityImageUrl;
  }

  String get getNormalImage {
    if (image != null) {
      return image!;
    }
    return getLowQualityImageUrl;
  }

  String get getLowQualityImageUrl {
    if (imageMin != null) {
      return imageMin!;
    } else if (image != null) {
      return image!;
    } else if (imageStandart != null) {
      return imageStandart!;
    } else if (imageMedium != null) {
      return imageMedium!;
    }
    return imageMax!;
  }

  String imageQuality(bool maxQuality) {
    if (maxQuality) {
      return getMaxQualityImageUrl;
    } else {
      return getLowQualityImageUrl;
    }
  }

  YoutubePlaylist copyWith({
    String? title,
    String? type,
    String? count,
    String? description,
    String? playlistId,
    String? firstItemId,
    String? videoId,
    String? image,
    String? imageMin,
    String? imageMedium,
    String? imageStandart,
    String? imageMax,
  }) {
    return YoutubePlaylist(
      title: title ?? this.title,
      type: type ?? this.type,
      count: count ?? this.count,
      description: description ?? this.description,
      playlistId: playlistId ?? this.playlistId,
      firstItemId: firstItemId ?? this.firstItemId,
      videoId: videoId ?? this.videoId,
      image: image ?? this.image,
      imageMin: imageMin ?? this.imageMin,
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
      'videoId': videoId,
      'image': image,
      'imageMin': imageMin,
      'imageMedium': imageMedium,
      'imageStandart': imageStandart,
      'imageMax': imageMax,
    };
  }

  factory YoutubePlaylist.fromMap(Map<String, dynamic> map) {
    return YoutubePlaylist(
      title: map['title'],
      type: map['type'],
      count: map['count'],
      description: map['description'],
      playlistId: map['playlistId'],
      firstItemId: map['firstItemId'],
      videoId: map['videoId'],
      image: map['image'],
      imageMin: map['imageMin'],
      imageMedium: map['imageMedium'],
      imageStandart: map['imageStandart'],
      imageMax: map['imageMax'],
    );
  }

  String toJson() => json.encode(toMap());

  factory YoutubePlaylist.fromJson(String source) =>
      YoutubePlaylist.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MyPlaylist(title: $title, type: $type, count: $count, description: $description, playlistId: $playlistId, firstItemId: $firstItemId, videoId: $videoId, image: $image, imageMin: $imageMin, imageMedium: $imageMedium, imageStandart: $imageStandart, imageMax: $imageMax)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is YoutubePlaylist &&
        other.title == title &&
        other.type == type &&
        other.count == count &&
        other.description == description &&
        other.playlistId == playlistId &&
        other.firstItemId == firstItemId &&
        other.videoId == videoId &&
        other.image == image &&
        other.imageMin == imageMin &&
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
        videoId.hashCode ^
        image.hashCode ^
        imageMin.hashCode ^
        imageMedium.hashCode ^
        imageStandart.hashCode ^
        imageMax.hashCode;
  }
}
