import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/services/ephemeris_download_service.dart';

void main() {
  group('EphemerisDownloadService recovery', () {
    late Directory temporaryDirectory;
    late Directory kernelDirectory;
    late EphemerisDownloadService service;
    late EphemerisKernel kernel;
    late File target;
    late File backup;

    final verifiedBytes = utf8.encode('verified-kernel-fixture');
    late String checksum;

    setUp(() async {
      temporaryDirectory =
          await Directory.systemTemp.createTemp('horoskopium-eph-test-');
      kernelDirectory = Directory('${temporaryDirectory.path}/ephemerides');
      await kernelDirectory.create();
      checksum = sha256.convert(verifiedBytes).toString();
      kernel = EphemerisKernel(
        id: 'fixture',
        fileName: 'fixture.bsp',
        title: 'Fixture',
        coverage: 'test',
        sizeLabel: 'test',
        url: 'https://example.invalid/fixture.bsp',
        sha256: checksum,
      );
      target = File('${kernelDirectory.path}/${kernel.fileName}');
      backup = File('${target.path}.bak');
      service = EphemerisDownloadService(
        supportDirectoryProvider: () async => temporaryDirectory,
      );
    });

    tearDown(() async {
      if (await temporaryDirectory.exists()) {
        await temporaryDirectory.delete(recursive: true);
      }
    });

    test('restores a verified backup when target is missing', () async {
      await backup.writeAsBytes(verifiedBytes);

      final installed = await service.installedPath(kernel);

      expect(installed, target.path);
      expect(await target.readAsBytes(), verifiedBytes);
      expect(await backup.exists(), isFalse);
    });

    test('restores verified backup over a damaged target', () async {
      await target.writeAsString('damaged-new-file');
      await backup.writeAsBytes(verifiedBytes);

      final installed = await service.installedPath(kernel);

      expect(installed, target.path);
      expect(await target.readAsBytes(), verifiedBytes);
      expect(await backup.exists(), isFalse);
    });

    test('keeps a valid target and removes stale backup', () async {
      await target.writeAsBytes(verifiedBytes);
      await backup.writeAsString('stale-backup');

      final installed = await service.installedPath(kernel);

      expect(installed, target.path);
      expect(await target.readAsBytes(), verifiedBytes);
      expect(await backup.exists(), isFalse);
    });

    test('removes invalid target when no verified backup exists', () async {
      await target.writeAsString('damaged-file');
      await backup.writeAsString('also-damaged');

      final installed = await service.installedPath(kernel);

      expect(installed, isNull);
      expect(await target.exists(), isFalse);
      expect(await backup.exists(), isFalse);
    });
  });
}
