import 'package:flutter/material.dart';

import '../application/use_cases/calculate_profile_radix.dart';
import '../infrastructure/ephemeris/ephemeris_runtime.dart';
import '../infrastructure/location/iana_birth_chart_input_resolver.dart';

import '../domain/location/geocoded_birth_place.dart';
import '../models/birth_profile.dart';
import '../services/profile_store.dart';
import 'radix_screen.dart';
import '../infrastructure/location/open_meteo_birth_place_geocoder.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key, required this.runtime});

  final EphemerisRuntime runtime;

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  final _store = ProfileStore();
  List<BirthProfile> _profiles = [];
  bool _loading = true;
  String? _calculatingProfileId;

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

  Future<void> _calculateProfile(BirthProfile profile) async {
    final engine = widget.runtime.activeEngine;
    if (engine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte zuerst in den Einstellungen eine Ephemeride herunterladen und aktivieren.'),
        ),
      );
      return;
    }
    setState(() => _calculatingProfileId = profile.id);
    try {
      final result = await CalculateProfileRadix(
        inputResolver: IanaBirthChartInputResolver(
          geocoder: OpenMeteoBirthPlaceGeocoder(),
        ),
        engine: engine,
      )(profile);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RadixScreen(result: result)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Radix konnte nicht berechnet werden: $error')),
      );
    } finally {
      if (mounted) setState(() => _calculatingProfileId = null);
    }
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
                        onTap: _calculatingProfileId == profile.id ? null : () => _calculateProfile(profile),
                        subtitle: Text(
                          '${_date(profile.birthDate)}'
                          '${profile.birthTime == null ? '' : ' · ${profile.birthTime}'}'
                          '${profile.birthPlace == null ? '' : '\n${profile.birthPlace}'}',
                        ),
                        isThreeLine: profile.birthPlace != null,
                        trailing: _calculatingProfileId == profile.id
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
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
  final _geocoder = OpenMeteoBirthPlaceGeocoder();
  DateTime? _birthDate;
  GeocodedBirthPlace? _selectedPlace;
  bool _searchingPlace = false;

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

  Future<void> _searchBirthPlace() async {
    final query = _place.text.trim();
    if (query.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte mindestens zwei Zeichen eingeben.')),
      );
      return;
    }
    setState(() => _searchingPlace = true);
    try {
      final results = await _geocoder.search(query);
      if (!mounted) return;
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keine passenden Orte gefunden.')),
        );
        return;
      }
      final selected = await showDialog<GeocodedBirthPlace>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Geburtsort auswählen'),
          content: SizedBox(
            width: 420,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final place = results[index];
                final location = [
                  place.name,
                  if (place.country != null && place.country!.isNotEmpty) place.country!,
                ].join(', ');
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(location),
                  subtitle: Text(
                    '${place.latitudeDegrees.toStringAsFixed(4)}, '
                    '${place.longitudeDegrees.toStringAsFixed(4)} · ${place.timeZoneId}',
                  ),
                  onTap: () => Navigator.of(dialogContext).pop(place),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      );
      if (selected != null && mounted) {
        setState(() {
          _selectedPlace = selected;
          _place.text = [
            selected.name,
            if (selected.country != null && selected.country!.isNotEmpty)
              selected.country!,
          ].join(', ');
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ortssuche fehlgeschlagen: $error')),
      );
    } finally {
      if (mounted) setState(() => _searchingPlace = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _birthDate == null) return;
    if (_selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte den Geburtsort suchen und ein Ergebnis auswählen.')),
      );
      return;
    }
    final time = _time.text.trim();
    final place = _selectedPlace!;
    Navigator.of(context).pop(
      BirthProfile(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        birthDate: _birthDate!,
        birthTime: time.isEmpty ? null : time,
        birthPlace: _place.text.trim(),
        birthPlaceLatitude: place.latitudeDegrees,
        birthPlaceLongitude: place.longitudeDegrees,
        birthPlaceTimeZoneId: place.timeZoneId,
        birthPlaceCountry: place.country,
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
                  labelText: 'Geburtszeit',
                  hintText: 'z. B. 14:35',
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Für die genaue Radix-Berechnung erforderlich';
                  return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(text)
                      ? null
                      : 'Bitte HH:MM verwenden';
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _place,
                decoration: InputDecoration(
                  labelText: 'Geburtsort',
                  hintText: 'z. B. Münster',
                  suffixIcon: IconButton(
                    tooltip: 'Ort suchen',
                    onPressed: _searchingPlace ? null : _searchBirthPlace,
                    icon: _searchingPlace
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                ),
                onChanged: (_) => setState(() => _selectedPlace = null),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Bitte Geburtsort eingeben' : null,
              ),
              if (_selectedPlace != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ausgewählt: ${_selectedPlace!.timeZoneId}',
                    style: const TextStyle(color: Color(0xFF47734D), fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              const Text(
                'Für die Berechnung wird der ausgewählte Ort mit Koordinaten und historischer Zeitzone gespeichert.',
                style: TextStyle(color: Color(0xFF716653), fontSize: 12),
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
