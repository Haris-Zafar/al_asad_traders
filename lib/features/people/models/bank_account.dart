import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
/// Model representing a bank account associated with profile, buyer, or supplier.
/// Rule: wholesale_relationships.md > BANK_ACCOUNT. Story: S10.
class BankAccount {
  /// Creates a [BankAccount] instance.
  const BankAccount({
    required this.id,
    this.profileId,
    this.buyerId,
    this.supplierId,
    required this.name,
    required this.accountNumber,
    this.notes,
    this.archivedAt,
    required this.createdAt,
  });

  /// Unique identifier of the bank account.
  final String id;

  /// Profile ID if owned by the business profile.
  final String? profileId;

  /// Buyer ID if owned by a buyer.
  final String? buyerId;

  /// Supplier ID if owned by a supplier.
  final String? supplierId;

  /// Bank name or account title.
  final String name;

  /// Account number or IBAN.
  final String accountNumber;

  /// Optional notes or remarks.
  final String? notes;

  /// Timestamp when bank account was archived (null if active).
  final DateTime? archivedAt;

  /// Timestamp when bank account record was created.
  final DateTime createdAt;

  /// Returns whether this bank account is archived.
  /// Rule: wholesale_project.md > Archiving. Story: S10.
  bool get isArchived => archivedAt != null;

  /// Validates that exactly one owner ID (profileId, buyerId, or supplierId) is set.
  /// Rule: docs/DATABASE.md > Collections (bankAccounts). Story: S10.
  bool get hasValidOwner {
    final owners = [
      profileId,
      buyerId,
      supplierId,
    ].where((id) => id != null && id.isNotEmpty);
    return owners.length == 1;
  }

  /// Deserializes a [BankAccount] from a Firestore document map.
  /// Rule: docs/DATABASE.md > Collections. Story: S10.
  factory BankAccount.fromMap(Map<String, dynamic> map, String id) {
    final Object? archived = map['archivedAt'];
    final Object? created = map['createdAt'];
    return BankAccount(
      id: id,
      profileId: map['profileId'] as String?,
      buyerId: map['buyerId'] as String?,
      supplierId: map['supplierId'] as String?,
      name: map['name'] as String? ?? '',
      accountNumber: map['accountNumber'] as String? ?? '',
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

  /// Serializes this [BankAccount] to a Firestore document map.
  /// Key set matches exact ERD fields required by security rules.
  /// Rule: docs/DATABASE.md > Field conventions. Story: S10.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'profileId': profileId,
      'buyerId': buyerId,
      'supplierId': supplierId,
      'name': name,
      'accountNumber': accountNumber,
      'notes': notes,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this [BankAccount] with updated fields.
  /// Rule: docs/ARCHITECTURE.md > Models. Story: S10.
  BankAccount copyWith({
    String? id,
    String? profileId,
    String? buyerId,
    String? supplierId,
    String? name,
    String? accountNumber,
    String? notes,
    DateTime? archivedAt,
    DateTime? createdAt,
  }) {
    return BankAccount(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      buyerId: buyerId ?? this.buyerId,
      supplierId: supplierId ?? this.supplierId,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      notes: notes ?? this.notes,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankAccount &&
        other.id == id &&
        other.profileId == profileId &&
        other.buyerId == buyerId &&
        other.supplierId == supplierId &&
        other.name == name &&
        other.accountNumber == accountNumber &&
        other.notes == notes &&
        other.archivedAt == archivedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    buyerId,
    supplierId,
    name,
    accountNumber,
    notes,
    archivedAt,
    createdAt,
  );
}
