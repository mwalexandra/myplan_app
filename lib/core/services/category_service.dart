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

  // Sample data
  Future<void> addSampleCategories() async {
    final samples = [
      Category(id: '', name: 'Schule', icon: 'school', color: '0xFF4CAF50'),     // green
      Category(id: '', name: 'Sport', icon: 'sports_soccer', color: '0xFF2196F3'), // blue
      Category(id: '', name: 'Freizeit', icon: 'gamepad', color: '0xFFFF9800'),    // orange
      Category(id: '', name: 'Familie', icon: 'group', color: '0xFFE91E63'),      // pink
    ];

    for (var cat in samples) {
      await _firestore.collection(collection).doc(cat.name).set(cat.toFirestore());
    }
  }
}
