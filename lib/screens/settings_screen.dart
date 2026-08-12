import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

final _prefsBox = Hive.box<String>('prefs');

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<String, String>>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<Map<String, String>> {
  SettingsNotifier()
      : super({
          'upiId': Hive.box<String>('prefs').get('upiId') ?? '',
          'upiName': Hive.box<String>('prefs').get('upiName') ?? '',
          'displayName': Hive.box<String>('prefs').get('displayName') ?? 'You',
        });

  void save(String key, String value) {
    _prefsBox.put(key, value);
    state = {...state, key: value};
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _upiCtrl;
  late final TextEditingController _upiNameCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _nameCtrl = TextEditingController(text: s['displayName']);
    _upiCtrl = TextEditingController(text: s['upiId']);
    _upiNameCtrl = TextEditingController(text: s['upiName']);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _upiCtrl.dispose();
    _upiNameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(settingsProvider.notifier)
      ..save('displayName', _nameCtrl.text.trim())
      ..save('upiId', _upiCtrl.text.trim())
      ..save('upiName', _upiNameCtrl.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: SplitsColors.positive),
            SizedBox(width: 8),
            Text('Settings saved!'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bg,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: AppIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => context.pop(),
          ),
        ),
        title: Text('Settings',
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 17, color: p.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          SectionHeader(title: 'Profile', padding: const EdgeInsets.fromLTRB(0, 12, 0, 12)),
          AppCard(
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Avatar(
                        name: _nameCtrl.text.isEmpty ? 'You' : _nameCtrl.text,
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap a member chip in "Create Group" to set payee',
                        style: TextStyle(color: p.textTertiary, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Your Display Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),

          SectionHeader(title: 'UPI Payment'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set your UPI ID so others can pay you directly from the app.',
                  style: TextStyle(color: p.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _upiCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Your UPI ID',
                    hintText: 'e.g. rahul@upi or 9XXXXXXXXX@paytm',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _upiNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'UPI Display Name',
                    hintText: 'Name shown in the UPI app',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: _save,
              child: const Text(
                'Save Settings',
                style: TextStyle(color: SplitsColors.onGold, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SplitsColors.primary,
                    borderRadius: BorderRadius.circular(SplitsRadius.md),
                  ),
                  child: const Icon(Icons.call_split_rounded, color: SplitsColors.onGold, size: 24),
                ),
                const SizedBox(height: 10),
                Text('spLit',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 18, color: p.textPrimary)),
                Text('v1.0.0', style: TextStyle(color: p.textTertiary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  'Split bills, track expenses, pay via UPI',
                  style: TextStyle(color: p.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
