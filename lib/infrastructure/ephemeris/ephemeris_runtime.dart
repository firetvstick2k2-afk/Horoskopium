import 'package:shared_preferences/shared_preferences.dart';

import '../../application/ports/ephemeris_engine.dart';
import '../../services/ephemeris_download_service.dart';
import 'hevelius_ephemeris_engine.dart';

typedef EphemerisEngineFactory = EphemerisEngine Function(String path);
typedef LoadKernelSelection = Future<String?> Function();
typedef SaveKernelSelection = Future<void> Function(String? kernelId);

/// Owns the single Hevelius engine for the lifetime of the app process.
///
/// A file opened by [HeveliusEphemerisEngine.fromSpkFilePath] remains open
/// until process exit. This owner therefore never switches or disposes an
/// active engine; changing kernels requires an app restart.
class EphemerisRuntime {
  EphemerisRuntime({
    required EphemerisDownloadService downloads,
    EphemerisEngineFactory? engineFactory,
    LoadKernelSelection? loadSelection,
    SaveKernelSelection? saveSelection,
  })  : _downloads = downloads,
        _engineFactory =
            engineFactory ?? HeveliusEphemerisEngine.fromSpkFilePath,
        _loadSelection = loadSelection ?? _loadSavedSelection,
        _saveSelection = saveSelection ?? _saveSavedSelection;

  static const _selectionKey = 'horoskopium.active_ephemeris.v1';

  final EphemerisDownloadService _downloads;
  final EphemerisEngineFactory _engineFactory;
  final LoadKernelSelection _loadSelection;
  final SaveKernelSelection _saveSelection;

  EphemerisEngine? _activeEngine;
  String? _activeKernelId;
  Future<EphemerisEngine?>? _restoreFuture;
  Future<EphemerisEngine>? _activationFuture;
  String? _activationKernelId;

  String? get activeKernelId => _activeKernelId;
  EphemerisEngine? get activeEngine => _activeEngine;
  bool get hasActiveEngine => _activeEngine != null;
  String? get persistenceWarning { return _persistenceWarning; }
  String? _persistenceWarning;
  String? restoreError;

  /// Restores the previously selected kernel once per process.
  ///
  /// Concurrent callers share the same future, preventing duplicate SPK opens.
  Future<EphemerisEngine?> restore() {
    return _restoreFuture ??= _restoreSavedKernel();
  }

  Future<EphemerisEngine?> _restoreSavedKernel() async {
    try {
      final savedId = await _loadSelection();
      if (savedId == null || savedId.isEmpty) return null;
      final matches =
          EphemerisKernel.available.where((kernel) => kernel.id == savedId);
      if (matches.isEmpty) {
        restoreError = 'Die gespeicherte Ephemeride ist unbekannt.';
        await _saveSelection(null);
        return null;
      }
      return await _openKernel(matches.first, persistSelection: false);
    } catch (error) {
      restoreError = error.toString();
      return null;
    }
  }

  /// Activates a verified, locally stored kernel exactly once.
  ///
  /// A different kernel cannot be activated after one has been opened because
  /// the underlying SPK file has no supported close operation.
  Future<EphemerisEngine> activate(EphemerisKernel kernel) async {
    final restoring = _restoreFuture;
    if (restoring != null) await restoring;

    final active = _activeEngine;
    if (active != null) {
      if (_activeKernelId == kernel.id) return active;
      throw StateError(
        'Eine andere Ephemeride ist bereits aktiv. '
        'Bitte Horoskopium neu starten, um den Kernel zu wechseln.',
      );
    }

    final pending = _activationFuture;
    if (pending != null) {
      if (_activationKernelId != kernel.id) {
        throw StateError('Eine andere Ephemeride wird gerade aktiviert.');
      }
      return pending;
    }

    final future = _openKernel(kernel, persistSelection: true);
    _activationKernelId = kernel.id;
    _activationFuture = future;
    try {
      return await future;
    } finally {
      _activationFuture = null;
      _activationKernelId = null;
    }
  }

  Future<EphemerisEngine> _openKernel(
    EphemerisKernel kernel, {
    required bool persistSelection,
  }) async {
    final catalogMatches =
        EphemerisKernel.available.where((item) => item.id == kernel.id);
    if (catalogMatches.isEmpty || catalogMatches.first.fileName != kernel.fileName) {
      throw ArgumentError.value(kernel.id, 'kernel', 'Unknown ephemeris kernel.');
    }

    final path = await _downloads.installedPath(catalogMatches.first);
    if (path == null) {
      throw StateError(
        '${kernel.title} ist nicht lokal vorhanden oder die Prüfsumme ist ungültig.',
      );
    }

    // Opening is synchronous in the current Hevelius SPK API. Store the
    // resulting engine immediately: even a later preference write failure
    // must not cause another open attempt in this process.
    final engine = _engineFactory(path);
    _activeEngine = engine;
    _activeKernelId = kernel.id;
    restoreError = null;

    if (persistSelection) {
      try {
        await _saveSelection(kernel.id);
        _persistenceWarning = null;
      } catch (error) {
        _persistenceWarning =
            'Die Ephemeride ist für diese Sitzung aktiv, konnte aber nicht '
            'für den nächsten App-Start gespeichert werden: $error';
      }
    }
    return engine;
  }

  /// Deletes only an inactive kernel. The guard is enforced below the UI.
  Future<void> deleteKernel(EphemerisKernel kernel) async {
    final restoring = _restoreFuture;
    if (restoring != null) await restoring;
    if (_activeKernelId == kernel.id ||
        _activationKernelId == kernel.id) {
      throw StateError(
        'Die aktive Ephemeride kann während dieser App-Sitzung '
        'nicht gelöscht werden. Bitte zuerst die App neu starten.',
      );
    }
    await _downloads.delete(kernel);
  }

  static Future<String?> _loadSavedSelection() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_selectionKey);
  }

  static Future<void> _saveSavedSelection(String? kernelId) async {
    final preferences = await SharedPreferences.getInstance();
    if (kernelId == null) {
      await preferences.remove(_selectionKey);
    } else {
      await preferences.setString(_selectionKey, kernelId);
    }
  }
}
