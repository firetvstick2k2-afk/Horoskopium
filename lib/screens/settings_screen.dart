import 'dart:io';

import 'package:flutter/material.dart';

import '../infrastructure/ephemeris/ephemeris_runtime.dart';
import '../services/ephemeris_download_service.dart';
import '../services/tsl1_license_service.dart';
import 'license_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.runtime, required this.licenseService});

  final EphemerisRuntime runtime;
  final Tsl1LicenseService licenseService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, String?> _installed = {};
  String? _downloading;
  int _received = 0;
  int _total = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    for (final kernel in EphemerisKernel.available) {
      final path = await widget.runtime.installedPathFor(kernel);
      if (!mounted) return;
      setState(() => _installed[kernel.id] = path);
    }
  }

  Future<void> _download(EphemerisKernel kernel) async {
    setState(() {
      _downloading = kernel.id;
      _received = 0;
      _total = 0;
      _error = null;
    });
    try {
      final path = await widget.runtime.downloadKernel(
        kernel,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _total = total;
          });
        },
      );
      if (!mounted) return;
      setState(() => _installed[kernel.id] = path);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _downloading = null);
    }
  }

  Future<void> _delete(EphemerisKernel kernel) async {
    try {
      await widget.runtime.deleteKernel(kernel);
      if (!mounted) return;
      setState(() {
        _installed[kernel.id] = null;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _activate(EphemerisKernel kernel) async {
    setState(() => _error = null);
    try {
      await widget.runtime.activate(kernel);
      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  String _bytes(int value) {
    if (value >= 1024 * 1024) return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(value / 1024).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final matches = EphemerisKernel.available
        .where((kernel) => kernel.id == _downloading)
        .toList();
    final downloading = matches.isEmpty ? null : matches.first;
    final double? progress = _total > 0
        ? (_received / _total).clamp(0.0, 1.0).toDouble()
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ASTRONOMISCHE DATEN',
            style: TextStyle(
              color: Color(0xFF9A7135),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lade die JPL-Ephemeriden einmalig auf dein Gerät. Danach stehen sie auch ohne Internetverbindung zur Verfügung.',
            style: TextStyle(color: Color(0xFF716653), height: 1.45),
          ),
          if (widget.runtime.restoreError != null) ...[
            const SizedBox(height: 12),
            Text('Wiederherstellung fehlgeschlagen: ${widget.runtime.restoreError}',
                style: const TextStyle(color: Colors.red)),
          ],
          if (widget.runtime.persistenceWarning != null) ...[
            const SizedBox(height: 8),
            Text(widget.runtime.persistenceWarning!,
                style: const TextStyle(color: Color(0xFF9A7135))),
          ],
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined, color: Color(0xFF9A7135)),
              title: const Text('ASTRALIUM-Lizenz', style: TextStyle(color: Color(0xFF17263D), fontWeight: FontWeight.w600)),
              subtitle: const Text('Lizenzschlüssel eingeben und Aktivierung verwalten'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LicenseScreen(service: widget.licenseService)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final kernel in EphemerisKernel.available)
            _kernelCard(kernel),
          if (downloading != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Text(
              _total > 0
                  ? '${_bytes(_received)} von ${_bytes(_total)} geladen'
                  : '${_bytes(_received)} geladen',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF716653)),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          const Text(
            'Die Dateien werden vor der Installation vollständig per SHA-256 geprüft. Beschädigte oder unvollständige Downloads werden nicht übernommen.',
            style: TextStyle(color: Color(0xFF716653), fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _kernelCard(EphemerisKernel kernel) {
    final path = _installed[kernel.id];
    final isDownloading = _downloading == kernel.id;
    final isBusy = _downloading != null;
    final isActive = widget.runtime.activeKernelId == kernel.id;
    final anotherKernelActive = widget.runtime.hasActiveEngine && !isActive;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kernel.title,
                    style: const TextStyle(
                      color: Color(0xFF17263D),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isActive)
                  const Chip(
                    avatar: Icon(Icons.stars, size: 16, color: Colors.green),
                    label: Text('Aktiv für Berechnungen'),
                  )
                else if (path != null)
                  const Chip(
                    avatar: Icon(Icons.check_circle, size: 16, color: Colors.green),
                    label: Text('Lokal gespeichert'),
                  )
                else if (kernel.id == 'de442')
                  const Chip(label: Text('Empfohlen')),
              ],
            ),
            Text(kernel.coverage, style: const TextStyle(color: Color(0xFF716653))),
            Text(kernel.sizeLabel, style: const TextStyle(color: Color(0xFF716653))),
            if (path != null)
              Text(
                'Lokal gespeichert: ${File(path).parent.path}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF82745F)),
              ),
            const SizedBox(height: 12),
            if (path != null && !isActive) ...[
              FilledButton.icon(
                onPressed: isBusy || anotherKernelActive
                    ? null
                    : () => _activate(kernel),
                icon: const Icon(Icons.play_circle_outline),
                label: Text(anotherKernelActive
                    ? 'Neustart zum Wechseln erforderlich'
                    : 'Für Berechnungen aktivieren'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : () => _delete(kernel),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Vom Gerät löschen'),
              ),
            ] else if (isActive)
              const Text('Diese Datei bleibt bis zum Beenden der App geöffnet.',
                  style: TextStyle(color: Color(0xFF716653), fontSize: 12))
            else if (path == null)
              FilledButton.icon(
                onPressed: isBusy ? null : () => _download(kernel),
                icon: isDownloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(isDownloading ? 'Wird geladen …' : 'Herunterladen'),
              ),
          ],
        ),
      ),
    );
  }
}
