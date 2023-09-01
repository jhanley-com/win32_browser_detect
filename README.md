# Browser Detect

## Features

This package detects the Windows default browser and returns the path to the exe.

This package is for Windows only.

## Getting started

## Usage

```
import 'package:win32_browser_detect/win32_browser_detect.dart';

void main() {
	var detect = BrowserDetect();
	print("Browser: ${detect.getDefaultBrowser()}");
	print("Path: ${detect.getDefaultBrowserPath()}");
}
```

## Additional information
