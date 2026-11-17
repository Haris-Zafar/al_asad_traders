import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
/// Model representing a supplier-specific rate entry with an effective date.
/// Rule: wholesale_erd_v9.mermaid > SUPPLIER_RATE, wholesale_project.md > Prices. Story: S5.
class SupplierRate {
  /// Creates a [SupplierRate] instance.
  const SupplierRate({
    required this.id,
    required this.supplierId,
    required this.productId,
    required this.rate,
    required this.effectiveDate,
    required this.createdAt,
  });

  /// Unique identifier of the rate document (`supplierId_productId_effectiveDate`).
  final String id;

  /// Identifier of the supplier.
  final String supplierId;

  /// Identifier of the product.
  final String productId;

  /// Rate amount in Rupees.
  final int rate;

  /// Date string from which this rate is effective (`yyyy-MM-dd`).
  final String effectiveDate;

  /// Timestamp when this rate record was created.
  final DateTime createdAt;

  /// Generates the deterministic document ID for a supplier rate.
  static String buildDocId(
    String supplierId,
    String productId,
    String effectiveDate,
  ) =>
      '${supplierId}_${productId}_$effectiveDate';

  /// Creates a [SupplierRate] instance from a Firestore document snapshot.
  factory SupplierRate.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return SupplierRate.fromMap(doc.id, data);
  }

  /// Creates a [SupplierRate] instance from a Map data structure.
  factory SupplierRate.fromMap(String id, Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    final DateTime createdAtDate = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw is DateTime
            ? createdAtRaw
            : DateTime.now();

    return SupplierRate(
      id: id,
      supplierId: data['supplierId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      rate: (data['rate'] as num?)?.toInt() ?? 0,
      effectiveDate: data['effectiveDate'] as String? ?? '',
      createdAt: createdAtDate,
    );
  }

  /// Converts this model instance into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'supplierId': supplierId,
      'productId': productId,
      'rate': rate,
      'effectiveDate': effectiveDate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this [SupplierRate] with modified fields.
  SupplierRate copyWith({
    String? id,
    String? supplierId,
    String? productId,
    int? rate,
    String? effectiveDate,
    DateTime? createdAt,
  }) {
    return SupplierRate(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      productId: productId ?? this.productId,
      rate: rate ?? this.rate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierRate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          supplierId == other.supplierId &&
          productId == other.productId &&
          rate == other.rate &&
          effectiveDate == other.effectiveDate &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, supplierId, productId, rate, effectiveDate, createdAt);
}
