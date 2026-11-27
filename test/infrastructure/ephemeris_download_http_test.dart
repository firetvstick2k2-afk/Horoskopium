import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horoskopium/services/ephemeris_download_service.dart';

void main() {
  group('EphemerisDownloadService HTTP download', () {
    late Directory temporaryDirectory;
    late HttpServer? server;
    late EphemerisDownloadService service;

    final expectedBytes = utf8.encode('verified-kernel-download');

    setUp(() async {
      temporaryDirectory =
          await Directory.systemTemp.createTemp('horoskopium-http-test-');
      server = null;
      service = EphemerisDownloadService(
        supportDirectoryProvider: () async => temporaryDirectory,
      );
    });

    tearDown(() async {
      await server?.close(force: true);
      if (await temporaryDirectory.exists()) {
        await temporaryDirectory.delete(recursive: true);
      }
    });

    Future<EphemerisKernel> serve({
      int statusCode = HttpStatus.ok,
      List<int>? body,
      String? expectedSha256,
      bool omitContentLength = false,
    }) async {
      final responseBytes = body ?? expectedBytes;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server!.listen((request) async {
        request.response.statusCode = statusCode;
        if (!omitContentLength) {
          request.response.contentLength = responseBytes.length;
        }
        request.response.add(responseBytes);
        await request.response.close();
      });
      return EphemerisKernel(
        id: 'http-fixture',
        fileName: 'fixture.bsp',
        title: 'Fixture',
        coverage: 'test',
        sizeLabel: 'test',
        url: 'http://127.0.0.1:${server!.port}/fixture.bsp',
        sha256: expectedSha256 ??
            sha256.convert(expectedBytes).toString(),
      );
    }

    test('downloads, verifies and installs a complete response', () async {
      final kernel = await serve();
      final progress = <(int, int)>[];

      final installedPath = await service.download(
        kernel,
        onProgress: (received, total) => progress.add((received, total)),
      );

      final installed = File(installedPath);
      expect(await installed.readAsBytes(), expectedBytes);
      expect(await File('$installedPath.part').exists(), isFalse);
      expect(progress, isNotEmpty);
      expect(progress.last.$1, expectedBytes.length);
      expect(progress.last.$2, expectedBytes.length);
    });

    test('downloads and verifies a chunked response without Content-Length',
        () async {
      final kernel = await serve(omitContentLength: true);
      final progress = <(int, int)>[];

      final installedPath = await service.download(
        kernel,
        onProgress: (received, total) => progress.add((received, total)),
      );

      expect(await File(installedPath).readAsBytes(), expectedBytes);
      expect(progress, isNotEmpty);
      expect(progress.last.$1, expectedBytes.length);
      expect(progress.last.$2, -1);
      expect(await File('$installedPath.part').exists(), isFalse);
    });

    test('rejects non-200 HTTP responses and removes the partial file', () async {
      final kernel = await serve(statusCode: HttpStatus.serviceUnavailable);
      final partial = File(
        '${temporaryDirectory.path}/ephemerides/${kernel.fileName}.part',
      );

      await expectLater(
        service.download(kernel, onProgress: (_, __) {}),
        throwsA(isA<HttpException>()),
      );

      expect(await partial.exists(), isFalse);
      expect(await service.installedPath(kernel), isNull);
    });

    test('cleans up a network-interrupted response and preserves old data',
        () async {
      final installedDirectory =
          Directory('${temporaryDirectory.path}/ephemerides');
      await installedDirectory.create();
      final target = File('${installedDirectory.path}/fixture.bsp');
      await target.writeAsBytes(expectedBytes);

      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server!.listen((request) async {
        request.response.statusCode = HttpStatus.ok;
        request.response.contentLength = expectedBytes.length + 20;
        final socket = await request.response.detachSocket();
        socket.add(expectedBytes.take(5).toList());
        await socket.flush();
        socket.destroy();
      });
      final kernel = EphemerisKernel(
        id: 'interrupted',
        fileName: 'fixture.bsp',
        title: 'Fixture',
        coverage: 'test',
        sizeLabel: 'test',
        url: 'http://127.0.0.1:${server!.port}/fixture.bsp',
        sha256: sha256.convert(expectedBytes).toString(),
      );
      final partial = File('${target.path}.part');

      await expectLater(
        service.download(kernel, onProgress: (_, __) {}),
        throwsA(anything),
      );

      expect(await target.readAsBytes(), expectedBytes);
      expect(await partial.exists(), isFalse);
      expect(await File('${target.path}.bak').exists(), isFalse);
    });

    test('rejects a checksum mismatch and preserves an existing valid file',
        () async {
      final installedDirectory =
          Directory('${temporaryDirectory.path}/ephemerides');
      await installedDirectory.create();
      final target = File('${installedDirectory.path}/fixture.bsp');
      await target.writeAsBytes(expectedBytes);

      final kernel = await serve(
        body: utf8.encode('different-download-content'),
      );
      final partial = File('${target.path}.part');

      await expectLater(
        service.download(kernel, onProgress: (_, __) {}),
        throwsA(isA<FormatException>()),
      );

      expect(await target.readAsBytes(), expectedBytes);
      expect(await partial.exists(), isFalse);
      expect(await File('${target.path}.bak').exists(), isFalse);
    });
  });
}
