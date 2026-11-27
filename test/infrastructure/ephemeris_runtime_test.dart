import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/application/ports/ephemeris_engine.dart';
import 'package:horoskopium/domain/astrology/chart_calculation_input.dart';
import 'package:horoskopium/domain/astrology/chart_calculation_result.dart';
import 'package:horoskopium/infrastructure/ephemeris/ephemeris_runtime.dart';
import 'package:horoskopium/services/ephemeris_download_service.dart';

void main() {
  group('EphemerisRuntime', () {
    late Directory temporaryDirectory;
    late EphemerisKernel firstKernel;
    late EphemerisKernel secondKernel;
    late EphemerisDownloadService downloads;
    late List<int> firstBytes;
    late List<int> secondBytes;

    setUp(() async {
      temporaryDirectory =
          await Directory.systemTemp.createTemp('horoskopium-runtime-');
      firstBytes = utf8.encode('first-kernel');
      secondBytes = utf8.encode('second-kernel');
      firstKernel = _kernel('first', firstBytes);
      secondKernel = _kernel('second', secondBytes);
      downloads = EphemerisDownloadService(
        supportDirectoryProvider: () async => temporaryDirectory,
      );
      final directory = Directory('${temporaryDirectory.path}/ephemerides');
      await directory.create();
      await File('${directory.path}/first.bsp').writeAsBytes(firstBytes);
      await File('${directory.path}/second.bsp').writeAsBytes(secondBytes);
    });

    tearDown(() async {
      if (await temporaryDirectory.exists()) {
        await temporaryDirectory.delete(recursive: true);
      }
    });

    test('does not open an engine when no kernel is selected', () async {
      var opens = 0;
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        engineFactory: (_) {
          opens++;
          return _FakeEngine();
        },
      );

      expect(await runtime.restore(), isNull);
      expect(runtime.hasActiveEngine, isFalse);
      expect(opens, 0);
    });

    test('activates a kernel once and returns the same engine instance',
        () async {
      var opens = 0;
      String? savedId;
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        engineFactory: (_) {
          opens++;
          return _FakeEngine();
        },
        saveSelection: (id) async => savedId = id,
      );

      final first = await runtime.activate(firstKernel);
      final again = await runtime.activate(firstKernel);

      expect(identical(first, again), isTrue);
      expect(identical(runtime.activeEngine, first), isTrue);
      expect(runtime.activeKernelId, 'first');
      expect(savedId, 'first');
      expect(opens, 1);
    });

    test('restore after activation reuses the already-open engine', () async {
      var opens = 0;
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        loadSelection: () async => 'first',
        engineFactory: (_) {
          opens++;
          return _FakeEngine();
        },
      );

      final activated = await runtime.activate(firstKernel);
      final restored = await runtime.restore();

      expect(identical(restored, activated), isTrue);
      expect(identical(runtime.activeEngine, activated), isTrue);
      expect(opens, 1);
    });

    test('restore during activation waits for the same engine open', () async {
      var opens = 0;
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        loadSelection: () async => 'first',
        engineFactory: (_) {
          opens++;
          return _FakeEngine();
        },
      );

      final activation = runtime.activate(firstKernel);
      final restoration = runtime.restore();
      final results = await Future.wait([activation, restoration]);

      expect(identical(results[0], results[1]), isTrue);
      expect(runtime.activeKernelId, 'first');
      expect(opens, 1);
    });

    test('rejects switching kernels after one has been opened', () async {
      var opens = 0;
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        engineFactory: (_) {
          opens++;
          return _FakeEngine();
        },
      );

      await runtime.activate(firstKernel);
      await expectLater(
        runtime.activate(secondKernel),
        throwsA(isA<StateError>()),
      );

      expect(runtime.activeKernelId, 'first');
      expect(opens, 1);
    });

    test('prevents deletion of the active kernel but permits inactive files',
        () async {
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        engineFactory: (_) => _FakeEngine(),
      );
      await runtime.activate(firstKernel);

      await expectLater(
        runtime.deleteKernel(firstKernel),
        throwsA(isA<StateError>()),
      );
      await runtime.deleteKernel(secondKernel);

      expect(
        await File(
          '${temporaryDirectory.path}/ephemerides/first.bsp',
        ).exists(),
        isTrue,
      );
      expect(
        await File(
          '${temporaryDirectory.path}/ephemerides/second.bsp',
        ).exists(),
        isFalse,
      );
    });

    test('deduplicates concurrent restore calls', () async {
      var opens = 0;
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        loadSelection: () async => 'first',
        engineFactory: (_) {
          opens++;
          return _FakeEngine();
        },
      );

      final results = await Future.wait([runtime.restore(), runtime.restore()]);

      expect(identical(results[0], results[1]), isTrue);
      expect(runtime.activeKernelId, 'first');
      expect(opens, 1);
    });

    test('does not activate a missing or checksum-invalid file', () async {
      final file = File(
        '${temporaryDirectory.path}/ephemerides/first.bsp',
      );
      await file.writeAsString('corrupt');
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        engineFactory: (_) => _FakeEngine(),
      );

      await expectLater(
        runtime.activate(firstKernel),
        throwsA(isA<StateError>()),
      );

      expect(runtime.hasActiveEngine, isFalse);
    });

    test('restore reports an unknown persisted kernel without opening it',
        () async {
      var opens = 0;
      final runtime = _runtime(
        downloads,
        [firstKernel, secondKernel],
        loadSelection: () async => 'unknown-kernel',
        engineFactory: (_) {
          opens++;
          return _FakeEngine();
        },
      );

      expect(await runtime.restore(), isNull);
      expect(runtime.restoreError, isNotNull);
      expect(opens, 0);
    });
  });
}

EphemerisRuntime _runtime(
  EphemerisDownloadService downloads,
  List<EphemerisKernel> kernels, {
  required EphemerisEngineFactory engineFactory,
  LoadKernelSelection? loadSelection,
  SaveKernelSelection? saveSelection,
}) {
  return EphemerisRuntime(
    downloads: downloads,
    kernels: kernels,
    engineFactory: engineFactory,
    loadSelection: loadSelection ?? () async => null,
    saveSelection: saveSelection ?? (_) async {},
  );
}

EphemerisKernel _kernel(String id, List<int> bytes) {
  return EphemerisKernel(
    id: id,
    fileName: '$id.bsp',
    title: id,
    coverage: 'test',
    sizeLabel: 'test',
    url: 'https://example.invalid/$id.bsp',
    sha256: sha256.convert(bytes).toString(),
  );
}

class _FakeEngine implements EphemerisEngine {
  @override
  String get engineId => 'fake';

  @override
  String get engineVersion => 'test';

  @override
  Future<ChartCalculationResult> calculate(ChartCalculationInput input) {
    throw UnimplementedError();
  }
}
