import '../models/models.dart';

/// Recomputes shares for an item.
/// Locked shares stay fixed; remaining amount is split equally
/// among unlocked members. Last unlocked absorbs rounding.
List<ItemShare> computeShares(SplitItem item) {
  final memberIds = item.includedMemberIds;
  if (memberIds.isEmpty) return [];

  final lockedShares = item.shares
      .where((s) => s.locked && memberIds.contains(s.memberId))
      .toList();

  final unlockedIds = memberIds
      .where((id) => !lockedShares.any((s) => s.memberId == id))
      .toList();

  final lockedTotal =
      lockedShares.fold(0.0, (sum, s) => sum + s.amount);
  final remainder =
      (item.price - lockedTotal).toDouble();

  final newShares = <ItemShare>[...lockedShares];

  if (unlockedIds.isNotEmpty) {
    // Floor to 2 decimal places, last member absorbs rounding
    final base = (remainder / unlockedIds.length * 100).floor() / 100;
    final baseTotal = double.parse(
        (base * unlockedIds.length).toStringAsFixed(2));
    final leftover =
        double.parse((remainder - baseTotal).toStringAsFixed(2));

    for (int i = 0; i < unlockedIds.length; i++) {
      final isLast = i == unlockedIds.length - 1;
      newShares.add(ItemShare(
        memberId: unlockedIds[i],
        amount: double.parse(
            (isLast ? base + leftover : base).toStringAsFixed(2)),
        locked: false,
      ));
    }
  }

  return newShares;
}

/// Sums each member's shares across all items.
/// Returns memberId → total owed.
Map<String, double> computeSummary({
  required List<Member> members,
  required List<SplitItem> items,
}) {
  final totals = {for (final m in members) m.id: 0.0};

  for (final item in items) {
    for (final share in item.shares) {
      if (totals.containsKey(share.memberId)) {
        totals[share.memberId] = double.parse(
            ((totals[share.memberId]! + share.amount))
                .toStringAsFixed(2));
      }
    }
  }

  return totals;
}

/// Builds a UPI deep-link.
String buildUpiLink({
  required String payeeUpiId,
  required String payeeName,
  required double amount,
  required String note,
}) {
  final params = {
    'pa': payeeUpiId,
    'pn': payeeName,
    'am': amount.toStringAsFixed(2),
    'cu': 'INR',
    'tn': note,
  };
  final query = params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
  return 'upi://pay?$query';
}

/// Formats currency amount.
String formatAmount(String currency, double amount) {
  return '$currency${amount.toStringAsFixed(2)}';
}

/// Formats an amount with thousands separators, e.g. `₹1,240.00`.
String formatMoney(String currency, double amount) {
  final fixed = amount.abs().toStringAsFixed(2);
  final dot = fixed.indexOf('.');
  final whole = fixed.substring(0, dot);
  final fraction = fixed.substring(dot + 1);

  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }

  final sign = amount < 0 ? '-' : '';
  return '$sign$currency$buf.$fraction';
}

/// Total a group's members still owe their payees, counting only splits that
/// are still open and only members who have not been marked paid.
double groupOutstanding(Group group) {
  var total = 0.0;
  for (final split in group.splits) {
    if (split.status == 'closed') continue;
    final totals = computeSummary(members: group.members, items: split.items);
    for (final member in group.members) {
      if (member.id == split.payeeId) continue;
      if (split.paidMemberIds.contains(member.id)) continue;
      total += totals[member.id] ?? 0;
    }
  }
  return double.parse(total.toStringAsFixed(2));
}

/// Everything ever billed in a group, across all of its splits.
double groupTotalSpend(Group group) =>
    double.parse(
        group.splits.fold(0.0, (sum, s) => sum + s.totalBill).toStringAsFixed(2));

/// Formats a timestamp to a readable date string.
String formatDate(int millis) {
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
