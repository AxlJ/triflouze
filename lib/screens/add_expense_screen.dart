import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triflouze/l10n/app_localizations.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../theme/triflouze_theme.dart';

// ─── Wizard d'ajout de dépense ────────────────────────────────────────────────
// Étapes : 0 Catégorie · 1 Montant · 2 Intitulé · 3 Pour qui

class AddExpenseScreen extends StatefulWidget {
  final List<Category> categories;
  final List<String> members;
  final Function(String name, String icon) onCategoryAdded;
  final Function(String id)? onCategoryDeleted;
  final Function(String name)? onMemberAdded;
  final Function(Expense)? onDelete;
  final Expense? expenseToEdit;
  final List<String> existingTags;
  final String currentUser;
  final String? newExpenseId;

  const AddExpenseScreen({
    super.key,
    required this.categories,
    required this.members,
    required this.onCategoryAdded,
    required this.currentUser,
    this.onCategoryDeleted,
    this.onMemberAdded,
    this.onDelete,
    this.expenseToEdit,
    this.existingTags = const [],
    this.newExpenseId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // ── Navigation
  int _step = 0;
  bool _goingForward = true;
  static const int _totalSteps = 4;

  // ── Étape 0 — Catégorie
  String? _category;
  String? _categoryIcon;

  // ── Étape 1 — Montant
  String _amountStr = '';
  String _currency = '€';

  // ── Étape 2 — Intitulé
  final _titleCtrl = TextEditingController();

  // ── Étape 3 — Pour qui + détails optionnels
  late List<String> _allMembers;
  List<String> _selectedMembers = [];
  final _newMemberCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final _commentCtrl = TextEditingController();
  List<String> _selectedTags = [];
  bool _showDetails = false;

  bool get _isEditing => widget.expenseToEdit != null;

  // ── Icônes par section pour le sélecteur de catégorie
  static const Map<String, List<String>> _iconsBySection = {
    'food':          ['🛒', '🍎', '🥦', '🥩', '🥐', '🧃', '🍷', '☕', '🍕', '🍣'],
    'housing':       ['🏠', '🛋️', '🔑', '🪴', '🧹', '💡', '🔧', '🛁', '🪟', '📦'],
    'transport':     ['🚗', '✈️', '🚂', '🚌', '🛵', '⛽', '🅿️', '🚕', '🚲', '🛳️'],
    'health':        ['💊', '🏥', '🩺', '🧴', '💉', '🩹', '🧪', '🏋️', '🧘', '😷'],
    'entertainment': ['🎮', '🎬', '🎵', '📚', '🎨', '⚽', '🎭', '🏖️', '🎲', '🎤'],
    'shopping':      ['👕', '👟', '💍', '🎒', '🕶️', '⌚', '💄', '🛍️', '🧢', '👗'],
    'tech':          ['💻', '📱', '🖥️', '🎧', '📷', '🖨️', '🔋', '💾', '🖱️', '📡'],
    'other':         ['📦', '🎁', '💼', '📝', '🔐', '🌍', '🐾', '👶', '🌸', '⭐'],
  };

  String _sectionDisplayName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'food':          return l10n.iconSectionFood;
      case 'housing':       return l10n.iconSectionHousing;
      case 'transport':     return l10n.iconSectionTransport;
      case 'health':        return l10n.iconSectionHealth;
      case 'entertainment': return l10n.iconSectionEntertainment;
      case 'shopping':      return l10n.iconSectionShopping;
      case 'tech':          return l10n.iconSectionTech;
      case 'other':         return l10n.iconSectionOther;
      default:              return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _allMembers = List.from(widget.members);
    if (_isEditing) {
      final e = widget.expenseToEdit!;
      _category = e.category;
      _categoryIcon = widget.categories
          .firstWhere((c) => c.name == e.category,
              orElse: () => Category(id: '', name: e.category, icon: '📦'))
          .icon;
      _amountStr = e.amount
          .toString()
          .replaceAll(RegExp(r'\.0+$'), '')
          .replaceAll(RegExp(r'(\.\d*?)0+$'), r'\1');
      _currency = e.currency;
      _titleCtrl.text = e.title;
      _date = e.date;
      _commentCtrl.text = e.comment;
      _selectedTags = List.from(e.tags);
      _selectedMembers = List.from(e.forMembers);
      for (final m in e.forMembers) {
        if (!_allMembers.contains(m)) _allMembers.add(m);
      }
    } else {
      if (widget.members.contains(widget.currentUser)) {
        _selectedMembers = [widget.currentUser];
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _newMemberCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _goTo(int step, {bool forward = true}) {
    setState(() {
      _goingForward = forward;
      _step = step;
    });
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _goTo(_step + 1);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      _goTo(_step - 1, forward: false);
    } else {
      Navigator.pop(context);
    }
  }

  // ── Soumission ──────────────────────────────────────────────────────────────

  void _submit() {
    if (_category == null || _amountStr.isEmpty || _selectedMembers.isEmpty) return;
    final title = _titleCtrl.text.trim().isEmpty
        ? (_category ?? 'Dépense')
        : _titleCtrl.text.trim();
    Navigator.pop(
      context,
      Expense(
        id: widget.expenseToEdit?.id ??
            widget.newExpenseId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: double.tryParse(_amountStr) ?? 0,
        currency: _currency,
        category: _category!,
        forMembers: _selectedMembers,
        date: _date,
        tags: _selectedTags,
        comment: _commentCtrl.text.trim(),
      ),
    );
  }

  // ── Numpad ──────────────────────────────────────────────────────────────────

  void _numpadPress(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountStr.isNotEmpty) _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else if (key == '.') {
        if (!_amountStr.contains('.')) _amountStr = _amountStr.isEmpty ? '0.' : '$_amountStr.';
      } else {
        final dotIdx = _amountStr.indexOf('.');
        if (dotIdx != -1 && _amountStr.length - dotIdx > 2) return;
        _amountStr = _amountStr == '0' ? key : '$_amountStr$key';
      }
    });
  }

  // ── Membres ─────────────────────────────────────────────────────────────────

  void _addMember(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _newMemberCtrl.clear();
    if (!_allMembers.contains(trimmed)) {
      setState(() => _allMembers.add(trimmed));
      widget.onMemberAdded?.call(trimmed);
    }
    if (!_selectedMembers.contains(trimmed)) setState(() => _selectedMembers.add(trimmed));
  }

  // ── Ajouter une catégorie ────────────────────────────────────────────────────

  Future<void> _showAddCategoryDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    String selectedIcon = '📦';
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(l10n.newCategoryTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.categoryNameLabel),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.chooseIcon,
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          color: TriflouzeTheme.textDark)),
                  const SizedBox(height: 8),
                  ..._iconsBySection.entries.map((section) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(_sectionDisplayName(section.key, l10n),
                                style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: TriflouzeTheme.textMedium,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: section.value.map((icon) {
                              final sel = selectedIcon == icon;
                              return GestureDetector(
                                onTap: () => setD(() => selectedIcon = icon),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? TriflouzeTheme.primary.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    border: Border.all(
                                        color: sel
                                            ? TriflouzeTheme.primary
                                            : Colors.transparent,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(icon,
                                      style: const TextStyle(fontSize: 24)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel)),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  widget.onCategoryAdded(nameCtrl.text.trim(), selectedIcon);
                  Navigator.pop(ctx);
                  // Auto-select the new category
                  setState(() {
                    _category = nameCtrl.text.trim();
                    _categoryIcon = selectedIcon;
                    _goingForward = true;
                    _step = 1;
                  });
                }
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TriflouzeTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) {
                  final key = child.key;
                  final isIncoming =
                      key is ValueKey<int> && key.value == _step;
                  final slideOffset = isIncoming
                      ? (_goingForward
                          ? const Offset(0.06, 0)
                          : const Offset(-0.06, 0))
                      : (_goingForward
                          ? const Offset(-0.06, 0)
                          : const Offset(0.06, 0));
                  return FadeTransition(
                    opacity: CurvedAnimation(
                        parent: animation, curve: Curves.easeOut),
                    child: SlideTransition(
                      position: Tween(begin: slideOffset, end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeOut)),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_step),
                  child: _buildStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── En-tête progress ─────────────────────────────────────────────────────────

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _step == 0 ? Icons.close : Icons.arrow_back,
              color: TriflouzeTheme.textDark,
            ),
            onPressed: _back,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: List.generate(_totalSteps, (i) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i <= _step ? TriflouzeTheme.primary : TriflouzeTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          if (_isEditing && widget.onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteExpenseTitle),
        content: Text(l10n.deleteExpenseConfirm(widget.expenseToEdit!.title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      widget.onDelete!(widget.expenseToEdit!);
      if (mounted) Navigator.pop(context, null);
    }
  }

  // ── Dispatch étapes ──────────────────────────────────────────────────────────

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildCategoryStep();
      case 1: return _buildAmountStep();
      case 2: return _buildTitleStep();
      case 3: return _buildMembersStep();
      default: return const SizedBox.shrink();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ÉTAPE 0 — Catégorie
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
          child: Text(
            l10n.whichCategory,
            style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: TriflouzeTheme.textDark),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: widget.categories.length + 1,
            itemBuilder: (context, i) {
              if (i == widget.categories.length) return _addCategoryTile(l10n);
              return _categoryTile(widget.categories[i], l10n);
            },
          ),
        ),
      ],
    );
  }

  Widget _categoryTile(Category cat, AppLocalizations l10n) {
    final isSelected = _category == cat.name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _category = cat.name;
          _categoryIcon = cat.icon;
          _goingForward = true;
          _step = 1;
        });
      },
      onLongPress: cat.name == 'Autre' || widget.onCategoryDeleted == null
          ? null
          : () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.deleteCategoryTitle),
                  content: Text(l10n.deleteCategoryConfirm(cat.name)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel)),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.delete,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (ok == true) widget.onCategoryDeleted!(cat.id);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? TriflouzeTheme.primary.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TriflouzeTheme.primary : TriflouzeTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(cat.icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(
              cat.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? TriflouzeTheme.primary
                    : TriflouzeTheme.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addCategoryTile(AppLocalizations l10n) => GestureDetector(
        onTap: _showAddCategoryDialog,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TriflouzeTheme.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline,
                  size: 32, color: TriflouzeTheme.textMedium),
              const SizedBox(height: 6),
              Text(l10n.addCategoryTile,
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: TriflouzeTheme.textMedium)),
            ],
          ),
        ),
      );

  // ────────────────────────────────────────────────────────────────────────────
  // ÉTAPE 1 — Montant
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildAmountStep() {
    final l10n = AppLocalizations.of(context)!;
    final canNext = _amountStr.isNotEmpty && (double.tryParse(_amountStr) ?? 0) > 0;
    return Column(
      children: [
        _recapRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.whichAmount,
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: TriflouzeTheme.textDark)),
          ),
        ),
        // Sélecteur devise
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: ['€', '\$', 'MAD'].map((c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _currency = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: _currency == c
                        ? TriflouzeTheme.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _currency == c
                            ? TriflouzeTheme.primary
                            : TriflouzeTheme.border),
                  ),
                  child: Text(c,
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          color: _currency == c
                              ? Colors.white
                              : TriflouzeTheme.textDark)),
                ),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Affichage montant
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _amountStr.isEmpty ? '0' : _amountStr,
                    style: GoogleFonts.nunito(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: _amountStr.isEmpty
                          ? TriflouzeTheme.border
                          : TriflouzeTheme.textDark,
                    ),
                  ),
                ),
              ),
              Text(_currency,
                  style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: TriflouzeTheme.textMedium)),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _numpad(),
        ),
        _nextButton(l10n.next, _next, enabled: canNext),
      ],
    );
  }

  Widget _numpad() {
    const rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['.', '0', '⌫'],
    ];
    return Column(
      children: rows.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: row.map((key) {
            final isBack = key == '⌫';
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _numpadPress(key),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: isBack
                          ? TriflouzeTheme.secondary.withValues(alpha: 0.10)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TriflouzeTheme.border),
                    ),
                    alignment: Alignment.center,
                    child: isBack
                        ? Icon(Icons.backspace_outlined,
                            color: TriflouzeTheme.secondary, size: 22)
                        : Text(key,
                            style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: TriflouzeTheme.textDark)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )).toList(),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ÉTAPE 2 — Intitulé
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildTitleStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _recapRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Text(l10n.expenseTitleLabel,
              style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: TriflouzeTheme.textDark)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: _titleCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.nunito(
                fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: _category ?? l10n.expenseTitleHint,
              hintStyle: GoogleFonts.nunito(
                  color: TriflouzeTheme.border,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            onSubmitted: (_) => _next(),
          ),
        ),
        const Spacer(),
        Center(
          child: TextButton(
            onPressed: () {
              _titleCtrl.clear();
              _next();
            },
            child: Text(
              l10n.skipButton(_category ?? 'Dépense'),
              style: GoogleFonts.nunito(
                  color: TriflouzeTheme.textMedium, fontSize: 13),
            ),
          ),
        ),
        _nextButton(l10n.next, _next),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ÉTAPE 3 — Pour qui + détails optionnels
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildMembersStep() {
    final l10n = AppLocalizations.of(context)!;
    final canSubmit = _selectedMembers.isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _recapRow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Text(l10n.forWho,
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: TriflouzeTheme.textDark)),
          ),
          // Chips membres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allMembers.map((m) {
                final sel = _selectedMembers.contains(m);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) {
                      _selectedMembers.remove(m);
                    } else {
                      _selectedMembers.add(m);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? TriflouzeTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: sel
                            ? TriflouzeTheme.primary
                            : TriflouzeTheme.border,
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      m.split(' ').first,
                      style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: sel
                              ? Colors.white
                              : TriflouzeTheme.textDark),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Ajouter un bénéficiaire
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newMemberCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.addBeneficiary,
                      hintText: l10n.addBeneficiaryHint,
                    ),
                    onSubmitted: _addMember,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add_circle,
                      color: TriflouzeTheme.primary, size: 30),
                  onPressed: () => _addMember(_newMemberCtrl.text),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Détails optionnels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: () => setState(() => _showDetails = !_showDetails),
              icon: Icon(
                  _showDetails ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: TriflouzeTheme.textMedium),
              label: Text(l10n.moreDetails,
                  style: GoogleFonts.nunito(
                      color: TriflouzeTheme.textMedium,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ),
          if (_showDetails) ...[
            // Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.dateLabel,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_date.day.toString().padLeft(2, '0')}/'
                    '${_date.month.toString().padLeft(2, '0')}/'
                    '${_date.year}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Commentaire
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _commentCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                    labelText: l10n.commentLabel,
                    hintText: l10n.commentHint),
              ),
            ),
            const SizedBox(height: 12),
            // Tags
            if (widget.existingTags.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(l10n.tagsLabel,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: TriflouzeTheme.textMedium,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.existingTags.map((tag) {
                    final isSel = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSel,
                      onSelected: (_) => setState(() {
                        if (isSel) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      }),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 8),
          _nextButton(
            _isEditing ? l10n.editExpenseButton : l10n.addExpenseButton,
            canSubmit ? _submit : null,
            enabled: canSubmit,
          ),
        ],
      ),
    );
  }

  // ── UI partagée ──────────────────────────────────────────────────────────────

  Widget _recapRow() {
    final chips = <Widget>[];
    if (_category != null) {
      chips.add(_RecapChip(
        label: '${_categoryIcon ?? ''} $_category',
        onTap: () => _goTo(0, forward: false),
      ));
    }
    if (_step >= 2 && _amountStr.isNotEmpty) {
      chips.add(_RecapChip(
        label: '$_amountStr $_currency',
        onTap: () => _goTo(1, forward: false),
      ));
    }
    if (_step >= 3 && _titleCtrl.text.isNotEmpty) {
      chips.add(_RecapChip(
        label: _titleCtrl.text,
        onTap: () => _goTo(2, forward: false),
      ));
    }
    if (chips.isEmpty) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips
              .map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8), child: c))
              .toList(),
        ),
      ),
    );
  }

  Widget _nextButton(String label, VoidCallback? onPressed,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: Text(label),
        ),
      ),
    );
  }
}

// ── Chip de récapitulatif ─────────────────────────────────────────────────────

class _RecapChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RecapChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: TriflouzeTheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: TriflouzeTheme.primary.withValues(alpha: 0.30)),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: TriflouzeTheme.primary),
        ),
      ),
    );
  }
}
