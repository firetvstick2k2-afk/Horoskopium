import 'dart:async';

import 'package:flutter/material.dart';

import '../infrastructure/licensing/tsl1_license_verifier.dart';
import '../services/tsl1_license_service.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key, required this.service});

  final Tsl1LicenseService service;

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _controller = TextEditingController();
  bool _busy = false;
  Timer? _countdownTimer;
  DateTime _now = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    setState(() => _busy = true);
    final success = await widget.service.activate(_controller.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (success) {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lizenz wurde sicher aktiviert.')),
      );
    }
  }

  Future<void> _deactivate() async {
    setState(() => _busy = true);
    await widget.service.deactivate();
    if (mounted) setState(() => _busy = false);
  }

  String _statusText(LicenseStatus status, AstraliumLicense? license) {
    if (status == LicenseStatus.invalid && license?.expiresAt != null) {
      return 'Lizenz abgelaufen';
    }
    return switch (status) {
        LicenseStatus.notActivated => 'Keine Lizenz aktiviert',
        LicenseStatus.active => 'Lizenz gültig und aktiviert',
        LicenseStatus.invalid => 'Lizenz ungültig oder abgelaufen',
        LicenseStatus.storageError => 'Sicherer Speicher nicht verfügbar',
      };
  }

  String _remainingText(DateTime expiry) {
    final remaining = expiry.difference(_now);
    if (remaining <= Duration.zero) return 'Lizenz abgelaufen';
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    if (days > 0) return 'Noch ${days} ${days == 1 ? 'Tag' : 'Tage'}, ${hours} Std., ${minutes} Min.';
    if (remaining.inHours > 0) return 'Noch ${remaining.inHours} Std., ${minutes} Min.';
    if (remaining.inMinutes > 0) return 'Noch ${minutes} Min., ${seconds} Sek.';
    return 'Noch ${seconds} Sekunden';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASTRALIUM-Lizenz')),
      body: AnimatedBuilder(
        animation: widget.service,
        builder: (context, _) {
          final license = widget.service.license;
          final active = widget.service.status == LicenseStatus.active;
          final expired = widget.service.status == LicenseStatus.invalid && license?.expiresAt != null;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 54, color: Color(0xFF9A7135)),
              const SizedBox(height: 14),
              Text(
                _statusText(widget.service.status, license),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF17263D),
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (license != null && (active || expired)) ...[
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lizenztyp: ${license.type}'),
                        const SizedBox(height: 6),
                        Text('Kunde: ${license.customerName}'),
                        const SizedBox(height: 6),
                        if (license.isLifetime) ...[
                          const Text('Laufzeit: Unbegrenzt gültig'),
                        ] else ...[
                          Text('Gültig bis: ${license.expiresAt!.toLocal()}'),
                          const SizedBox(height: 8),
                          Text(
                            expired ? 'Abgelaufen' : _remainingText(license.expiresAt!),
                            style: TextStyle(
                              color: expired ? Colors.red : Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _deactivate,
                  icon: const Icon(Icons.logout),
                  label: const Text('Lizenz auf diesem Gerät deaktivieren'),
                ),
              ] else ...[
                const SizedBox(height: 24),
                const Text(
                  'Füge hier deinen TSL1-Lizenzschlüssel aus Licence Studio ein. Die Signatur wird vollständig offline geprüft.',
                  style: TextStyle(color: Color(0xFF716653), height: 1.5),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 5,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'TSL1-Lizenzschlüssel',
                    hintText: 'TSL1.…',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _busy ? null : _activate,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: Text(_busy ? 'Wird geprüft …' : 'Lizenz prüfen und aktivieren'),
                ),
              ],
              if (widget.service.status == LicenseStatus.invalid && !expired) ...[
                const SizedBox(height: 12),
                const Text(
                  'Der Schlüssel konnte nicht bestätigt werden. Prüfe, ob er vollständig kopiert wurde und noch gültig ist.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
              if (widget.service.storageError != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Fehler im sicheren Gerätespeicher: ${widget.service.storageError}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Der Lizenzschlüssel wird verschlüsselt im sicheren Speicher des Geräts abgelegt und beim nächsten App-Start erneut geprüft. Ohne gültige Lizenz bleibt die App derzeit weiterhin zugänglich; es wird noch keine globale App-Sperre aktiviert.',
                style: TextStyle(color: Color(0xFF82745F), fontSize: 12, height: 1.45),
              ),
            ],
          );
        },
      ),
    );
  }
}
