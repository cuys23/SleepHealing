import 'package:flutter_test/flutter_test.dart';
import 'package:medyo/utils/media_url.dart';

void main() {
  const host = 'http://localhost:9080';

  test('absolute https URL is left unchanged', () {
    expect(
      normalizeMediaUrl('https://host/storage/file.jpg', host: host),
      'https://host/storage/file.jpg',
    );
  });

  test('absolute http URL is left unchanged', () {
    expect(
      normalizeMediaUrl('http://host/storage/file.jpg', host: host),
      'http://host/storage/file.jpg',
    );
  });

  test('leading-slash storage path gets the host prepended', () {
    expect(
      normalizeMediaUrl('/storage/file.jpg', host: host),
      'http://localhost:9080/storage/file.jpg',
    );
  });

  test('relative storage path (no leading slash) gets the host prepended', () {
    expect(
      normalizeMediaUrl('storage/file.jpg', host: host),
      'http://localhost:9080/storage/file.jpg',
    );
  });

  test('bare relative path gets /storage/ inserted, not duplicated', () {
    expect(
      normalizeMediaUrl('images/file.jpg', host: host),
      'http://localhost:9080/storage/images/file.jpg',
    );
  });

  test('null returns null', () {
    expect(normalizeMediaUrl(null, host: host), isNull);
  });

  test('empty string returns null', () {
    expect(normalizeMediaUrl('', host: host), isNull);
    expect(normalizeMediaUrl('   ', host: host), isNull);
  });

  test('a raw filesystem path is rejected rather than passed through', () {
    expect(normalizeMediaUrl('/var/www/storage/app/file.jpg', host: host), isNull);
    expect(normalizeMediaUrl(r'C:\project\storage\file.jpg', host: host), isNull);
  });

  test('does not duplicate the storage segment for a full path already containing it', () {
    expect(
      normalizeMediaUrl('/storage/images/albam/x.png', host: host),
      'http://localhost:9080/storage/images/albam/x.png',
    );
  });
}
