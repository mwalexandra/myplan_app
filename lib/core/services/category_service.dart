import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  Stream<List<Category>> getCategories() {
    return _categories.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => Category.fromFirestore(doc.data(), doc.id))
          .toList();

      items.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return items;
    });
  }

  Future<Category?> getCategoryById(String id) async {
    final doc = await _categories.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Category.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> createCategory(Category category) async {
    final docRef = _categories.doc();
    final newCategory = category.copyWith(id: docRef.id);

    await docRef.set(newCategory.toFirestore(isCreate: true));
  }

  Future<void> updateCategory(Category category) async {
    await _categories.doc(category.id).update(category.toFirestore());
  }

  Future<void> deleteCategory(String id) async {
    await _categories.doc(id).delete();
  }

  Future<void> ensureDefaultCategories() async {
    final existing = await _categories.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();

    final sportRef = _categories.doc();
    final familyRef = _categories.doc();

    final defaults = [
      Category(
        id: sportRef.id,
        name: 'Sport',
        iconKey: 'sports_soccer',
        color: '0xFF2196F3',
        isDefault: true,
      ),
      Category(
        id: familyRef.id,
        name: 'Familie',
        iconKey: 'family',
        color: '0xFFE91E63',
        isDefault: true,
      ),
    ];

    batch.set(sportRef, defaults[0].toFirestore(isCreate: true));
    batch.set(familyRef, defaults[1].toFirestore(isCreate: true));

    await batch.commit();
  }
}
