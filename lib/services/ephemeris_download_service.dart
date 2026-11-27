import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// JPL planetary kernels available for local, offline use.
class EphemerisKernel {
  const EphemerisKernel({
    required this.id,
    required this.fileName,
    required this.title,
    required this.coverage,
    required this.sizeLabel,
    required this.url,
    required this.sha256,
  });

  final String id;
  final String fileName;
  final String title;
  final String coverage;
  final String sizeLabel;
  final String url;
  final String sha256;

  static const de440s = EphemerisKernel(
    id: 'de440s',
    fileName: 'de440s.bsp',
    title: 'DE440s',
    coverage: '26.12.1849 – 22.01.2150',
    sizeLabel: 'ca. 32 MB',
    url: 'https://ssd.jpl.nasa.gov/ftp/eph/planets/bsp/de440s.bsp',
    sha256: 'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2',
  );

  static const de442 = EphemerisKernel(
    id: 'de442',
    fileName: 'de442.bsp',
    title: 'DE442',
    coverage: '1550 – 2650',
    sizeLabel: 'ca. 115 MB',
    url: 'https://ssd.jpl.nasa.gov/ftp/eph/planets/bsp/de442.bsp',
    sha256: '8d5001fab315eeff222cc51f7cf7ffcdb43fb38fb9ac73ff09e09a5b361fd388',
  );

  static const available = [de440s, de442];
}

class EphemerisDownloadService {
  Future<File> _fileFor(EphemerisKernel kernel) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/ephemerides');
    await directory.create(recursive: true);
    return File('${directory.path}/${kernel.fileName}');
  }

  Future<String?> installedPath(EphemerisKernel kernel) async {
    final file = await _fileFor(kernel);
    if (!await file.exists()) return null;
    final actual = await _sha256(file);
    if (actual != kernel.sha256) {
      await file.delete();
      return null;
    }
    return file.path;
  }

  Future<String> download(
    EphemerisKernel kernel, {
    required void Function(int received, int total) onProgress,
  }) async {
    final target = await _fileFor(kernel);
    final temporary = File('${target.path}.part');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.getUrl(Uri.parse(kernel.url));
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('JPL-Server antwortet mit HTTP ${response.statusCode}.');
      }
      final total = response.contentLength;
      var received = 0;
      final sink = temporary.openWrite();
      try {
        await for (final chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          onProgress(received, total);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      if (total > 0 && received != total) {
        throw const FormatException('Der Download ist unvollständig.');
      }
      final actual = await _sha256(temporary);
      if (actual != kernel.sha256) {
        throw const FormatException(
          'Die SHA-256-Prüfung ist fehlgeschlagen. Die Datei wurde verworfen.',
        );
      }
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
      return target.path;
    } catch (_) {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> delete(EphemerisKernel kernel) async {
    final file = await _fileFor(kernel);
    final temporary = File('${file.path}.part');
    if (await file.exists()) await file.delete();
    if (await temporary.exists()) await temporary.delete();
  }

  Future<String> _sha256(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();
}
