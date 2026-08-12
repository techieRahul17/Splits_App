import 'package:hive/hive.dart';

part 'models.g.dart';

// ── Member ────────────────────────────────────────────────────────────────────
@HiveType(typeId: 0)
class Member extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? upiId;

  @HiveField(3)
  String? upiName;

  Member({
    required this.id,
    required this.name,
    this.upiId,
    this.upiName,
  });

  Member copyWith({String? id, String? name, String? upiId, String? upiName}) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      upiId: upiId ?? this.upiId,
      upiName: upiName ?? this.upiName,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'upiId': upiId,
        'upiName': upiName,
      };
}

// ── ItemShare ─────────────────────────────────────────────────────────────────
@HiveType(typeId: 1)
class ItemShare extends HiveObject {
  @HiveField(0)
  String memberId;

  @HiveField(1)
  double amount;

  @HiveField(2)
  bool locked;

  ItemShare({
    required this.memberId,
    required this.amount,
    this.locked = false,
  });

  ItemShare copyWith({String? memberId, double? amount, bool? locked}) {
    return ItemShare(
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      locked: locked ?? this.locked,
    );
  }
}

// ── SplitItem ─────────────────────────────────────────────────────────────────
@HiveType(typeId: 2)
class SplitItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  List<String> includedMemberIds;

  @HiveField(4)
  List<ItemShare> shares;

  SplitItem({
    required this.id,
    required this.name,
    required this.price,
    required this.includedMemberIds,
    required this.shares,
  });

  SplitItem copyWith({
    String? id,
    String? name,
    double? price,
    List<String>? includedMemberIds,
    List<ItemShare>? shares,
  }) {
    return SplitItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      includedMemberIds: includedMemberIds ?? this.includedMemberIds,
      shares: shares ?? this.shares,
    );
  }
}

// ── SplitSession ──────────────────────────────────────────────────────────────
@HiveType(typeId: 3)
class SplitSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String createdBy;

  @HiveField(3)
  String createdByName;

  @HiveField(4)
  int createdAt;

  @HiveField(5)
  String payeeId;

  @HiveField(6)
  List<SplitItem> items;

  @HiveField(7)
  String status; // 'active' | 'closed'

  @HiveField(8)
  List<String> paidMemberIds;

  SplitSession({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.payeeId,
    required this.items,
    this.status = 'active',
    required this.paidMemberIds,
  });

  SplitSession copyWith({
    String? id,
    String? name,
    String? createdBy,
    String? createdByName,
    int? createdAt,
    String? payeeId,
    List<SplitItem>? items,
    String? status,
    List<String>? paidMemberIds,
  }) {
    return SplitSession(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      payeeId: payeeId ?? this.payeeId,
      items: items ?? this.items,
      status: status ?? this.status,
      paidMemberIds: paidMemberIds ?? this.paidMemberIds,
    );
  }

  double get totalBill =>
      items.fold(0.0, (sum, item) => sum + item.price);
}

// ── Group ─────────────────────────────────────────────────────────────────────
@HiveType(typeId: 4)
class Group extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String payeeId;

  @HiveField(3)
  String currency;

  @HiveField(4)
  List<Member> members;

  @HiveField(5)
  List<SplitItem> items; // Group-level items (legacy, kept for compat)

  @HiveField(6)
  int createdAt;

  @HiveField(7)
  String ownerId;

  @HiveField(8)
  List<SplitSession> splits;

  Group({
    required this.id,
    required this.name,
    required this.payeeId,
    this.currency = '₹',
    required this.members,
    required this.items,
    required this.createdAt,
    required this.ownerId,
    required this.splits,
  });

  Group copyWith({
    String? id,
    String? name,
    String? payeeId,
    String? currency,
    List<Member>? members,
    List<SplitItem>? items,
    int? createdAt,
    String? ownerId,
    List<SplitSession>? splits,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      payeeId: payeeId ?? this.payeeId,
      currency: currency ?? this.currency,
      members: members ?? this.members,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      splits: splits ?? this.splits,
    );
  }
}

// ── Currency helpers ──────────────────────────────────────────────────────────
const kCurrencies = [
  {'symbol': '₹', 'label': 'Indian Rupee (₹)'},
  {'\$': '\$', 'label': 'US Dollar (\$)'},
  {'symbol': '€', 'label': 'Euro (€)'},
  {'symbol': '£', 'label': 'British Pound (£)'},
  {'symbol': '¥', 'label': 'Japanese Yen (¥)'},
];

const kCurrencySymbols = ['₹', '\$', '€', '£', '¥'];
