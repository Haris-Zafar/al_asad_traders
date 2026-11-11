import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
/// Model representing a tag for categorizing products.
/// Rule: wholesale_project.md > Products. Story: S3.
class Tag {
  /// Creates a [Tag] instance.
  const Tag({required this.id, required this.name, required this.createdAt});

  /// Document ID (lowercase trimmed tag name).
  final String id;

  /// Display name of the tag.
  final String name;

  /// Timestamp when the tag was created.
  final DateTime createdAt;

  /// Deserializes a [Tag] from a Firestore document map.
  /// Rule: docs/DATABASE.md > Collections. Story: S3.
  factory Tag.fromMap(Map<String, dynamic> map, String id) {
    final Object? created = map['createdAt'];
    return Tag(
      id: id,
      name: map['name'] as String? ?? '',
      createdAt: created is Timestamp
          ? created.toDate()
          : (created is String
                ? DateTime.tryParse(created) ?? DateTime.now()
                : DateTime.now()),
    );
  }

  /// Serializes this [Tag] to a Firestore document map.
  /// Key set matches exact ERD fields required by security rules.
  /// Rule: docs/DATABASE.md > Field conventions. Story: S3.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this [Tag] with updated fields.
  /// Rule: docs/ARCHITECTURE.md > Models. Story: S3.
  Tag copyWith({String? id, String? name, DateTime? createdAt}) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
}
