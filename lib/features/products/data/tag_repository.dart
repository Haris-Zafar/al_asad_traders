import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/products/models/product_tag.dart';
import 'package:al_asad_traders/features/products/models/tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [TagRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S3.
final Provider<TagRepository> tagRepositoryProvider = Provider<TagRepository>((
  ref,
) {
  return TagRepository(FirebaseFirestore.instance);
});

/// Repository for tags and product-tag relations in Firestore.
/// Rule: docs/ARCHITECTURE.md > Layers. Story: S3.
class TagRepository {
  /// Creates a [TagRepository] with the given [firestore] instance.
  TagRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tagsRef =>
      _firestore.collection('tags');

  CollectionReference<Map<String, dynamic>> get _productTagsRef =>
      _firestore.collection('productTags');

  /// Stream of all tags in the system.
  /// Rule: docs/DATABASE.md > Collections (tags). Story: S3.
  Stream<List<Tag>> watchTags() {
    return _tagsRef.snapshots().map((snapshot) {
      final tags = snapshot.docs
          .map((doc) => Tag.fromMap(doc.data(), doc.id))
          .toList();
      tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return tags;
    });
  }

  /// Stream of all product-tag links.
  /// Rule: docs/DATABASE.md > Collections (productTags). Story: S3.
  Stream<List<ProductTag>> watchProductTags() {
    return _productTagsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductTag.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Stream of tag IDs associated with a specific product.
  /// Rule: wholesale_project.md > Products. Story: S3.
  Stream<List<String>> watchTagsForProduct(String productId) {
    return _productTagsRef
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data()['tagId'] as String? ?? '')
              .where((id) => id.isNotEmpty)
              .toList();
        });
  }

  /// Creates or ensures a tag with [name] exists.
  /// Rule: wholesale_project.md > Uniqueness (TAG: lowercase name). Story: S3.
  Future<Tag> createTag(String name) async {
    try {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        throw const ValidationException('Tag name cannot be empty');
      }

      final tagId = trimmedName.toLowerCase();
      final docRef = _tagsRef.doc(tagId);
      final docSnap = await docRef.get();

      if (docSnap.exists && docSnap.data() != null) {
        return Tag.fromMap(docSnap.data()!, tagId);
      }

      final newTag = Tag(
        id: tagId,
        name: trimmedName,
        createdAt: DateTime.now(),
      );

      await docRef.set(newTag.toMap());
      return newTag;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Updates the tags assigned to a specific [productId].
  /// ID format: `productId_tagId`.
  /// Rule: wholesale_project.md > Uniqueness (PRODUCT_TAG: productId_tagId). Story: S3.
  Future<void> assignTagsToProduct(
    String productId,
    List<String> tagIds,
  ) async {
    try {
      if (productId.isEmpty) {
        throw const ValidationException('Product ID cannot be empty');
      }

      final existingSnap = await _productTagsRef
          .where('productId', isEqualTo: productId)
          .get();

      final existingTagIds = existingSnap.docs
          .map((doc) => doc.data()['tagId'] as String? ?? '')
          .toSet();

      final targetTagIds = tagIds.toSet();

      final toAdd = targetTagIds.difference(existingTagIds);
      final toRemove = existingTagIds.difference(targetTagIds);

      final batch = _firestore.batch();

      for (final tagId in toAdd) {
        final docId = '${productId}_$tagId';
        final productTag = ProductTag(
          id: docId,
          productId: productId,
          tagId: tagId,
        );
        batch.set(_productTagsRef.doc(docId), productTag.toMap());
      }

      for (final tagId in toRemove) {
        final docId = '${productId}_$tagId';
        batch.delete(_productTagsRef.doc(docId));
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  AppException _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const PermissionException(AppStrings.errorPleaseLogInAgain);
      case 'unavailable':
      case 'network-request-failed':
        return const UnavailableException(AppStrings.errorInternetNeeded);
      default:
        return UnknownException(AppStrings.errorGeneric, e);
    }
  }
}
