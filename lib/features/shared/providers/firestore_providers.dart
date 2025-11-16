import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/link_item.dart';
import '../models/category.dart';
import '../../auth/auth_controller.dart';

/// Provider for FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

/// Provider for user's links stream
final userLinksProvider = StreamProvider<List<LinkItem>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;
  
  if (userId == null) return Stream.value([]);
  
  return ref.watch(firestoreServiceProvider).getUserLinks(userId);
});

/// Provider for user's favorite links stream
final favoriteLinksProvider = StreamProvider<List<LinkItem>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;
  
  if (userId == null) return Stream.value([]);
  
  return ref.watch(firestoreServiceProvider).getFavoriteLinks(userId);
});

/// Provider for user's categories stream
final userCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;
  
  if (userId == null) return Stream.value([]);
  
  return ref.watch(firestoreServiceProvider).getUserCategories(userId);
});

/// Provider for links by category
final linksByCategoryProvider = StreamProvider.family<List<LinkItem>, String>((ref, categoryId) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;
  
  if (userId == null) return Stream.value([]);
  
  return ref.watch(firestoreServiceProvider).getLinksByCategory(userId, categoryId);
});
