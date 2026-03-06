import 'package:flutter/material.dart';
import 'package:triflouze/l10n/app_localizations.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final Function(Expense) onEdit;
  final Function(Expense) onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      onTap: () => onEdit(expense),
      onLongPress: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteExpenseTitle),
            content: Text(l10n.deleteExpenseDialogConfirm(expense.title)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (confirm == true) onDelete(expense);
      },
      leading: CircleAvatar(child: Text(expense.category[0])),
      title: Text(expense.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.forLabel} ${expense.forMembers.join(', ')} · ${expense.category}\n'
            '${expense.date.day.toString().padLeft(2, '0')}/'
            '${expense.date.month.toString().padLeft(2, '0')}/'
            '${expense.date.year}',
          ),
          if (expense.comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                expense.comment,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (expense.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                children: expense.tags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
      isThreeLine: true,
      trailing: Text(
        '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
