import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../providers/groups_provider.dart';
import '../theme/app_theme.dart';
import '../utils/split_calculator.dart';
import '../widgets/common_widgets.dart';

class SplitScreen extends ConsumerWidget {
  const SplitScreen({
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
        appBar: AppBar(title: const Text('Split')),
        body: const Center(child: Text('Group not found')),
      );
    }

    final split = group.splits
        .cast<SplitSession?>()
        .firstWhere((s) => s?.id == splitId, orElse: () => null);

    if (split == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Split')),
        body: const Center(child: Text('Split not found')),
      );
    }

    final payee = group.members
        .cast<Member?>()
        .firstWhere((m) => m?.id == split.payeeId, orElse: () => null);
    final isClosed = split.status == 'closed';

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
              split.name,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 17, color: p.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (split.items.isNotEmpty)
                AppIconButton(
                  icon: Icons.summarize_outlined,
                  tooltip: 'View summary',
                  onPressed: () =>
                      context.push('/group/$groupId/split/$splitId/summary'),
                ),
              const SizedBox(width: 8),
              _MenuButton(split: split, onSelect: (v) => _handleMenu(context, ref, v, split)),
              const SizedBox(width: 16),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (payee != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Paid by ${payee.name}',
                      style: TextStyle(fontSize: 13, color: p.textSecondary),
                    ),
                  ),

                if (split.items.isNotEmpty)
                  _SummaryBar(group: group, split: split),

                SectionHeader(
                  title: 'Items',
                  trailing: !isClosed
                      ? PillButton(
                          label: 'Add Item',
                          icon: Icons.add,
                          onPressed: () =>
                              _showAddItemSheet(context, ref, group, split),
                        )
                      : const StatusPill(label: 'Closed', tone: Tone.positive),
                ),

                if (split.items.isEmpty)
                  EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No items yet',
                    subtitle:
                        'Add items like Biryani ${group.currency}600 and split them among members',
                    action: !isClosed
                        ? PillButton(
                            label: 'Add First Item',
                            icon: Icons.add,
                            onPressed: () =>
                                _showAddItemSheet(context, ref, group, split),
                          )
                        : null,
                  )
                else
                  ...split.items.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ItemCard(
                            group: group,
                            split: split,
                            item: e.value,
                            index: e.key,
                            locked: isClosed,
                          ),
                        ),
                      ),

                if (split.items.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () => context.push(
                        '/group/$groupId/split/$splitId/summary',
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.summarize_outlined, color: SplitsColors.onGold, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'View Split Summary',
                            style: TextStyle(
                              color: SplitsColors.onGold,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenu(
      BuildContext context, WidgetRef ref, String value, SplitSession split) {
    if (value == 'close') {
      final newStatus = split.status == 'closed' ? 'active' : 'closed';
      ref.read(groupsProvider.notifier).updateSplit(
            groupId: groupId,
            split: split.copyWith(status: newStatus),
          );
    }
  }

  void _showAddItemSheet(
      BuildContext context, WidgetRef ref, Group group, SplitSession split) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(group: group, split: split),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.split, required this.onSelect});
  final SplitSession split;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return PopupMenuButton<String>(
      onSelected: onSelect,
      padding: EdgeInsets.zero,
      splashRadius: 20,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: p.surfaceRaised, shape: BoxShape.circle),
        child: Icon(Icons.more_horiz_rounded, color: p.textPrimary, size: 20),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'close',
          child: Row(
            children: [
              Icon(
                split.status == 'closed'
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline_rounded,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(split.status == 'closed' ? 'Reopen Split' : 'Close Split'),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.group, required this.split});

  final Group group;
  final SplitSession split;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _BarStat(
                label: 'Total',
                value: '${group.currency}${split.totalBill.toStringAsFixed(2)}',
                color: SplitsColors.primary,
              ),
            ),
            Container(width: 1, height: 34, color: p.border),
            Expanded(
              child: _BarStat(
                label: 'Items',
                value: '${split.items.length}',
                color: p.infoText,
              ),
            ),
            Container(width: 1, height: 34, color: p.border),
            Expanded(
              child: _BarStat(
                label: 'Paid',
                value:
                    '${split.paidMemberIds.length}/${group.members.where((m) => m.id != split.payeeId).length}',
                color: p.positiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarStat extends StatelessWidget {
  const _BarStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      children: [
        Text(value, style: amountStyle(size: 17, weight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: p.textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ── Item card ─────────────────────────────────────────────────────────────────
class _ItemCard extends ConsumerWidget {
  const _ItemCard({
    required this.group,
    required this.split,
    required this.item,
    required this.index,
    required this.locked,
  });

  final Group group;
  final SplitSession split;
  final SplitItem item;
  final int index;
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    return Slidable(
      endActionPane: locked
          ? null
          : ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    ref.read(groupsProvider.notifier).deleteItemFromSplit(
                          groupId: group.id,
                          splitId: split.id,
                          itemId: item.id,
                        );
                  },
                  backgroundColor: SplitsColors.negative,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove',
                  borderRadius: BorderRadius.circular(SplitsRadius.lg),
                ),
              ],
            ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: p.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AmountBadge(amount: item.price, currency: group.currency),
              ],
            ),
            const SizedBox(height: 12),
            ...item.shares.map((share) {
              final member = group.members
                  .cast<Member?>()
                  .firstWhere((m) => m?.id == share.memberId, orElse: () => null);
              if (member == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Avatar(name: member.name, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        member.name,
                        style: TextStyle(fontSize: 13, color: p.textPrimary),
                      ),
                    ),
                    if (!locked)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _toggleLock(ref, share);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            share.locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                            size: 14,
                            color: share.locked ? p.infoText : p.textTertiary,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.currency}${share.amount.toStringAsFixed(2)}',
                      style: amountStyle(
                        size: 13,
                        weight: FontWeight.w700,
                        color: share.locked ? p.infoText : p.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      )
          .animate(delay: (index * 40).ms)
          .fadeIn(duration: 250.ms)
          .slideY(begin: 0.05, end: 0),
    );
  }

  void _toggleLock(WidgetRef ref, ItemShare share) {
    final newShares = item.shares.map((s) {
      if (s.memberId == share.memberId) {
        return s.copyWith(locked: !s.locked);
      }
      return s;
    }).toList();

    final updated = item.copyWith(
      shares: computeShares(item.copyWith(shares: newShares)),
    );

    ref.read(groupsProvider.notifier).updateItemInSplit(
          groupId: group.id,
          splitId: split.id,
          item: updated,
        );
  }
}

// ── Add item sheet ────────────────────────────────────────────────────────────
class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet({required this.group, required this.split});
  final Group group;
  final SplitSession split;

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  late Set<String> _selected;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.group.members.map((m) => m.id).toSet();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    final priceStr = _priceCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Item name is required');
      return;
    }
    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      setState(() => _error = 'Enter a valid price');
      return;
    }
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one member');
      return;
    }

    await ref.read(groupsProvider.notifier).addItemToSplit(
          groupId: widget.group.id,
          splitId: widget.split.id,
          itemName: name,
          price: price,
          includedMemberIds: _selected.toList(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final allSelected = _selected.length == widget.group.members.length;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final perHead = _selected.isEmpty ? 0.0 : price / _selected.length;

    return SheetScaffold(
      title: 'Add Item',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g. Biryani',
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _priceCtrl,
                // Rebuilds the live per-person preview as the price is typed.
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Price',
                  hintText: '0.00',
                  prefixText: '${widget.group.currency} ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(child: FieldLabel(text: 'Split among')),
            GestureDetector(
              onTap: () => setState(() {
                if (allSelected) {
                  _selected.clear();
                } else {
                  _selected = widget.group.members.map((m) => m.id).toSet();
                }
              }),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 9, left: 8),
                child: Text(
                  allSelected ? 'Clear all' : 'Select all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.accentText,
                  ),
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.group.members.map((m) {
            final selected = _selected.contains(m.id);
            return SelectableChip(
              label: m.name,
              selected: selected,
              onTap: () {
                setState(() {
                  if (selected) {
                    _selected.remove(m.id);
                  } else {
                    _selected.add(m.id);
                  }
                });
              },
              leading: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: SplitsColors.onGold)
                  : Avatar(name: m.name, size: 18),
            );
          }).toList(),
        ),
        if (price > 0 && _selected.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: p.surfaceRaised,
              borderRadius: BorderRadius.circular(SplitsRadius.md),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Icon(Icons.pie_chart_outline_rounded,
                    size: 15, color: p.accentText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Splits to ${formatMoney(widget.group.currency, perHead)} each',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: p.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '${_selected.length} ${_selected.length == 1 ? 'person' : 'people'}',
                  style: TextStyle(fontSize: 11.5, color: p.textTertiary),
                ),
              ],
            ),
          ),
        ],
        if (_error != null) FormError(message: _error!),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: _add,
            child: const Text(
              'Add Item',
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
