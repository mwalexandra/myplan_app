import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/category.dart';
import '../../core/services/category_service.dart';
import '../../core/utils/category_ui_mapper.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddEditCategoryScreen({
    super.key,
    this.category,
  });

  bool get isEdit => category != null;

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryService = CategoryService();

  late String _selectedIconKey;
  late String _selectedColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category?.name ?? '';
    _selectedIconKey = widget.category?.iconKey ?? 'school';
    _selectedColor = widget.category?.color ?? '0xFF2196F3';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final category = Category(
      id: widget.category?.id ?? '',
      name: _nameController.text.trim(),
      iconKey: _selectedIconKey,
      color: _selectedColor,
      isDefault: widget.category?.isDefault ?? false,
      createdAt: widget.category?.createdAt,
      updatedAt: widget.category?.updatedAt,
    );

    try {
      if (widget.isEdit) {
        await _categoryService.updateCategory(category);
      } else {
        await _categoryService.createCategory(category);
      }

      if (!mounted) return;
      context.pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewColor = CategoryUiMapper.colorFromString(_selectedColor);
    final previewIcon = CategoryUiMapper.iconFromKey(_selectedIconKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit category' : 'Add category'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: previewColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Icon(previewIcon, size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        _nameController.text.trim().isEmpty
                            ? 'Preview'
                            : _nameController.text.trim(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Please enter category name';
                    }
                    if (text.length < 2) {
                      return 'Minimum 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedIconKey,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: CategoryUiMapper.icons.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(entry.value),
                          const SizedBox(width: 12),
                          Text(entry.key),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedIconKey = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedColor,
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(),
                  ),
                  items: CategoryUiMapper.colors.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: CategoryUiMapper.colorFromString(entry.value),
                          ),
                          const SizedBox(width: 12),
                          Text(entry.key),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedColor = value);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(_isSaving ? 'Saving...' : 'Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
