import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a saved link with metadata
class LinkItem {
  final String id;
  final String url;
  final String title;
  final String description;
  final String? imageUrl;
  final String domain;
  final String? categoryId;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  LinkItem({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.domain,
    this.categoryId,
    this.favorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create LinkItem from Firestore document
  factory LinkItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LinkItem(
      id: doc.id,
      url: data['url'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      domain: data['domain'] ?? '',
      categoryId: data['categoryId'],
      favorite: data['favorite'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert LinkItem to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'domain': domain,
      'categoryId': categoryId,
      'favorite': favorite,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields
  LinkItem copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    String? imageUrl,
    String? domain,
    String? categoryId,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LinkItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      domain: domain ?? this.domain,
      categoryId: categoryId ?? this.categoryId,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
