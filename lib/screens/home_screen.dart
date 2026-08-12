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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final isDark = ref.watch(themeProvider);
    final p = AppPalette.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: p.bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 20,
              toolbarHeight: 64,
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: SplitsColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.call_split_rounded,
                        color: SplitsColors.onGold, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'spLit',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.6,
                      color: p.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                AppIconButton(
                  icon: isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  tooltip: 'Toggle theme',
                  onPressed: () =>
                      ref.read(themeProvider.notifier).state = !isDark,
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: Icons.settings_outlined,
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                ),
                const SizedBox(width: 20),
              ],
            ),
            if (groups.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.group_add_rounded,
                  title: 'No groups yet',
                  subtitle:
                      'Create a group to start splitting bills with friends.',
                  action: PrimaryButton(
                    onPressed: () => _showCreateGroupSheet(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded,
                            color: SplitsColors.onGold, size: 20),
                        SizedBox(width: 8),
                        Text('Create a Group',
                            style: TextStyle(
                                color: SplitsColors.onGold,
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _OverviewCard(groups: groups)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0, duration: 300.ms),
                    SectionHeader(
                      title: 'Your Groups',
                      trailing: CountBadge(count: groups.length),
                    ),
                    ...groups.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GroupCard(group: e.value)
                            .animate(delay: (e.key * 50).ms)
                            .fadeIn(duration: 280.ms)
                            .slideY(begin: 0.06, end: 0, duration: 280.ms),
                      );
                    }),
                  ]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: groups.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: PrimaryButton(
                onPressed: () => _showCreateGroupSheet(context),
                height: 54,
                borderRadius: SplitsRadius.pill,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded,
                        color: SplitsColors.onGold, size: 21),
                    SizedBox(width: 8),
                    Text('New Group',
                        style: TextStyle(
                            color: SplitsColors.onGold,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 240.ms).scale(
              delay: 180.ms, duration: 240.ms, curve: Curves.easeOutBack),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateGroupSheet(),
    );
  }
}

// ── Overview card ─────────────────────────────────────────────────────────────
/// The hero of the home screen: how much is still owed right now, plus the
/// three counts that used to sit in separate floating tiles.
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.groups});
  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    // Groups can use different currencies, so outstanding totals are bucketed
    // per currency and the largest bucket leads — summing across symbols would
    // produce a meaningless number.
    final byCurrency = <String, double>{};
    for (final g in groups) {
      final owed = groupOutstanding(g);
      if (owed <= 0) continue;
      byCurrency[g.currency] = (byCurrency[g.currency] ?? 0) + owed;
    }

    final buckets = byCurrency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final lead = buckets.isEmpty ? null : buckets.first;

    final activeSplits = groups.fold<int>(
        0, (s, g) => s + g.splits.where((sp) => sp.status != 'closed').length);
    final totalSplits = groups.fold<int>(0, (s, g) => s + g.splits.length);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(SplitsRadius.xl),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: lead == null ? p.positiveText : SplitsColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'OUTSTANDING',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              lead == null ? 'All settled' : formatMoney(lead.key, lead.value),
              style: amountStyle(
                size: 40,
                weight: FontWeight.w900,
                color: lead == null ? p.positiveText : p.textPrimary,
                letterSpacing: -1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lead == null
                ? 'Nothing owed across your groups'
                : buckets.length > 1
                    ? 'across $activeSplits active split${activeSplits == 1 ? '' : 's'} · +${buckets.length - 1} other currency'
                    : 'across $activeSplits active split${activeSplits == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 13, color: p.textSecondary),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: p.border),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                  value: '${groups.length}',
                  label: groups.length == 1 ? 'Group' : 'Groups'),
              _MiniDivider(color: p.border),
              _MiniStat(
                  value: '$totalSplits',
                  label: totalSplits == 1 ? 'Split' : 'Splits'),
              _MiniDivider(color: p.border),
              _MiniStat(
                value: '$activeSplits',
                label: 'Active',
                highlight: activeSplits > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: amountStyle(
              size: 19,
              weight: FontWeight.w800,
              color: highlight ? p.accentText : p.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 11.5, color: p.textSecondary)),
        ],
      ),
    );
  }
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: color);
}

// ── Group card ────────────────────────────────────────────────────────────────
class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group});
  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final payee = group.members.cast<Member?>().firstWhere(
          (m) => m?.id == group.payeeId,
          orElse: () => null,
        );
    final splitCount = group.splits.length;
    final hasActive = group.splits.any((s) => s.status != 'closed');
    final spend = groupTotalSpend(group);

    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.26,
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
        padding: const EdgeInsets.all(16),
        onTap: () => context.push('/group/${group.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Avatar(name: group.name, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.5,
                          letterSpacing: -0.3,
                          color: p.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${group.members.length} member${group.members.length == 1 ? '' : 's'}'
                        ' · $splitCount split${splitCount == 1 ? '' : 's'}',
                        style:
                            TextStyle(fontSize: 12.5, color: p.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatMoney(group.currency, spend),
                      style: amountStyle(
                        size: 16,
                        weight: FontWeight.w800,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('total',
                        style: TextStyle(fontSize: 11, color: p.textTertiary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: p.border),
            const SizedBox(height: 12),
            Row(
              children: [
                if (payee != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: SplitsColors.primary.withOpacity(p.tint),
                        borderRadius: BorderRadius.circular(SplitsRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 13, color: p.accentText),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              payee.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.1,
                                color: p.accentText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                if (splitCount > 0)
                  StatusPill(
                    label: hasActive ? 'Active' : 'Settled',
                    tone: hasActive ? Tone.info : Tone.positive,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Group'),
        content:
            Text('Delete "${group.name}"? This removes all splits and data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(groupsProvider.notifier).deleteGroup(group.id);
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

// ── Create group bottom sheet ─────────────────────────────────────────────────
class _CreateGroupSheet extends ConsumerStatefulWidget {
  const _CreateGroupSheet();

  @override
  ConsumerState<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<_CreateGroupSheet> {
  final _nameCtrl = TextEditingController();
  final _memberCtrl = TextEditingController();
  final _memberFocus = FocusNode();
  String _currency = '₹';
  final List<String> _members = [];
  String? _payeeName;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _memberCtrl.dispose();
    _memberFocus.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberCtrl.text.trim();
    if (name.isEmpty) return;
    // Case-insensitive duplicate check — "Bala" and "bala" are the same person.
    if (_members.any((m) => m.toLowerCase() == name.toLowerCase())) {
      setState(() => _error = '"$name" is already added');
      return;
    }
    setState(() {
      _members.add(name);
      _payeeName ??= name;
      _memberCtrl.clear();
      _error = null;
    });
    _memberFocus.requestFocus();
  }

  void _removeMember(String name) {
    setState(() {
      _members.remove(name);
      if (_payeeName == name) {
        _payeeName = _members.isEmpty ? null : _members.first;
      }
    });
  }

  Future<void> _create() async {
    if (_saving) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Group name is required');
      return;
    }
    if (_members.length < 2) {
      setState(() => _error = 'Add at least 2 members');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(groupsProvider.notifier).createGroup(
            name: name,
            memberNames: _members,
            payeeName: _payeeName ?? _members.first,
            currency: _currency,
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not create the group. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return SheetScaffold(
      title: 'Create Group',
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            hintText: 'e.g. Goa Trip 2025',
            prefixIcon: Icon(Icons.group_outlined),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 18),
        FieldLabel(text: 'Currency'),
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
        FieldLabel(text: 'Members'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _memberCtrl,
                focusNode: _memberFocus,
                decoration: const InputDecoration(
                  hintText: 'Add a name…',
                  prefixIcon: Icon(Icons.person_add_outlined),
                ),
                onSubmitted: (_) => _addMember(),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 10),
            PrimaryButton(
              onPressed: _addMember,
              height: 52,
              borderRadius: SplitsRadius.md,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              glow: false,
              child: const Text('Add',
                  style: TextStyle(
                      color: SplitsColors.onGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ),
          ],
        ),
        if (_members.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _members.map((m) {
              final isPayee = m == _payeeName;
              return SelectableChip(
                label: m,
                selected: isPayee,
                onTap: () => setState(() => _payeeName = m),
                leading: isPayee
                    ? const Icon(Icons.star_rounded,
                        size: 14, color: SplitsColors.onGold)
                    : Avatar(name: m, size: 18),
                trailing: GestureDetector(
                  onTap: () => _removeMember(m),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: isPayee
                        ? SplitsColors.onGold.withOpacity(0.7)
                        : p.textTertiary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a name to make them the payee ★',
            style: TextStyle(fontSize: 11.5, color: p.textTertiary),
          ),
        ],
        if (_error != null) FormError(message: _error!),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: _create,
            disabled: _saving,
            child: Text(
              _saving ? 'Creating…' : 'Create Group',
              style: const TextStyle(
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
