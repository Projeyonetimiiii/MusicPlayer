// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class UpdateModel {
  double version;
  String? title;
  String name;
  String description;
  List<String> changes;
  List<String> apks;
  List<String> sizes;

  UpdateModel({
    required this.version,
    this.title,
    required this.name,
    required this.description,
    required this.changes,
    required this.apks,
    required this.sizes,
  });

  UpdateModel copyWith({
    double? version,
    String? title,
    String? name,
    String? description,
    List<String>? changes,
    List<String>? apks,
    List<String>? sizes,
  }) {
    return UpdateModel(
      version: version ?? this.version,
      title: title ?? this.title,
      name: name ?? this.name,
      description: description ?? this.description,
      changes: changes ?? this.changes,
      apks: apks ?? this.apks,
      sizes: sizes ?? this.sizes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'version': version,
      'title': title,
      'name': name,
      'description': description,
      'changes': changes,
      'apks': apks,
      'sizes': sizes,
    };
  }

  String toJson() => json.encode(toMap());

  factory UpdateModel.fromJson(String source) =>
      UpdateModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UpdateModel(version: $version, title: $title, name: $name, description: $description, changes: $changes, apks: $apks, sizes: $sizes)';
  }

  factory UpdateModel.fromMap(Map<String, dynamic> map) {
    return UpdateModel(
      version: map['version'] as double,
      title: map['title'] != null ? map['title'] as String : null,
      name: map['name'] as String,
      description: map['description'] as String,
      changes: List<String>.from(map['changes'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      apks: map['apks'] == null
          ? []
          : List<String>.from(
              (map['apks'] as List<dynamic>).map((e) => e.toString()).toList()),
      sizes: map['sizes'] == null
          ? []
          : List<String>.from((map['sizes'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()),
    );
  }

  List<ApkInfo> get apkInfos {
    List<ApkInfo> infos = [];
    if (apks.length == sizes.length) {
      for (var i = 0; i < apks.length; i++) {
        infos.add(ApkInfo(name: apks[i].toString(), size: sizes[i]));
      }
    } else {
      for (var i = 0; i < apks.length; i++) {
        infos.add(ApkInfo(name: apks[i].toString()));
      }
    }

    return infos;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpdateModel &&
        other.version == version &&
        other.title == title &&
        other.name == name &&
        other.description == description &&
        listEquals(other.changes, changes) &&
        listEquals(other.apks, apks) &&
        listEquals(other.sizes, sizes);
  }

  @override
  int get hashCode {
    return version.hashCode ^
        title.hashCode ^
        name.hashCode ^
        description.hashCode ^
        changes.hashCode ^
        apks.hashCode ^
        sizes.hashCode;
  }
}

class ApkInfo {
  String name;
  String? size;
  ApkInfo({
    required this.name,
    this.size,
  });

  ApkInfo copyWith({
    String? name,
    String? size,
  }) {
    return ApkInfo(
      name: name ?? this.name,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'size': size,
    };
  }

  factory ApkInfo.fromMap(Map map) {
    return ApkInfo(
      name: map['name'] as String,
      size: map['size'] != null ? map['size'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApkInfo.fromJson(String source) =>
      ApkInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ApkInfo(name: $name, size: $size)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApkInfo && other.name == name && other.size == size;
  }

  @override
  int get hashCode => name.hashCode ^ size.hashCode;
}
