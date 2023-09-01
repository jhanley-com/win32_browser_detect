import 'package:test/test.dart';
import 'package:win32_browser_detect/win32_browser_detect.dart';

void main() {
  group('A group of tests', () {
    final detect = BrowserDetect();

    setUp(() {});

    test('Get Browser', () {
      expect(detect.getDefaultBrowser, isNot(null));
    });
  });
}
