import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collection = 'categories';

  // All categories ordered by name
  Stream<List<Category>> getCategories() {
    return _firestore
        .collection(collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // By ID
  Future<Category?> getCategory(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (doc.exists) {
      return Category.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // CRUD
  Future<void> createCategory(Category category) async {
    await _firestore.collection(collection).doc(category.name).set(category.toFirestore());
  }

  Future<void> updateCategory(Category category) async {
    await _firestore.collection(collection).doc(category.name).set(category.toFirestore());
  }

  Future<void> deleteCategory(String categoryName) async {
    await _firestore.collection(collection).doc(categoryName).delete();
  }

  Future<void> ensureDefaultCategories() async {
    final existing = await _firestore.collection(collection).limit(1).get();
    
    if (existing.docs.isEmpty) {  
      print('Adding default categories...');
      final defaults = [
        Category(id: '', name: 'Schule', icon: 'school', color: '0xFF2196F3'),
        Category(id: '', name: 'Sport', icon: 'sports_soccer', color: '0xFFE91E63'),
        // Только 2 по твоему запросу
      ];

      for (var cat in defaults) {
        await _firestore.collection(collection).doc(cat.name).set(cat.toFirestore());
      }
    }
  }
}
