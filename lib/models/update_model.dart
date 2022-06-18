// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class UpdateModel {
  double version;
  String name;
  String description;
  List<String> changes;
  List<String> apks;

  UpdateModel({
    required this.version,
    required this.name,
    required this.description,
    required this.changes,
    required this.apks,
  });

  UpdateModel copyWith({
    double? version,
    String? name,
    String? description,
    List<String>? changes,
    List<String>? apks,
  }) {
    return UpdateModel(
      version: version ?? this.version,
      name: name ?? this.name,
      description: description ?? this.description,
      changes: changes ?? this.changes,
      apks: apks ?? this.apks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'version': version,
      'name': name,
      'description': description,
      'changes': changes,
      'apks': apks,
    };
  }

  factory UpdateModel.fromMap(Map<String, dynamic> map) {
    return UpdateModel(
      version: map['version'] as double,
      name: map['name'] as String,
      description: map['description'] as String,
      changes: List<String>.from(map['changes'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      apks: List<String>.from(
          (map['apks'] as List<dynamic>).map((e) => e.toString()).toList()),
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateModel.fromJson(String source) =>
      UpdateModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UpdateModel(version: $version, name: $name, description: $description, changes: $changes, apks: $apks)';
  }
}
