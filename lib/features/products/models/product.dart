import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

const Object _sentinel = Object();

@immutable
/// Model representing a product in the system.
/// Rule: wholesale_project.md > Products. Story: S1, S4.
class Product {
  /// Creates a [Product] instance.
  const Product({
    required this.id,
    required this.name,
    this.sku,
    required this.defaultSupplierRate,
    required this.defaultBuyerRate,
    required this.defaultRetailPrice,
    this.notes,
    this.archivedAt,
    required this.createdAt,
  });

  /// Unique identifier of the product.
  final String id;

  /// Product's display name.
  final String name;

  /// Optional barcode (SKU).
  final String? sku;

  /// Default supplier rate (buying price).
  final int defaultSupplierRate;

  /// Default buyer rate (selling price).
  final int defaultBuyerRate;

  /// Default retail price (shop price).
  final int defaultRetailPrice;

  /// Optional notes or remarks.
  final String? notes;

  /// Timestamp when product was hidden/archived (null if active).
  final DateTime? archivedAt;

  /// Timestamp when product record was created.
  final DateTime createdAt;

  /// Returns whether this product is archived/hidden.
  /// Rule: wholesale_project.md > Archiving. Story: S4.
  bool get isArchived => archivedAt != null;

  /// Deserializes a [Product] from a Firestore document map.
  /// Rule: docs/DATABASE.md > Collections. Story: S1.
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    final Object? archived = map['archivedAt'];
    final Object? created = map['createdAt'];
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      sku: map['sku'] as String?,
      defaultSupplierRate: (map['defaultSupplierRate'] as num?)?.toInt() ?? 0,
      defaultBuyerRate: (map['defaultBuyerRate'] as num?)?.toInt() ?? 0,
      defaultRetailPrice: (map['defaultRetailPrice'] as num?)?.toInt() ?? 0,
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

  /// Serializes this [Product] to a Firestore document map.
  /// Key set matches exact ERD fields required by security rules.
  /// Rule: docs/DATABASE.md > Field conventions. Story: S1.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'sku': sku,
      'defaultSupplierRate': defaultSupplierRate,
      'defaultBuyerRate': defaultBuyerRate,
      'defaultRetailPrice': defaultRetailPrice,
      'notes': notes,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this [Product] with updated fields.
  /// Rule: docs/ARCHITECTURE.md > Models. Story: S1.
  Product copyWith({
    String? id,
    String? name,
    Object? sku = _sentinel,
    int? defaultSupplierRate,
    int? defaultBuyerRate,
    int? defaultRetailPrice,
    Object? notes = _sentinel,
    Object? archivedAt = _sentinel,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku == _sentinel ? this.sku : (sku as String?),
      defaultSupplierRate: defaultSupplierRate ?? this.defaultSupplierRate,
      defaultBuyerRate: defaultBuyerRate ?? this.defaultBuyerRate,
      defaultRetailPrice: defaultRetailPrice ?? this.defaultRetailPrice,
      notes: notes == _sentinel ? this.notes : (notes as String?),
      archivedAt: archivedAt == _sentinel ? this.archivedAt : (archivedAt as DateTime?),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.sku == sku &&
        other.defaultSupplierRate == defaultSupplierRate &&
        other.defaultBuyerRate == defaultBuyerRate &&
        other.defaultRetailPrice == defaultRetailPrice &&
        other.notes == notes &&
        other.archivedAt == archivedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sku,
    defaultSupplierRate,
    defaultBuyerRate,
    defaultRetailPrice,
    notes,
    archivedAt,
    createdAt,
  );
}
