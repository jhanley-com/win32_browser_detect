import 'package:win32_browser_detect/win32_browser_detect.dart';

void main() {
  var detect = BrowserDetect();
  print("Browser: ${detect.getDefaultBrowser()}");
  print("Path: ${detect.getDefaultBrowserPath()}");
}
