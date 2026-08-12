import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../utils/split_calculator.dart';

const _uuid = Uuid();

// ── Hive box provider ─────────────────────────────────────────────────────────
final groupBoxProvider = Provider<Box<Group>>((ref) {
  return Hive.box<Group>('groups');
});

// ── Groups notifier ───────────────────────────────────────────────────────────
class GroupsNotifier extends Notifier<List<Group>> {
  @override
  List<Group> build() {
    final box = ref.watch(groupBoxProvider);
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Box<Group> get _box => ref.read(groupBoxProvider);

  void _save() {
    state = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Group> createGroup({
    required String name,
    required List<String> memberNames,
    required String payeeName,
    String currency = '₹',
  }) async {
    final members = memberNames
        .map((n) => Member(id: _uuid.v4(), name: n.trim()))
        .toList();

    final payee = members.firstWhere(
      (m) => m.name == payeeName,
      orElse: () => members.first,
    );

    final group = Group(
      id: _uuid.v4(),
      name: name.trim(),
      payeeId: payee.id,
      currency: currency,
      members: members,
      items: [],
      createdAt: DateTime.now().millisecondsSinceEpoch,
      ownerId: 'local',
      splits: [],
    );

    await _box.put(group.id, group);
    _save();
    return group;
  }

  Future<void> updateGroup(Group group) async {
    await _box.put(group.id, group);
    _save();
  }

  Future<void> deleteGroup(String id) async {
    await _box.delete(id);
    _save();
  }

  Group? getGroup(String id) => _box.get(id);

  // ── Split operations ────────────────────────────────────────────────────────
  Future<SplitSession> createSplit({
    required String groupId,
    required String name,
    required String payeeId,
  }) async {
    final group = _box.get(groupId);
    if (group == null) throw Exception('Group not found');

    final split = SplitSession(
      id: _uuid.v4(),
      name: name.trim(),
      createdBy: 'local',
      createdByName: 'You',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      payeeId: payeeId,
      items: [],
      paidMemberIds: [],
    );

    final updated = group.copyWith(splits: [...group.splits, split]);
    await _box.put(groupId, updated);
    _save();
    return split;
  }

  Future<void> updateSplit({
    required String groupId,
    required SplitSession split,
  }) async {
    final group = _box.get(groupId);
    if (group == null) return;

    final splits = group.splits
        .map((s) => s.id == split.id ? split : s)
        .toList();
    final updated = group.copyWith(splits: splits);
    await _box.put(groupId, updated);
    _save();
  }

  Future<void> deleteSplit({
    required String groupId,
    required String splitId,
  }) async {
    final group = _box.get(groupId);
    if (group == null) return;

    final splits = group.splits.where((s) => s.id != splitId).toList();
    final updated = group.copyWith(splits: splits);
    await _box.put(groupId, updated);
    _save();
  }

  // ── Item operations ─────────────────────────────────────────────────────────
  Future<void> addItemToSplit({
    required String groupId,
    required String splitId,
    required String itemName,
    required double price,
    required List<String> includedMemberIds,
  }) async {
    final group = _box.get(groupId);
    if (group == null) return;

    final rawShares = includedMemberIds
        .map((id) => ItemShare(memberId: id, amount: 0.0))
        .toList();

    final newItem = SplitItem(
      id: _uuid.v4(),
      name: itemName.trim(),
      price: price,
      includedMemberIds: includedMemberIds,
      shares: rawShares,
    );

    final recomputed =
        newItem.copyWith(shares: computeShares(newItem));

    final splits = group.splits.map((s) {
      if (s.id != splitId) return s;
      return s.copyWith(items: [...s.items, recomputed]);
    }).toList();

    await _box.put(groupId, group.copyWith(splits: splits));
    _save();
  }

  Future<void> updateItemInSplit({
    required String groupId,
    required String splitId,
    required SplitItem item,
  }) async {
    final group = _box.get(groupId);
    if (group == null) return;

    final splits = group.splits.map((s) {
      if (s.id != splitId) return s;
      final items =
          s.items.map((i) => i.id == item.id ? item : i).toList();
      return s.copyWith(items: items);
    }).toList();

    await _box.put(groupId, group.copyWith(splits: splits));
    _save();
  }

  Future<void> deleteItemFromSplit({
    required String groupId,
    required String splitId,
    required String itemId,
  }) async {
    final group = _box.get(groupId);
    if (group == null) return;

    final splits = group.splits.map((s) {
      if (s.id != splitId) return s;
      return s.copyWith(
          items: s.items.where((i) => i.id != itemId).toList());
    }).toList();

    await _box.put(groupId, group.copyWith(splits: splits));
    _save();
  }

  Future<void> markMemberPaid({
    required String groupId,
    required String splitId,
    required String memberId,
  }) async {
    final group = _box.get(groupId);
    if (group == null) return;

    final splits = group.splits.map((s) {
      if (s.id != splitId) return s;
      if (s.paidMemberIds.contains(memberId)) return s;
      return s.copyWith(
          paidMemberIds: [...s.paidMemberIds, memberId]);
    }).toList();

    await _box.put(groupId, group.copyWith(splits: splits));
    _save();
  }
}

final groupsProvider = NotifierProvider<GroupsNotifier, List<Group>>(
  GroupsNotifier.new,
);

// ── Single group provider ─────────────────────────────────────────────────────
final groupProvider = Provider.family<Group?, String>((ref, id) {
  ref.watch(groupsProvider); // rebuild when groups change
  final box = ref.read(groupBoxProvider);
  return box.get(id);
});

// ── Single split provider ─────────────────────────────────────────────────────
final splitProvider =
    Provider.family<SplitSession?, ({String groupId, String splitId})>(
  (ref, params) {
    final group = ref.watch(groupProvider(params.groupId));
    return group?.splits
        .cast<SplitSession?>()
        .firstWhere((s) => s?.id == params.splitId, orElse: () => null);
  },
);

// ── Theme provider ────────────────────────────────────────────────────────────
final themeProvider = StateProvider<bool>((ref) => true); // true = dark
