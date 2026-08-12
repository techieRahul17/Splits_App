import 'package:flutter_test/flutter_test.dart';

import 'package:splits_app/models/models.dart';
import 'package:splits_app/utils/split_calculator.dart';

Member _member(String id, String name) => Member(id: id, name: name);

SplitItem _item({
  required String name,
  required double price,
  required List<String> memberIds,
  List<ItemShare> shares = const [],
}) =>
    SplitItem(
      id: 'item-$name',
      name: name,
      price: price,
      includedMemberIds: memberIds,
      shares: List<ItemShare>.from(shares),
    );

void main() {
  group('computeShares', () {
    test('splits evenly when the amount divides cleanly', () {
      final item = _item(name: 'Pizza', price: 300, memberIds: ['a', 'b', 'c']);
      final shares = computeShares(item);

      expect(shares.length, 3);
      expect(shares.map((s) => s.amount), everyElement(100.0));
    });

    test('assigns the rounding remainder so shares sum to the exact price', () {
      // 100 / 3 = 33.333... — the last member must absorb the leftover cent.
      final item = _item(name: 'Cab', price: 100, memberIds: ['a', 'b', 'c']);
      final shares = computeShares(item);

      final total = shares.fold<double>(0, (sum, s) => sum + s.amount);
      expect(total, closeTo(100.0, 0.001));
      expect(shares.length, 3);
    });

    test('keeps locked shares fixed and splits the rest among the others', () {
      final item = _item(
        name: 'Dinner',
        price: 300,
        memberIds: ['a', 'b', 'c'],
        shares: [ItemShare(memberId: 'a', amount: 150, locked: true)],
      );
      final shares = computeShares(item);

      final a = shares.firstWhere((s) => s.memberId == 'a');
      expect(a.amount, 150);
      expect(a.locked, isTrue);

      // The remaining 150 is divided between b and c.
      for (final id in ['b', 'c']) {
        expect(shares.firstWhere((s) => s.memberId == id).amount, 75);
      }
      expect(shares.fold<double>(0, (sum, s) => sum + s.amount),
          closeTo(300.0, 0.001));
    });

    test('returns nothing when no members are included', () {
      expect(computeShares(_item(name: 'X', price: 50, memberIds: [])), isEmpty);
    });
  });

  group('computeSummary', () {
    test('adds up each member across every item', () {
      final members = [_member('a', 'Asha'), _member('b', 'Bala')];
      final items = [
        _item(name: 'Rice', price: 100, memberIds: ['a', 'b'], shares: [
          ItemShare(memberId: 'a', amount: 50),
          ItemShare(memberId: 'b', amount: 50),
        ]),
        // Only Asha is on this one.
        _item(name: 'Juice', price: 40, memberIds: ['a'], shares: [
          ItemShare(memberId: 'a', amount: 40),
        ]),
      ];

      final totals = computeSummary(members: members, items: items);
      expect(totals['a'], 90);
      expect(totals['b'], 50);
    });

    test('gives every member a zero entry when there are no items', () {
      final totals = computeSummary(
        members: [_member('a', 'Asha')],
        items: const [],
      );
      expect(totals['a'], 0);
    });
  });

  group('formatMoney', () {
    test('groups thousands and always shows two decimals', () {
      expect(formatMoney('₹', 1240), '₹1,240.00');
      expect(formatMoney('₹', 999), '₹999.00');
      expect(formatMoney('₹', 1234567.5), '₹1,234,567.50');
      expect(formatMoney('\$', 0), '\$0.00');
    });

    test('puts the minus sign before the currency symbol', () {
      expect(formatMoney('₹', -1240), '-₹1,240.00');
    });
  });

  group('groupOutstanding', () {
    Group buildGroup({
      required String status,
      List<String> paidMemberIds = const [],
    }) {
      final members = [
        _member('payee', 'Payee'),
        _member('a', 'Asha'),
        _member('b', 'Bala'),
      ];
      return Group(
        id: 'g1',
        name: 'Trip',
        payeeId: 'payee',
        members: members,
        items: [],
        createdAt: 0,
        ownerId: 'local',
        splits: [
          SplitSession(
            id: 's1',
            name: 'Dinner',
            createdBy: 'local',
            createdByName: 'You',
            createdAt: 0,
            payeeId: 'payee',
            status: status,
            paidMemberIds: List<String>.from(paidMemberIds),
            items: [
              _item(
                name: 'Meal',
                price: 300,
                memberIds: ['payee', 'a', 'b'],
                shares: [
                  ItemShare(memberId: 'payee', amount: 100),
                  ItemShare(memberId: 'a', amount: 100),
                  ItemShare(memberId: 'b', amount: 100),
                ],
              ),
            ],
          ),
        ],
      );
    }

    test('counts only what non-payee members still owe', () {
      // The payee's own 100 share is not debt owed to themselves.
      expect(groupOutstanding(buildGroup(status: 'active')), 200);
    });

    test('excludes members already marked paid', () {
      expect(
        groupOutstanding(buildGroup(status: 'active', paidMemberIds: ['a'])),
        100,
      );
    });

    test('ignores closed splits entirely', () {
      expect(groupOutstanding(buildGroup(status: 'closed')), 0);
    });
  });

  group('buildUpiLink', () {
    test('encodes the payee, amount and note', () {
      final link = buildUpiLink(
        payeeUpiId: 'bala@upi',
        payeeName: 'Bala M',
        amount: 250.5,
        note: 'Split: Dinner',
      );

      expect(link, startsWith('upi://pay?'));
      expect(link, contains('pa=bala%40upi'));
      expect(link, contains('am=250.50'));
      expect(link, contains('cu=INR'));
      expect(link, contains('tn=Split%3A%20Dinner'));
    });
  });
}
