import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
/// Model representing a retail price history entry with an effective date.
/// Rule: wholesale_erd_v9.mermaid > RETAIL_PRICE, wholesale_project.md > Prices. Story: S6.
class RetailPrice {
  /// Creates a [RetailPrice] instance.
  const RetailPrice({
    required this.id,
    required this.productId,
    required this.price,
    required this.effectiveDate,
    required this.createdAt,
  });

  /// Unique identifier of the retail price document (`productId_effectiveDate`).
  final String id;

  /// Identifier of the product.
  final String productId;

  /// Price amount in Rupees.
  final int price;

  /// Date string from which this price is effective (`yyyy-MM-dd`).
  final String effectiveDate;

  /// Timestamp when this retail price record was created.
  final DateTime createdAt;

  /// Generates the deterministic document ID for a retail price.
  static String buildDocId(String productId, String effectiveDate) =>
      '${productId}_$effectiveDate';

  /// Creates a [RetailPrice] instance from a Firestore document snapshot.
  factory RetailPrice.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return RetailPrice.fromMap(doc.id, data);
  }

  /// Creates a [RetailPrice] instance from a Map data structure.
  factory RetailPrice.fromMap(String id, Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    final DateTime createdAtDate = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw is DateTime
        ? createdAtRaw
        : DateTime.now();

    return RetailPrice(
      id: id,
      productId: data['productId'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      effectiveDate: data['effectiveDate'] as String? ?? '',
      createdAt: createdAtDate,
    );
  }

  /// Converts this model instance into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'price': price,
      'effectiveDate': effectiveDate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this [RetailPrice] with modified fields.
  RetailPrice copyWith({
    String? id,
    String? productId,
    int? price,
    String? effectiveDate,
    DateTime? createdAt,
  }) {
    return RetailPrice(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetailPrice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          price == other.price &&
          effectiveDate == other.effectiveDate &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, productId, price, effectiveDate, createdAt);
}
