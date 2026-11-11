import 'package:flutter/foundation.dart';

@immutable
/// Model representing the composite link between a product and a tag.
/// Rule: wholesale_project.md > Products, Uniqueness. Story: S3.
class ProductTag {
  /// Creates a [ProductTag] instance.
  const ProductTag({
    required this.id,
    required this.productId,
    required this.tagId,
  });

  /// Document ID in format `productId_tagId`.
  final String id;

  /// ID of the product.
  final String productId;

  /// ID of the tag.
  final String tagId;

  /// Deserializes a [ProductTag] from a Firestore document map.
  /// Rule: docs/DATABASE.md > Collections. Story: S3.
  factory ProductTag.fromMap(Map<String, dynamic> map, String id) {
    return ProductTag(
      id: id,
      productId: map['productId'] as String? ?? '',
      tagId: map['tagId'] as String? ?? '',
    );
  }

  /// Serializes this [ProductTag] to a Firestore document map.
  /// Key set matches exact ERD fields required by security rules.
  /// Rule: docs/DATABASE.md > Field conventions. Story: S3.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'productId': productId, 'tagId': tagId};
  }

  /// Creates a copy of this [ProductTag] with updated fields.
  /// Rule: docs/ARCHITECTURE.md > Models. Story: S3.
  ProductTag copyWith({String? id, String? productId, String? tagId}) {
    return ProductTag(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      tagId: tagId ?? this.tagId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductTag &&
        other.id == id &&
        other.productId == productId &&
        other.tagId == tagId;
  }

  @override
  int get hashCode => Object.hash(id, productId, tagId);
}
