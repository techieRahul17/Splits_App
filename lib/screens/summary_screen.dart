import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../providers/groups_provider.dart';
import '../theme/app_theme.dart';
import '../utils/split_calculator.dart';
import '../widgets/common_widgets.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({
    super.key,
    required this.groupId,
    required this.splitId,
  });

  final String groupId;
  final String splitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    final p = AppPalette.of(context);
    if (group == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Summary')),
          body: const Center(child: Text('Group not found')));
    }

    final split = group.splits
        .cast<SplitSession?>()
        .firstWhere((s) => s?.id == splitId, orElse: () => null);
    if (split == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Summary')),
          body: const Center(child: Text('Split not found')));
    }

    final payee = group.members
        .cast<Member?>()
        .firstWhere((m) => m?.id == split.payeeId, orElse: () => null);

    final totals = computeSummary(members: group.members, items: split.items);

    final nonPayeeMembers =
        group.members.where((m) => m.id != split.payeeId).toList();
    final totalOwed = nonPayeeMembers.fold(
      0.0,
      (sum, m) => sum + (totals[m.id] ?? 0),
    );
    final paidCount =
        nonPayeeMembers.where((m) => split.paidMemberIds.contains(m.id)).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: p.bg,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: AppIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => context.pop(),
              ),
            ),
            title: Text('Summary',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: p.textPrimary)),
            actions: [
              AppIconButton(
                icon: Icons.ios_share_rounded,
                tooltip: 'Share summary',
                onPressed: () =>
                    _shareViaWhatsApp(context, group, split, totals, payee),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeroTotal(
                  group: group,
                  split: split,
                  payee: payee,
                  totalOwed: totalOwed,
                  paidCount: paidCount,
                  totalCount: nonPayeeMembers.length,
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Who Owes What',
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                ),
                if (payee != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PayeeCard(
                            payee: payee, group: group, totalOwed: totalOwed)
                        .animate()
                        .fadeIn(duration: 250.ms),
                  ),
                ...nonPayeeMembers.asMap().entries.map((e) {
                  final m = e.value;
                  final amount = totals[m.id] ?? 0;
                  final isPaid = split.paidMemberIds.contains(m.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MemberSummaryCard(
                      member: m,
                      amount: amount,
                      currency: group.currency,
                      isPaid: isPaid,
                      payee: payee,
                      splitName: split.name,
                      onMarkPaid: () {
                        ref.read(groupsProvider.notifier).markMemberPaid(
                              groupId: groupId,
                              splitId: splitId,
                              memberId: m.id,
                            );
                      },
                      onRemindWhatsApp: () => _sendWhatsAppReminder(
                          context, m, amount, group, split, payee),
                    )
                        .animate(delay: (e.key * 60).ms)
                        .fadeIn(duration: 280.ms)
                        .slideY(begin: 0.06, end: 0),
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _shareViaWhatsApp(
    BuildContext context,
    Group group,
    SplitSession split,
    Map<String, double> totals,
    Member? payee,
  ) {
    final payeeName = payee?.name ?? 'Payee';
    final nonPayeeDebts =
        group.members.where((m) => m.id != split.payeeId).map((m) {
      final amount = totals[m.id] ?? 0;
      final paid = split.paidMemberIds.contains(m.id) ? ' ✓ Paid' : '';
      return '• ${m.name}: ${group.currency}${amount.toStringAsFixed(2)}$paid';
    }).join('\n');

    final message = '*${split.name}* — ${group.name}\n\n'
        'Total: ${group.currency}${split.totalBill.toStringAsFixed(2)} '
        '(paid by $payeeName)\n\n'
        'Shares:\n$nonPayeeDebts';

    Share.share(message);
  }

  void _sendWhatsAppReminder(
    BuildContext context,
    Member member,
    double amount,
    Group group,
    SplitSession split,
    Member? payee,
  ) {
    final payeeName = payee?.name ?? 'Payee';
    final message = 'Hey ${member.name}! 👋\n\n'
        'Your share for *${split.name}* is '
        '${group.currency}${amount.toStringAsFixed(2)} '
        '(to $payeeName). Please pay when you can! 🙏';

    final url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

// ── Hero total ────────────────────────────────────────────────────────────────
class _HeroTotal extends StatelessWidget {
  const _HeroTotal({
    required this.group,
    required this.split,
    required this.payee,
    required this.totalOwed,
    required this.paidCount,
    required this.totalCount,
  });

  final Group group;
  final SplitSession split;
  final Member? payee;
  final double totalOwed;
  final int paidCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 1.0 : paidCount / totalCount;
    // Gold is a bright, light accent — every label on this card uses dark
    // (onGold) text/ink rather than white so contrast stays crisp.
    const ink = SplitsColors.onGold;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: SplitsColors.heroGradient,
        borderRadius: BorderRadius.circular(SplitsRadius.xl),
        boxShadow: [
          BoxShadow(
            color: SplitsColors.primary.withOpacity(0.4),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            split.name,
            style: TextStyle(
                color: ink.withOpacity(0.72),
                fontSize: 13,
                fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${group.currency}${split.totalBill.toStringAsFixed(2)}',
            style: amountStyle(
                size: 44,
                weight: FontWeight.w900,
                color: ink,
                letterSpacing: -1.2),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.15, end: 0, duration: 300.ms),
          const SizedBox(height: 4),
          Text(
            'Total bill${payee != null ? ' · paid by ${payee!.name}' : ''}',
            style: TextStyle(
                color: ink.withOpacity(0.68),
                fontSize: 12.5,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          // Dark "chrome plate" inset — a gold card with a black inlay reads
          // distinctly premium and keeps the secondary stats legible.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(SplitsRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${group.currency}${totalOwed.toStringAsFixed(2)}',
                        style: amountStyle(
                            size: 18, weight: FontWeight.w800, color: ink),
                      ),
                      const SizedBox(height: 2),
                      Text('to collect',
                          style:
                              TextStyle(color: Colors.white, fontSize: 11.5)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$paidCount/$totalCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('paid up',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(SplitsRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.black.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation(ink),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payee card ────────────────────────────────────────────────────────────────
class _PayeeCard extends StatelessWidget {
  const _PayeeCard({
    required this.payee,
    required this.group,
    required this.totalOwed,
  });

  final Member payee;
  final Group group;
  final double totalOwed;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return AppCard(
      borderColor: SplitsColors.positive.withOpacity(0.3),
      color: SplitsColors.positive.withOpacity(0.08),
      child: Row(
        children: [
          Avatar(name: payee.name, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payee.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: p.textPrimary)),
                Text('Payee (paid upfront)',
                    style: TextStyle(color: p.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${group.currency}${totalOwed.toStringAsFixed(2)}',
                style: amountStyle(
                    size: 16, weight: FontWeight.w800, color: p.positiveText),
              ),
              Text('to collect',
                  style: TextStyle(color: p.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Member summary card ───────────────────────────────────────────────────────
class _MemberSummaryCard extends StatelessWidget {
  const _MemberSummaryCard({
    required this.member,
    required this.amount,
    required this.currency,
    required this.isPaid,
    required this.payee,
    required this.splitName,
    required this.onMarkPaid,
    required this.onRemindWhatsApp,
  });

  final Member member;
  final double amount;
  final String currency;
  final bool isPaid;
  final Member? payee;
  final String splitName;
  final VoidCallback onMarkPaid;
  final VoidCallback onRemindWhatsApp;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Avatar(name: member.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: p.textPrimary)),
                    if (payee != null)
                      Text('owes ${payee!.name}',
                          style:
                              TextStyle(color: p.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currency${amount.toStringAsFixed(2)}',
                    style: amountStyle(
                      size: 16,
                      weight: FontWeight.w800,
                      color: isPaid ? p.positiveText : p.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (isPaid)
                    StatusPill.paid()
                  else
                    Text('pending',
                        style: TextStyle(color: p.textTertiary, fontSize: 11)),
                ],
              ),
            ],
          ),
          if (!isPaid) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (payee?.upiId != null) ...[
                  _RoundIconAction(
                    icon: Icons.qr_code_scanner_rounded,
                    color: SplitsColors.positive,
                    tooltip: 'Pay via UPI',
                    onTap: () => _openUpi(context),
                  ),
                  const SizedBox(width: 8),
                ],
                _RoundIconAction(
                  icon: Icons.chat_outlined,
                  color: SplitsColors.whatsapp,
                  tooltip: 'Remind on WhatsApp',
                  onTap: onRemindWhatsApp,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    onPressed: onMarkPaid,
                    height: 48,
                    borderRadius: SplitsRadius.md,
                    glow: false,
                    child: const Text('Mark Paid',
                        style: TextStyle(
                            color: SplitsColors.onGold,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _openUpi(BuildContext context) {
    if (payee?.upiId == null) return;
    final link = buildUpiLink(
      payeeUpiId: payee!.upiId!,
      payeeName: payee!.upiName ?? payee!.name,
      amount: amount,
      note: 'Split: $splitName',
    );
    launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }
}

class _RoundIconAction extends StatelessWidget {
  const _RoundIconAction({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: color.withOpacity(0.14),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
