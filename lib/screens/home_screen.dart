import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:triflouze/l10n/app_localizations.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'add_expense_screen.dart';
import 'stats_screen.dart';
import 'group_settings_screen.dart';
import '../widgets/expense_tile.dart';
import '../theme/triflouze_theme.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final String groupId;
  final String groupName;
  final String groupCode;
  final List<String> members;
  final List<String> forMembers;
  final List<String> memberUids;
  final void Function(String groupId) onSwitchGroup;

  const HomeScreen({
    super.key,
    required this.user,
    required this.groupId,
    required this.groupName,
    required this.groupCode,
    required this.members,
    required this.forMembers,
    required this.memberUids,
    required this.onSwitchGroup,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirestoreService _fs;

  List<Category> _latestCategories = [];
  final Set<String> _deletingIds = {};

  final Map<String, double> toEuroRates = {
    '€': 1.0,
    '\$': 0.8502,
    'MAD': 0.0925,
  };

  List<Color> get chartColors => TriflouzeTheme.chartColors;

  int? touchedIndex;

  // Internal period keys — locale-independent
  static const _kAll = 'all';
  static const _kToday = 'today';
  static const _kWeek = 'week';
  static const _kMonth = 'month';
  static const _kYear = 'year';

  String selectedPeriod = _kToday;
  String? selectedCategoryFilter;
  String? selectedMemberFilter;
  int _periodOffset = 0;

  @override
  void initState() {
    super.initState();
    _fs = FirestoreService(widget.groupId);
    final displayName = widget.user.displayName ?? '';
    if (displayName.isNotEmpty) {
      _fs.ensureMemberDisplayName(widget.user.uid, displayName);
    }
  }

  bool get _supportsNavigation =>
      selectedPeriod == _kToday ||
      selectedPeriod == _kWeek ||
      selectedPeriod == _kMonth ||
      selectedPeriod == _kYear;

  DateTime get _referenceDate {
    final now = DateTime.now();
    if (selectedPeriod == _kToday) {
      return DateTime(now.year, now.month, now.day - _periodOffset);
    } else if (selectedPeriod == _kWeek) {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      return DateTime(
        monday.year,
        monday.month,
        monday.day - _periodOffset * 7,
      );
    } else if (selectedPeriod == _kMonth) {
      return DateTime(now.year, now.month - _periodOffset);
    } else if (selectedPeriod == _kYear) {
      return DateTime(now.year - _periodOffset);
    }
    return now;
  }

  void _goToPreviousPeriod() => setState(() => _periodOffset++);
  void _goToNextPeriod() {
    if (_periodOffset > 0) setState(() => _periodOffset--);
  }

  List<Expense> _filteredExpenses(List<Expense> expenses) {
    final ref = _referenceDate;
    return expenses.where((e) {
      bool matchesPeriod;
      if (selectedPeriod == _kToday) {
        matchesPeriod =
            e.date.year == ref.year &&
            e.date.month == ref.month &&
            e.date.day == ref.day;
      } else if (selectedPeriod == _kWeek) {
        final end = ref.add(const Duration(days: 7));
        matchesPeriod = !e.date.isBefore(ref) && e.date.isBefore(end);
      } else if (selectedPeriod == _kMonth) {
        matchesPeriod =
            e.date.year == ref.year && e.date.month == ref.month;
      } else if (selectedPeriod == _kYear) {
        matchesPeriod = e.date.year == ref.year;
      } else {
        matchesPeriod = true;
      }

      final matchesCategory =
          selectedCategoryFilter == null ||
          e.category == selectedCategoryFilter;

      final matchesMember =
          selectedMemberFilter == null ||
          e.forMembers.contains(selectedMemberFilter);

      return matchesPeriod && matchesCategory && matchesMember;
    }).toList();
  }

  Map<String, double> _totalByCategory(List<Expense> filtered) {
    final Map<String, double> totals = {};
    for (final e in filtered) {
      final rate = toEuroRates[e.currency] ?? 1.0;
      totals[e.category] = (totals[e.category] ?? 0) + (e.amount * rate);
    }
    return Map.fromEntries(
      totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> _addExpense(Expense expense) async {
    final expenseWithAuthor = expense.copyWith(addedBy: widget.user.uid);
    await _fs.addExpense(expenseWithAuthor);
    NotificationService.sendExpenseNotification(
      allMemberUids: widget.memberUids,
      addedByUid: widget.user.uid,
      category: expenseWithAuthor.category,
      amount: expenseWithAuthor.amount,
      currency: expenseWithAuthor.currency,
      title: expenseWithAuthor.title,
    );
  }

  Future<void> _editExpense(Expense expense) => _fs.updateExpense(expense);

  Future<void> _deleteExpense(Expense expense) async {
    setState(() => _deletingIds.add(expense.id));
    try {
      await _fs.deleteExpense(expense.id);
    } finally {
      if (mounted) setState(() => _deletingIds.remove(expense.id));
    }
  }

  Future<void> _addForMember(String name) => _fs.addForMember(name);
  Future<void> _deleteForMember(String name) => _fs.deleteForMember(name);
  Future<void> _deleteCategory(String id) => _fs.deleteCategory(id);

  Future<void> _addCategory(String name, String icon) async {
    final id = _fs.generateCategoryId();
    final order = _latestCategories
        .where((c) => c.name != 'Autre')
        .length;
    await _fs.addCategory(
      Category(id: id, name: name, icon: icon),
      order: order * 10 + 10,
    );
  }

  // ── Date labels (using intl for locale-aware formatting) ─────────────────────

  String _dayLabel(DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('d MMMM yyyy', locale).format(d);
  }

  String _monthLabel(DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final s = DateFormat('MMMM yyyy', locale).format(d);
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  String _weekLabel(DateTime monday) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final sunday = monday.add(const Duration(days: 6));
    final dfShort = DateFormat('d MMM', locale);
    if (monday.month == sunday.month) {
      final monthYear = DateFormat('MMM yyyy', locale).format(sunday);
      return '${monday.day}–${sunday.day} $monthYear';
    }
    return '${dfShort.format(monday)} – ${dfShort.format(sunday)} ${sunday.year}';
  }

  String _periodName(AppLocalizations l10n) {
    switch (selectedPeriod) {
      case _kAll: return l10n.filterAll;
      case _kToday: return l10n.filterToday;
      case _kWeek: return l10n.filterThisWeek;
      case _kMonth: return l10n.filterThisMonth;
      case _kYear: return l10n.filterThisYear;
      default: return selectedPeriod;
    }
  }

  String periodLabel(AppLocalizations l10n) {
    if (_periodOffset > 0) {
      final ref = _referenceDate;
      if (selectedPeriod == _kToday) return _dayLabel(ref);
      if (selectedPeriod == _kWeek) return _weekLabel(ref);
      if (selectedPeriod == _kMonth) return _monthLabel(ref);
      if (selectedPeriod == _kYear) return ref.year.toString();
    }
    return _periodName(l10n);
  }

  Widget _buildMiniPieChart(
    Map<String, double> data,
    double totalInEuros,
    List<Expense> filtered,
    AppLocalizations l10n,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();
    final entries = data.entries.toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatsScreen(
            expenses: filtered,
            toEuroRates: toEuroRates,
            periodLabel: periodLabel(l10n),
            categories: _latestCategories,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                      sections: entries.asMap().entries.map((entry) {
                        final i = entry.key;
                        final amount = entry.value.value;
                        final isTouched = i == touchedIndex;
                        final color = chartColors[i % chartColors.length];
                        final percentage = totalInEuros > 0
                            ? (amount / totalInEuros * 100)
                            : 0.0;
                        return PieChartSectionData(
                          color: color,
                          value: amount,
                          title: isTouched
                              ? '${percentage.toStringAsFixed(0)}%'
                              : '',
                          radius: isTouched ? 55 : 45,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries
                          .take(5)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final i = entry.key;
                        final category = entry.value.key;
                        final amount = entry.value.value;
                        final color = chartColors[i % chartColors.length];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${amount.toStringAsFixed(0)}€',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.viewDetails,
                style: TextStyle(
                    fontSize: 12,
                    color: TriflouzeTheme.primary,
                    fontWeight: FontWeight.w600),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 10, color: TriflouzeTheme.primary),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserName =
        widget.user.displayName ?? widget.user.email ?? l10n.user;

    return StreamBuilder<List<Category>>(
      stream: _fs.watchCategories(),
      builder: (context, catSnap) {
        final categories = catSnap.data ?? [];
        _latestCategories = categories;

        return StreamBuilder<List<Expense>>(
          stream: _fs.watchExpenses(),
          builder: (context, expSnap) {
            final expenses = (expSnap.data ?? [])
                .where((e) => !_deletingIds.contains(e.id))
                .toList();
            final filtered = _filteredExpenses(expenses);
            final byCategory = _totalByCategory(filtered);
            final totalInEuros =
                byCategory.values.fold(0.0, (sum, v) => sum + v);
            final allTags =
                expenses.expand((e) => e.tags).toSet().toList();

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.groupName),
                    Text(
                      currentUserName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.group_add),
                    tooltip: l10n.inviteTooltip,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        final dl10n = AppLocalizations.of(context)!;
                        return AlertDialog(
                          title: Text(dl10n.inviteDialogTitle),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dl10n.inviteDialogSubtitle,
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  widget.groupCode,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton.icon(
                              icon: const Icon(Icons.copy, size: 18),
                              label: Text(dl10n.copyButton),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: widget.groupCode),
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(dl10n.codeCopied),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(dl10n.close),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: l10n.settingsTooltip,
                    onPressed: () async {
                      final primaryGroupId = await UserService()
                          .getPrimaryGroupId(widget.user.uid);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupSettingsScreen(
                            user: widget.user,
                            currentGroupId: widget.groupId,
                            primaryGroupId: primaryGroupId ?? widget.groupId,
                            onSwitchGroup: widget.onSwitchGroup,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: l10n.logoutTooltip,
                    onPressed: () => AuthService().signOut(),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: TriflouzeTheme.primary.withValues(alpha: 0.08),
                    child: Column(
                      children: [
                        Text(
                          l10n.totalExpenses,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${totalInEuros.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_supportsNavigation)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                color: Colors.black54,
                                onPressed: _goToPreviousPeriod,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                periodLabel(l10n),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: _periodOffset > 0
                                      ? Colors.black54
                                      : Colors.transparent,
                                ),
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _periodOffset > 0
                                    ? _goToNextPeriod
                                    : null,
                              ),
                            ],
                          )
                        else
                          Text(
                            periodLabel(l10n),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildMiniPieChart(byCategory, totalInEuros, filtered, l10n),
                      ],
                    ),
                  ),

                  // Filtres période
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...([
                            (_kAll,   l10n.filterAll),
                            (_kToday, l10n.filterToday),
                            (_kWeek,  l10n.filterThisWeek),
                            (_kMonth, l10n.filterThisMonth),
                            (_kYear,  l10n.filterThisYear),
                          ]).map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(p.$2),
                                selected: selectedPeriod == p.$1,
                                onSelected: (_) => setState(() {
                                  selectedPeriod = p.$1;
                                  _periodOffset = 0;
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filtres bénéficiaires
                  Builder(builder: (context) {
                    final allForMembers = ([...widget.forMembers]..sort());
                    if (allForMembers.length <= 1) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(l10n.filterAllMembers),
                                selected: selectedMemberFilter == null,
                                onSelected: (_) => setState(
                                  () => selectedMemberFilter = null,
                                ),
                              ),
                            ),
                            ...allForMembers.map(
                              (m) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onLongPress: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        final dl10n = AppLocalizations.of(context)!;
                                        return AlertDialog(
                                          title: Text(dl10n.deleteBeneficiaryTitle),
                                          content: Text(dl10n.deleteBeneficiaryConfirm(m)),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(dl10n.cancel),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: Text(
                                                dl10n.delete,
                                                style: const TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirm == true) {
                                      if (selectedMemberFilter == m) {
                                        setState(
                                          () => selectedMemberFilter = null,
                                        );
                                      }
                                      _deleteForMember(m);
                                    }
                                  },
                                  child: ChoiceChip(
                                    avatar: const Icon(Icons.person, size: 16),
                                    label: Text(m.split(' ').first),
                                    selected: selectedMemberFilter == m,
                                    onSelected: (_) => setState(
                                      () => selectedMemberFilter = m,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Filtres catégories
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(l10n.filterAllCategories),
                              selected: selectedCategoryFilter == null,
                              onSelected: (_) => setState(
                                () => selectedCategoryFilter = null,
                              ),
                            ),
                          ),
                          ...categories.map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('${c.icon} ${c.name}'),
                                selected: selectedCategoryFilter == c.name,
                                onSelected: (_) => setState(
                                  () => selectedCategoryFilter = c.name,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noExpensesForPeriod,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return ExpenseTile(
                                expense: filtered[index],
                                onEdit: (expense) async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddExpenseScreen(
                                        categories: categories,
                                        members: widget.forMembers,
                                        onCategoryAdded: _addCategory,
                                        onCategoryDeleted: _deleteCategory,
                                        onMemberAdded: _addForMember,
                                        onDelete: _deleteExpense,
                                        expenseToEdit: expense,
                                        existingTags: allTags,
                                        currentUser: currentUserName,
                                      ),
                                    ),
                                  );
                                  if (result != null) _editExpense(result);
                                },
                                onDelete: _deleteExpense,
                              );
                            },
                          ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpenseScreen(
                        categories: categories,
                        members: widget.forMembers,
                        onCategoryAdded: _addCategory,
                        onCategoryDeleted: _deleteCategory,
                        onMemberAdded: _addForMember,
                        existingTags: allTags,
                        currentUser: currentUserName,
                      ),
                    ),
                  );
                  if (result != null) _addExpense(result);
                },
                child: const Icon(Icons.add),
              ),
            );
          },
        );
      },
    );
  }
}
