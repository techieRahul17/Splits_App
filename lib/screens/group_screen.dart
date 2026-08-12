import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../providers/groups_provider.dart';
import '../theme/app_theme.dart';
import '../utils/split_calculator.dart';
import '../widgets/common_widgets.dart';

class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    final p = AppPalette.of(context);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group')),
        body: const Center(child: Text('Group not found')),
      );
    }

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
            title: Text(
              group.name,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 17, color: p.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              AppIconButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit group',
                onPressed: () => _showEditGroupSheet(context, ref, group),
              ),
              const SizedBox(width: 16),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Members ────────────────────────────────────────────────
                SectionHeader(
                  title: 'Members',
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.surfaceRaised,
                      borderRadius: BorderRadius.circular(SplitsRadius.pill),
                    ),
                    child: Text(
                      '${group.members.length}',
                      style: TextStyle(
                          color: p.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(
                  height: 82,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: group.members.length,
                    itemBuilder: (_, i) {
                      final m = group.members[i];
                      final isPayee = m.id == group.payeeId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Avatar(
                                  name: m.name,
                                  size: 48,
                                  ring: isPayee,
                                  ringColor: SplitsColors.primary,
                                ),
                                if (isPayee)
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: SplitsColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: p.bg, width: 2),
                                      ),
                                      child: const Icon(Icons.star_rounded,
                                          size: 10, color: SplitsColors.onGold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              m.name.split(' ').first,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight:
                                    isPayee ? FontWeight.w700 : FontWeight.w500,
                                color: isPayee
                                    ? SplitsColors.primary
                                    : p.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: (i * 40).ms).fadeIn().slideX(begin: 0.15);
                    },
                  ),
                ),

                // ── Splits ─────────────────────────────────────────────────
                SectionHeader(
                  title: 'Splits',
                  trailing: PillButton(
                    label: 'New Split',
                    icon: Icons.add,
                    onPressed: () => _showCreateSplitSheet(context, ref, group),
                  ),
                ),

                if (group.splits.isEmpty)
                  EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No splits yet',
                    subtitle:
                        'Create a split for a meal, trip, or any shared expense',
                    action: PillButton(
                      label: 'Create Split',
                      icon: Icons.add,
                      onPressed: () => _showCreateSplitSheet(context, ref, group),
                    ),
                  )
                else
                  ...group.splits.reversed.toList().asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SplitCard(
                        group: group,
                        split: e.value,
                        index: e.key,
                      ),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateSplitSheet(BuildContext context, WidgetRef ref, Group group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateSplitSheet(group: group),
    );
  }

  void _showEditGroupSheet(BuildContext context, WidgetRef ref, Group group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditGroupSheet(group: group),
    );
  }
}

// ── Split card ────────────────────────────────────────────────────────────────
class _SplitCard extends ConsumerWidget {
  const _SplitCard({
    required this.group,
    required this.split,
    required this.index,
  });

  final Group group;
  final SplitSession split;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final total = split.totalBill;
    final isClosed = split.status == 'closed';
    final paidCount = split.paidMemberIds.length;
    final nonPayeeCount =
        group.members.where((m) => m.id != split.payeeId).length;

    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _confirmDelete(context, ref),
            backgroundColor: SplitsColors.negative,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.circular(SplitsRadius.lg),
          ),
        ],
      ),
      child: AppCard(
        onTap: () => context.push('/group/${group.id}/split/${split.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (isClosed ? SplitsColors.positive : SplitsColors.info)
                        .withOpacity(0.14),
                    borderRadius: BorderRadius.circular(SplitsRadius.md),
                  ),
                  child: Icon(
                    isClosed
                        ? Icons.check_circle_outline_rounded
                        : Icons.receipt_long_outlined,
                    color: isClosed ? SplitsColors.positive : SplitsColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        split.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: p.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formatDate(split.createdAt),
                        style: TextStyle(fontSize: 12, color: p.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${group.currency}${total.toStringAsFixed(2)}',
                  style: amountStyle(
                      size: 16, weight: FontWeight.w800, color: p.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatChip(
                  icon: Icons.list_alt_outlined,
                  label:
                      '${split.items.length} item${split.items.length != 1 ? 's' : ''}',
                ),
                const SizedBox(width: 8),
                StatChip(
                  icon: Icons.payments_outlined,
                  label: '$paidCount/$nonPayeeCount paid',
                  highlight: paidCount == nonPayeeCount && nonPayeeCount > 0,
                ),
                const Spacer(),
                StatusPill(
                  label: isClosed ? 'Closed' : 'Active',
                  tone: isClosed ? Tone.positive : Tone.info,
                ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: (index * 50).ms)
          .fadeIn(duration: 280.ms)
          .slideY(begin: 0.06, end: 0),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Split'),
        content: Text('Delete "${split.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(groupsProvider.notifier).deleteSplit(
                    groupId: group.id,
                    splitId: split.id,
                  );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: SplitsColors.negative),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Create split sheet ────────────────────────────────────────────────────────
class _CreateSplitSheet extends ConsumerStatefulWidget {
  const _CreateSplitSheet({required this.group});
  final Group group;

  @override
  ConsumerState<_CreateSplitSheet> createState() => _CreateSplitSheetState();
}

class _CreateSplitSheetState extends ConsumerState<_CreateSplitSheet> {
  final _nameCtrl = TextEditingController();
  late String _payeeId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _payeeId = widget.group.payeeId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Split title is required');
      return;
    }
    await ref.read(groupsProvider.notifier).createSplit(
          groupId: widget.group.id,
          name: name,
          payeeId: _payeeId,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'New Split',
      children: [
        TextField(
          controller: _nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Split Title / Occasion',
            hintText: 'e.g. Dinner, Groceries, Hotel',
            prefixIcon: Icon(Icons.receipt_long_outlined),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 18),
        const FieldLabel(text: 'Who paid upfront?'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.group.members.map((m) {
            return SelectableChip(
              label: m.name,
              selected: _payeeId == m.id,
              onTap: () => setState(() => _payeeId = m.id),
              leading: _payeeId == m.id
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: SplitsColors.onGold)
                  : Avatar(name: m.name, size: 18),
            );
          }).toList(),
        ),
        if (_error != null) FormError(message: _error!),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: _create,
            child: const Text(
              'Create Split',
              style: TextStyle(
                  color: SplitsColors.onGold,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Edit group sheet ──────────────────────────────────────────────────────────
class _EditGroupSheet extends ConsumerStatefulWidget {
  const _EditGroupSheet({required this.group});
  final Group group;

  @override
  ConsumerState<_EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends ConsumerState<_EditGroupSheet> {
  late final TextEditingController _nameCtrl;
  late String _payeeId;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.group.name);
    _payeeId = widget.group.payeeId;
    _currency = widget.group.currency;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.group.copyWith(
      name: _nameCtrl.text.trim(),
      payeeId: _payeeId,
      currency: _currency,
    );
    await ref.read(groupsProvider.notifier).updateGroup(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'Edit Group',
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            prefixIcon: Icon(Icons.group_outlined),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 18),
        const FieldLabel(text: 'Currency'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kCurrencySymbols.map((c) {
            return SelectableChip(
              label: c,
              selected: _currency == c,
              onTap: () => setState(() => _currency = c),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        const FieldLabel(text: 'Default Payee'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.group.members.map((m) {
            return SelectableChip(
              label: m.name,
              selected: _payeeId == m.id,
              onTap: () => setState(() => _payeeId = m.id),
              leading: _payeeId == m.id
                  ? const Icon(Icons.star_rounded,
                      size: 14, color: SplitsColors.onGold)
                  : Avatar(name: m.name, size: 18),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: _save,
            child: const Text(
              'Save Changes',
              style: TextStyle(
                  color: SplitsColors.onGold,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
