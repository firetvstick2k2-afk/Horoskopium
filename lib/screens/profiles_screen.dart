import 'package:flutter/material.dart';

import '../models/birth_profile.dart';
import '../services/profile_store.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  final _store = ProfileStore();
  List<BirthProfile> _profiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profiles = await _store.loadProfiles();
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _loading = false;
    });
  }

  Future<void> _addProfile() async {
    final profile = await showDialog<BirthProfile>(
      context: context,
      builder: (_) => const _ProfileDialog(),
    );
    if (profile == null) return;
    final updated = [..._profiles, profile];
    await _store.saveProfiles(updated);
    if (!mounted) return;
    setState(() => _profiles = updated);
  }

  Future<void> _deleteProfile(BirthProfile profile) async {
    final updated = _profiles.where((item) => item.id != profile.id).toList();
    await _store.saveProfiles(updated);
    if (!mounted) return;
    setState(() => _profiles = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geburtsprofile')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProfile,
        icon: const Icon(Icons.add),
        label: const Text('Profil anlegen'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? const _EmptyProfiles()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                  itemCount: _profiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFECE1CE),
                          foregroundColor: Color(0xFF17263D),
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(profile.name),
                        subtitle: Text(
                          '${_date(profile.birthDate)}'
                          '${profile.birthTime == null ? '' : ' · ${profile.birthTime}'}'
                          '${profile.birthPlace == null ? '' : '\n${profile.birthPlace}'}',
                        ),
                        isThreeLine: profile.birthPlace != null,
                        trailing: IconButton(
                          tooltip: 'Profil löschen',
                          onPressed: () => _deleteProfile(profile),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

class _EmptyProfiles extends StatelessWidget {
  const _EmptyProfiles();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.brightness_3_outlined, size: 54, color: Color(0xFF9A7135)),
            SizedBox(height: 16),
            Text(
              'Noch keine Geburtsprofile',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Lege ein Profil an. Deine Angaben bleiben zunächst lokal auf diesem Gerät.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF716653), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDialog extends StatefulWidget {
  const _ProfileDialog();

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _time = TextEditingController();
  final _place = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _name.dispose();
    _time.dispose();
    _place.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Geburtsdatum auswählen',
    );
    if (selected != null) setState(() => _birthDate = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _birthDate == null) return;
    final time = _time.text.trim();
    Navigator.of(context).pop(
      BirthProfile(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        birthDate: _birthDate!,
        birthTime: time.isEmpty ? null : time,
        birthPlace: _place.text.trim().isEmpty ? null : _place.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neues Geburtsprofil'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Bitte Namen eingeben' : null,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Geburtsdatum'),
                subtitle: Text(_birthDate == null ? 'Bitte auswählen' : 
                    '${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}'),
                trailing: const Icon(Icons.calendar_month),
                onTap: _chooseDate,
              ),
              TextFormField(
                controller: _time,
                decoration: const InputDecoration(
                  labelText: 'Geburtszeit (optional)',
                  hintText: 'z. B. 14:35',
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(text)
                      ? null
                      : 'Bitte HH:MM verwenden';
                },
              ),
              TextFormField(
                controller: _place,
                decoration: const InputDecoration(
                  labelText: 'Geburtsort (optional)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(onPressed: _save, child: const Text('Speichern')),
      ],
    );
  }
}
