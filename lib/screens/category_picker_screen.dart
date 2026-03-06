import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class CategoryPickerScreen extends StatefulWidget {
  final List<Category> categories;
  final List<String> members;
  final Function(String name, String icon) onCategoryAdded;
  final Function(String id)? onCategoryDeleted;
  final Function(String name)? onMemberAdded;
  final List<String> existingTags;
  final String currentUser;

  const CategoryPickerScreen({
    super.key,
    required this.categories,
    required this.members,
    required this.onCategoryAdded,
    required this.existingTags,
    required this.currentUser,
    this.onCategoryDeleted,
    this.onMemberAdded,
  });

  @override
  State<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends State<CategoryPickerScreen> {
  final Map<String, List<String>> iconsBySection = {
    'Alimentation': ['🛒', '🍎', '🥦', '🥩', '🥐', '🧃', '🍷', '☕', '🍕', '🍣'],
    'Logement': ['🏠', '🛋️', '🔑', '🪴', '🧹', '💡', '🔧', '🛁', '🪟', '📦'],
    'Transport': ['🚗', '✈️', '🚂', '🚌', '🛵', '⛽', '🅿️', '🚕', '🚲', '🛳️'],
    'Santé': ['💊', '🏥', '🩺', '🧴', '💉', '🩹', '🧪', '🏋️', '🧘', '😷'],
    'Loisirs': ['🎮', '🎬', '🎵', '📚', '🎨', '⚽', '🎭', '🏖️', '🎲', '🎤'],
    'Shopping': ['👕', '👟', '💍', '🎒', '🕶️', '⌚', '💄', '🛍️', '🧢', '👗'],
    'Tech': ['💻', '📱', '🖥️', '🎧', '📷', '🖨️', '🔋', '💾', '🖱️', '📡'],
    'Autres': ['📦', '🎁', '💼', '📝', '🔐', '🌍', '🐾', '👶', '🌸', '⭐'],
  };

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedIcon = '📦';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvelle catégorie'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choisir une icône :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...iconsBySection.entries.map(
                    (section) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            section.key,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: section.value.map((icon) {
                            final isSelected = selectedIcon == icon;
                            return GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedIcon = icon),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade100
                                      : Colors.transparent,
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.blue,
                                          width: 2,
                                        )
                                      : Border.all(
                                          color: Colors.transparent,
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  widget.onCategoryAdded(nameController.text, selectedIcon);
                  Navigator.pop(context);
                  setState(() {});
                  _selectCategory(nameController.text);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCategory(String categoryName) async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          initialCategory: categoryName,
          categories: widget.categories,
          members: widget.members,
          onCategoryAdded: widget.onCategoryAdded,
          onMemberAdded: widget.onMemberAdded,
          existingTags: widget.existingTags,
          currentUser: widget.currentUser,
        ),
      ),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une catégorie'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: widget.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.categories.length) {
            return GestureDetector(
              onTap: _showAddCategoryDialog,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 32, color: Colors.blue.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Nouvelle\ncatégorie',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final cat = widget.categories[index];
          return GestureDetector(
            onTap: () => _selectCategory(cat.name),
            onLongPress: cat.name == 'Autre' || widget.onCategoryDeleted == null
                ? null
                : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer la catégorie'),
                        content: Text(
                          'Voulez-vous supprimer "${cat.name}" ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) widget.onCategoryDeleted!(cat.id);
                  },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    cat.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
