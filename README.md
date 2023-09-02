# Browser Detect

## Features

This package detects the Windows default browser and returns the path to the exe.

This package is for Windows only.

## Getting started

## Usage

```
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
    print("keyName: ${browser.keyName}");
    print("applicationName: ${browser.applicationName}");
    print("command: ${browser.command}");
    print("");
  });
}
```

## Additional information
