import 'dart:io';

import 'package:flutter/material.dart';

import '../services/ephemeris_download_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _downloads = EphemerisDownloadService();
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
      final path = await _downloads.installedPath(kernel);
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
      final path = await _downloads.download(
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
    await _downloads.delete(kernel);
    if (!mounted) return;
    setState(() => _installed[kernel.id] = null);
  }

  String _bytes(int value) {
    if (value >= 1024 * 1024) return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(value / 1024).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final downloading = EphemerisKernel.available
        .where((kernel) => kernel.id == _downloading)
        .firstOrNull;
    final progress = _total > 0 ? (_received / _total).clamp(0.0, 1.0) : null;

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
          const SizedBox(height: 16),
          for (final kernel in EphemerisKernel.available)
            _kernelCard(kernel, downloading, progress),
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

  Widget _kernelCard(
    EphemerisKernel kernel,
    EphemerisKernel? downloading,
    double? progress,
  ) {
    final path = _installed[kernel.id];
    final isDownloading = _downloading == kernel.id;
    final isBusy = _downloading != null;
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
                if (path != null)
                  const Chip(
                    avatar: Icon(Icons.check_circle, size: 16, color: Colors.green),
                    label: Text('Installiert'),
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
            if (path != null)
              OutlinedButton.icon(
                onPressed: isBusy ? null : () => _delete(kernel),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Vom Gerät löschen'),
              )
            else
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
