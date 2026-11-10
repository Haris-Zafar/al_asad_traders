import 'package:flutter/foundation.dart';

@immutable
/// Represents the wholesale business owner's profile.
/// Rule: wholesale_project.md > People and accounts. Story: S11.
class Profile {
  /// Creates a [Profile] instance.
  const Profile({
    required this.id,
    required this.businessName,
    required this.businessAddress,
    required this.contactNumber1,
    this.contactNumber2,
  });

  /// Document ID, always 'main'.
  final String id;

  /// Business name.
  final String businessName;

  /// Business address.
  final String businessAddress;

  /// Primary contact number.
  final String contactNumber1;

  /// Secondary contact number (optional).
  final String? contactNumber2;

  /// Creates a [Profile] from Firestore document map.
  /// Rule: docs/DATABASE.md > Collections. Story: S11.
  factory Profile.fromMap(Map<String, dynamic> map, String id) {
    return Profile(
      id: id,
      businessName: map['businessName'] as String? ?? '',
      businessAddress: map['businessAddress'] as String? ?? '',
      contactNumber1: map['contactNumber1'] as String? ?? '',
      contactNumber2: map['contactNumber2'] as String?,
    );
  }

  /// Converts this [Profile] to a Firestore document map.
  /// Rule: docs/DATABASE.md > Collections. Story: S11.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'businessName': businessName,
      'businessAddress': businessAddress,
      'contactNumber1': contactNumber1,
      'contactNumber2': contactNumber2,
    };
  }

  /// Creates a copy of this [Profile] with optional updated fields.
  /// Rule: docs/ARCHITECTURE.md > Models. Story: S11.
  Profile copyWith({
    String? id,
    String? businessName,
    String? businessAddress,
    String? contactNumber1,
    String? contactNumber2,
  }) {
    return Profile(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      contactNumber1: contactNumber1 ?? this.contactNumber1,
      contactNumber2: contactNumber2 ?? this.contactNumber2,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.id == id &&
        other.businessName == businessName &&
        other.businessAddress == businessAddress &&
        other.contactNumber1 == contactNumber1 &&
        other.contactNumber2 == contactNumber2;
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessName,
    businessAddress,
    contactNumber1,
    contactNumber2,
  );
}
