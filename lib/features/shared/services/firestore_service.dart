import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/link_item.dart';
import '../models/category.dart';

/// Service for Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ====== Links ======

  /// Get user's links collection reference
  CollectionReference _userLinksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('links');
  }

  /// Stream of user's links (ordered by most recent)
  Stream<List<LinkItem>> getUserLinks(String userId) {
    return _userLinksCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LinkItem.fromFirestore(doc))
            .toList());
  }

  /// Stream of user's favorite links
  Stream<List<LinkItem>> getFavoriteLinks(String userId) {
    // Avoid requiring a composite index by removing server-side orderBy.
    // We sort client-side by createdAt descending after fetching favorites.
    return _userLinksCollection(userId)
        .where('favorite', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => LinkItem.fromFirestore(doc))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  /// Stream of links by category
  Stream<List<LinkItem>> getLinksByCategory(String userId, String categoryId) {
    // Avoid requiring a composite index by removing server-side orderBy.
    // We sort client-side by createdAt descending after filtering by category.
    return _userLinksCollection(userId)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => LinkItem.fromFirestore(doc))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  /// Add a new link
  Future<void> addLink(String userId, LinkItem link) async {
    await _userLinksCollection(userId).add(link.toFirestore());
  }

  /// Update an existing link
  Future<void> updateLink(String userId, LinkItem link) async {
    await _userLinksCollection(userId).doc(link.id).update(link.toFirestore());
  }

  /// Delete a link
  Future<void> deleteLink(String userId, String linkId) async {
    await _userLinksCollection(userId).doc(linkId).delete();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String userId, String linkId, bool favorite) async {
    await _userLinksCollection(userId).doc(linkId).update({'favorite': favorite});
  }

  // ====== Categories ======

  /// Get user's categories collection reference
  CollectionReference _userCategoriesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  /// Stream of user's categories
  Stream<List<Category>> getUserCategories(String userId) {
    return _userCategoriesCollection(userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  /// Add a new category
  Future<String> addCategory(String userId, String name) async {
    final docRef = await _userCategoriesCollection(userId).add({
      'name': name,
      'createdAt': Timestamp.now(),
    });
    return docRef.id;
  }

  /// Update category name
  Future<void> updateCategory(String userId, String categoryId, String name) async {
    await _userCategoriesCollection(userId).doc(categoryId).update({'name': name});
  }

  /// Delete a category
  Future<void> deleteCategory(String userId, String categoryId) async {
    // Remove category from links first
    final linksSnapshot = await _userLinksCollection(userId)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    
    for (var doc in linksSnapshot.docs) {
      await doc.reference.update({'categoryId': null});
    }
    
    // Delete category
    await _userCategoriesCollection(userId).doc(categoryId).delete();
  }

  // ====== Notepad ======

  /// Get notepad content
  Future<String> getNotepad(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['notepad'] ?? '';
  }

  /// Update notepad content
  Future<void> updateNotepad(String userId, String content) async {
    await _firestore.collection('users').doc(userId).set(
      {'notepad': content},
      SetOptions(merge: true),
    );
  }

  /// Stream of notepad content
  Stream<String> getNotepadStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['notepad'] ?? '');
  }

  // ====== User Profile ======

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      return {
        'name': '',
        'username': '',
        'bio': '',
        'profileImageUrl': null,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };
    }
    return doc.data() ?? {};
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, {
    String? name,
    String? username,
    String? bio,
    String? profileImageUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.now(),
    };
    
    if (name != null) updates['name'] = name;
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
    
    await _firestore.collection('users').doc(userId).set(
      updates,
      SetOptions(merge: true),
    );
  }

  /// Stream of user profile
  Stream<Map<String, dynamic>> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return {
              'name': '',
              'username': '',
              'bio': '',
              'profileImageUrl': null,
              'createdAt': Timestamp.now(),
              'updatedAt': Timestamp.now(),
            };
          }
          return doc.data() ?? {};
        });
  }
}
