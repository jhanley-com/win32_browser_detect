import 'package:win32_browser_detect/win32_browser_detect.dart';

void main() {
  print("Default Browser:");
  var detect = BrowserDetect();
  print("Browser: ${detect.getDefaultBrowser()}");
  print("Path: ${detect.getDefaultBrowserPath()}");

  print("");
  print("Installed Browsers:");
  List<Browser> browsers = detect.getInstalledBrowsers();
  for (var browser in browsers) {
    print("hive: ${browser.hive}");
    print("keyName: ${browser.keyName}");
    print("applicationName: ${browser.applicationName}");
    print("command: ${browser.command}");
    print("");
  }
}
