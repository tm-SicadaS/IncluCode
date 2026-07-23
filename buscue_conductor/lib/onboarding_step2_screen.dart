import 'package:flutter/material.dart';

import 'app_text_field.dart';
import 'app_theme.dart';
import 'data/app_session.dart';
import 'models/app_models.dart';
import 'onboarding_step3_screen.dart';
import 'primary_button.dart';

class _StaffDraft {
  _StaffDraft();
  final name = TextEditingController();
  final phone = TextEditingController();
  final badge = TextEditingController();
  void dispose() { name.dispose(); phone.dispose(); badge.dispose(); }
}

/// Step 2 keeps a reusable staff list rather than binding a shift to one person.
/// Saved people remain in [AppSession] and can later be loaded from Firestore.
class OnboardingStep2Screen extends StatefulWidget {
  const OnboardingStep2Screen({super.key});
  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen> {
  final _busName = TextEditingController();
  final _capacity = TextEditingController();
  final _depot = TextEditingController();
  final List<_StaffDraft> _drivers = [_StaffDraft()];
  final List<_StaffDraft> _coConductors = [];
  static const _shifts = ['Morning (6:00 AM - 2:00 PM)', 'Afternoon (2:00 PM - 10:00 PM)', 'Night (10:00 PM - 6:00 AM)'];
  String _shift = _shifts.first;

  @override
  void dispose() {
    _busName.dispose(); _capacity.dispose(); _depot.dispose();
    for (final draft in [..._drivers, ..._coConductors]) { draft.dispose(); }
    super.dispose();
  }

  void _next() {
    final members = <StaffMember>[];
    void addPeople(List<_StaffDraft> drafts, StaffRole role) {
      for (final draft in drafts) {
        if (draft.name.text.trim().isEmpty && draft.phone.text.trim().isEmpty) continue;
        if (draft.name.text.trim().isEmpty || draft.phone.text.trim().isEmpty) {
          throw StateError('Complete the name and phone number for each staff member.');
        }
        members.add(StaffMember(
          id: draft.badge.text.trim().isEmpty ? draft.phone.text.trim() : draft.badge.text.trim(),
          name: draft.name.text.trim(), phone: draft.phone.text.trim(), role: role,
          badgeNumber: draft.badge.text.trim().isEmpty ? null : draft.badge.text.trim(),
        ));
      }
    }
    try { addPeople(_drivers, StaffRole.driver); addPeople(_coConductors, StaffRole.coConductor); }
    on StateError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message.toString())));
      return;
    }
    if (members.where((m) => m.role == StaffRole.driver).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one driver.')));
      return;
    }
    AppSession.instance.saveStaff(members);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnboardingStep3Screen(
      busNumber: _busName.text.trim(), shift: _shift,
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back, size: 20))]),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bus & Team Details', style: AppTextStyles.screenTitle), SizedBox(height: 4), Text('STEP 2 OF 3', style: AppTextStyles.stepLabel)])),
        const SizedBox(height: 20),
        Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('BUS DETAILS', style: AppTextStyles.sectionLabel), const SizedBox(height: 12),
          AppTextField(label: 'Bus number', hint: 'KL 08 AB 1234', icon: Icons.directions_bus_outlined, controller: _busName),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: AppTextField(label: 'Capacity', hint: '48', icon: Icons.event_seat_outlined, controller: _capacity, keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: AppTextField(label: 'Depot', hint: 'Thrissur', icon: Icons.location_city_outlined, controller: _depot))]),
          const SizedBox(height: 24),
          _staffSection('DRIVERS', _drivers, StaffRole.driver, 'Add another driver'),
          const SizedBox(height: 24),
          _staffSection('CO-CONDUCTORS', _coConductors, StaffRole.coConductor, 'Add co-conductor'),
          const SizedBox(height: 24), const Text('SHIFT TIMING', style: AppTextStyles.sectionLabel), const SizedBox(height: 8),
          DropdownButtonFormField<String>(initialValue: _shift, decoration: AppTheme.inputDecoration(hint: 'Select shift', prefixIcon: const Icon(Icons.schedule)), items: _shifts.map((shift) => DropdownMenuItem(value: shift, child: Text(shift))).toList(), onChanged: (value) => setState(() => _shift = value!)),
          const SizedBox(height: 16),
          const Text('Saved staff can be reused on another shift after Firebase is connected.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ]))),
        const SizedBox(height: 12), PrimaryButton(label: 'Next', icon: Icons.arrow_forward, onPressed: _next),
      ]),
    )),
  );

  Widget _staffSection(String title, List<_StaffDraft> drafts, StaffRole role, String addLabel) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text(title, style: AppTextStyles.sectionLabel), const SizedBox(height: 8),
    if (drafts.isEmpty) const Text('None added yet.', style: TextStyle(color: AppColors.textMuted)),
    ...List.generate(drafts.length, (index) => _staffCard(drafts[index], index, drafts, role)),
    TextButton.icon(onPressed: () => setState(() => drafts.add(_StaffDraft())), icon: const Icon(Icons.person_add_alt_outlined, size: 18), label: Text(addLabel), style: TextButton.styleFrom(alignment: Alignment.centerLeft, foregroundColor: AppColors.deepGreen)),
  ]);

  Widget _staffCard(_StaffDraft draft, int index, List<_StaffDraft> list, StaffRole role) => Card(
    margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Row(children: [Text('${role == StaffRole.driver ? 'Driver' : 'Co-conductor'} ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)), const Spacer(), if (list.length > (role == StaffRole.driver ? 1 : 0)) IconButton(onPressed: () => setState(() { final removed = list.removeAt(index); removed.dispose(); }), icon: const Icon(Icons.close, size: 18))]),
      AppTextField(label: 'Name', hint: 'Full name', icon: Icons.person_outline, controller: draft.name), const SizedBox(height: 10),
      AppTextField(label: 'Phone', hint: '98765 43210', icon: Icons.call_outlined, controller: draft.phone, keyboardType: TextInputType.phone), const SizedBox(height: 10),
      AppTextField(label: 'Badge / employee ID (optional)', hint: 'EMP-001', icon: Icons.badge_outlined, controller: draft.badge),
    ])),
  );
}
