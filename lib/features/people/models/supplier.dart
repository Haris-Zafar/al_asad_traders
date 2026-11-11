import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
/// Model representing a supplier in the system.
/// Rule: wholesale_project.md > People and accounts. Story: S9.
class Supplier {
  /// Creates a [Supplier] instance.
  const Supplier({
    required this.id,
    required this.name,
    this.contactNumber,
    this.address,
    this.notes,
    this.archivedAt,
    required this.createdAt,
  });

  /// Unique identifier of the supplier.
  final String id;

  /// Supplier's display name.
  final String name;

  /// Optional contact phone number.
  final String? contactNumber;

  /// Optional physical address.
  final String? address;

  /// Optional notes or remarks.
  final String? notes;

  /// Timestamp when supplier was hidden/archived (null if active).
  final DateTime? archivedAt;

  /// Timestamp when supplier record was created.
  final DateTime createdAt;

  /// Returns whether this supplier is archived/hidden.
  /// Rule: wholesale_project.md > Archiving. Story: S9.
  bool get isArchived => archivedAt != null;

  /// Deserializes a [Supplier] from a Firestore document map.
  /// Rule: docs/DATABASE.md > Collections. Story: S9.
  factory Supplier.fromMap(Map<String, dynamic> map, String id) {
    final Object? archived = map['archivedAt'];
    final Object? created = map['createdAt'];
    return Supplier(
      id: id,
      name: map['name'] as String? ?? '',
      contactNumber: map['contactNumber'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      archivedAt: archived is Timestamp
          ? archived.toDate()
          : (archived is String ? DateTime.tryParse(archived) : null),
      createdAt: created is Timestamp
          ? created.toDate()
          : (created is String
                ? DateTime.tryParse(created) ?? DateTime.now()
                : DateTime.now()),
    );
  }

  /// Serializes this [Supplier] to a Firestore document map.
  /// Key set matches exact ERD fields required by security rules.
  /// Rule: docs/DATABASE.md > Field conventions. Story: S9.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'contactNumber': contactNumber,
      'address': address,
      'notes': notes,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this [Supplier] with updated fields.
  /// Rule: docs/ARCHITECTURE.md > Models. Story: S9.
  Supplier copyWith({
    String? id,
    String? name,
    String? contactNumber,
    String? address,
    String? notes,
    DateTime? archivedAt,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier &&
        other.id == id &&
        other.name == name &&
        other.contactNumber == contactNumber &&
        other.address == address &&
        other.notes == notes &&
        other.archivedAt == archivedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    contactNumber,
    address,
    notes,
    archivedAt,
    createdAt,
  );
}
