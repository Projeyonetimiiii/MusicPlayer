import 'dart:convert';

class BlockedDetails {
  DateTime blockedTime;
  String blockedUid;
  BlockedDetails({
    required this.blockedTime,
    required this.blockedUid,
  });

  BlockedDetails copyWith({
    DateTime? blockedTime,
    String? blockedUid,
  }) {
    return BlockedDetails(
      blockedTime: blockedTime ?? this.blockedTime,
      blockedUid: blockedUid ?? this.blockedUid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'blockedTime': blockedTime.millisecondsSinceEpoch,
      'blockedUid': blockedUid,
    };
  }

  factory BlockedDetails.fromMap(Map<String, dynamic> map) {
    return BlockedDetails(
      blockedTime:
          DateTime.fromMillisecondsSinceEpoch(map['blockedTime'] as int),
      blockedUid: map['blockedUid'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BlockedDetails.fromJson(String source) =>
      BlockedDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'BlockedDetails(blockedTime: $blockedTime, blockedUid: $blockedUid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BlockedDetails &&
        other.blockedTime == blockedTime &&
        other.blockedUid == blockedUid;
  }

  @override
  int get hashCode => blockedTime.hashCode ^ blockedUid.hashCode;
}
