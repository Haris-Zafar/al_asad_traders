import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
/// Model representing a buyer-specific rate entry with an effective date.
/// Rule: wholesale_erd_v9.mermaid > BUYER_RATE, wholesale_project.md > Prices. Story: S5.
class BuyerRate {
  /// Creates a [BuyerRate] instance.
  const BuyerRate({
    required this.id,
    required this.buyerId,
    required this.productId,
    required this.rate,
    required this.effectiveDate,
    required this.createdAt,
  });

  /// Unique identifier of the rate document (`buyerId_productId_effectiveDate`).
  final String id;

  /// Identifier of the buyer.
  final String buyerId;

  /// Identifier of the product.
  final String productId;

  /// Rate amount in Rupees.
  final int rate;

  /// Date string from which this rate is effective (`yyyy-MM-dd`).
  final String effectiveDate;

  /// Timestamp when this rate record was created.
  final DateTime createdAt;

  /// Generates the deterministic document ID for a buyer rate.
  static String buildDocId(
    String buyerId,
    String productId,
    String effectiveDate,
  ) => '${buyerId}_${productId}_$effectiveDate';

  /// Creates a [BuyerRate] instance from a Firestore document snapshot.
  factory BuyerRate.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return BuyerRate.fromMap(doc.id, data);
  }

  /// Creates a [BuyerRate] instance from a Map data structure.
  factory BuyerRate.fromMap(String id, Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    final DateTime createdAtDate = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw is DateTime
        ? createdAtRaw
        : DateTime.now();

    return BuyerRate(
      id: id,
      buyerId: data['buyerId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      rate: (data['rate'] as num?)?.toInt() ?? 0,
      effectiveDate: data['effectiveDate'] as String? ?? '',
      createdAt: createdAtDate,
    );
  }

  /// Converts this model instance into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'buyerId': buyerId,
      'productId': productId,
      'rate': rate,
      'effectiveDate': effectiveDate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this [BuyerRate] with modified fields.
  BuyerRate copyWith({
    String? id,
    String? buyerId,
    String? productId,
    int? rate,
    String? effectiveDate,
    DateTime? createdAt,
  }) {
    return BuyerRate(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      productId: productId ?? this.productId,
      rate: rate ?? this.rate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuyerRate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          buyerId == other.buyerId &&
          productId == other.productId &&
          rate == other.rate &&
          effectiveDate == other.effectiveDate &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, buyerId, productId, rate, effectiveDate, createdAt);
}
