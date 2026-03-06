import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triflouze/l10n/app_localizations.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../theme/triflouze_theme.dart';

class StatsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Map<String, double> toEuroRates;
  final String periodLabel;
  final List<Category> categories;

  const StatsScreen({
    super.key,
    required this.expenses,
    required this.toEuroRates,
    required this.periodLabel,
    this.categories = const [],
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int? _touchedIndex;

  // ── Données ──────────────────────────────────────────────────────────────────

  Map<String, double> get _byCategory {
    final Map<String, double> totals = {};
    for (final e in widget.expenses) {
      final rate = widget.toEuroRates[e.currency] ?? 1.0;
      totals[e.category] = (totals[e.category] ?? 0) + e.amount * rate;
    }
    return Map.fromEntries(
        totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  double get _total => _byCategory.values.fold(0, (s, v) => s + v);

  String _iconFor(String categoryName) => widget.categories
      .firstWhere((c) => c.name == categoryName,
          orElse: () => Category(id: '', name: categoryName, icon: '📦'))
      .icon;

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = _byCategory;

    return Scaffold(
      backgroundColor: TriflouzeTheme.surface,
      appBar: AppBar(
        title: Text(l10n.statisticsTitle),
      ),
      body: data.isEmpty
          ? Center(
              child: Text(l10n.noExpensesForPeriod,
                  style: GoogleFonts.nunito(color: TriflouzeTheme.textMedium)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 24),
                  _buildDonut(data),
                  const SizedBox(height: 32),
                  _buildSectionTitle(l10n.categoryBreakdown),
                  const SizedBox(height: 12),
                  ..._buildCategoryCards(data),
                ],
              ),
            ),
    );
  }

  // ── En-tête ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            widget.periodLabel,
            style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TriflouzeTheme.textMedium),
          ),
          const SizedBox(height: 4),
          Text(
            '${_total.toStringAsFixed(2)} €',
            style: GoogleFonts.nunito(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: TriflouzeTheme.textDark),
          ),
          Text(
            l10n.expenseCount(widget.expenses.length),
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: TriflouzeTheme.textMedium,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Donut ─────────────────────────────────────────────────────────────────────

  Widget _buildDonut(Map<String, double> data) {
    final entries = data.entries.toList();
    final touched = _touchedIndex != null &&
        _touchedIndex! >= 0 &&
        _touchedIndex! < entries.length;
    final touchedEntry = touched ? entries[_touchedIndex!] : null;

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = null;
                      return;
                    }
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: entries.asMap().entries.map((e) {
                final i = e.key;
                final amount = e.value.value;
                final isTouched = i == _touchedIndex;
                final color =
                    TriflouzeTheme.chartColors[i % TriflouzeTheme.chartColors.length];
                return PieChartSectionData(
                  color: color,
                  value: amount,
                  title: '',
                  radius: isTouched ? 82 : 68,
                  borderSide: isTouched
                      ? BorderSide(color: color.withValues(alpha: 0.4), width: 4)
                      : const BorderSide(color: Colors.transparent),
                );
              }).toList(),
              sectionsSpace: 3,
              centerSpaceRadius: 72,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: touchedEntry != null
                ? _donutCenter(
                    key: ValueKey(touchedEntry.key),
                    icon: _iconFor(touchedEntry.key),
                    name: touchedEntry.key,
                    amount: touchedEntry.value,
                    percent: _total > 0
                        ? touchedEntry.value / _total * 100
                        : 0,
                  )
                : _donutCenterDefault(key: const ValueKey('default')),
          ),
        ],
      ),
    );
  }

  Widget _donutCenterDefault({Key? key}) => Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.totalLabel,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TriflouzeTheme.textMedium)),
          Text('${_total.toStringAsFixed(0)} €',
              style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: TriflouzeTheme.textDark)),
        ],
      );

  Widget _donutCenter({
    Key? key,
    required String icon,
    required String name,
    required double amount,
    required double percent,
  }) =>
      Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 2),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: TriflouzeTheme.textDark),
          ),
          Text(
            '${amount.toStringAsFixed(0)} €',
            style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TriflouzeTheme.textMedium),
          ),
        ],
      );

  // ── Titre de section ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TriflouzeTheme.textDark),
      );

  // ── Cards catégories ──────────────────────────────────────────────────────────

  List<Widget> _buildCategoryCards(Map<String, double> data) {
    return data.entries.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final category = entry.value.key;
      final amount = entry.value.value;
      final percent = _total > 0 ? amount / _total : 0.0;
      final color =
          TriflouzeTheme.chartColors[i % TriflouzeTheme.chartColors.length];
      final icon = _iconFor(category);

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: color, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category,
                      style: GoogleFonts.nunito(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${amount.toStringAsFixed(2)} €',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: TriflouzeTheme.textDark),
                      ),
                      Text(
                        '${(percent * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: TriflouzeTheme.textMedium),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
