import 'dart:io';
import 'package:win32_registry/win32_registry.dart';

class BrowserDetect {
  RegistryKey? _openRegistry(RegistryHive hive, String keyName) {
    try {
      return Registry.openPath(hive, path: keyName);
    } catch (e) {
      return null;
    }
  }

  String getDefaultBrowser() {
    String keyName = '';
    String? progId;
    RegistryKey? key;

    List<String> keyNames = [
      r"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice",
      r"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice",
    ];

    for (var index = 0; index < keyNames.length; index++) {
      keyName = keyNames[index];
      key = _openRegistry(RegistryHive.currentUser, keyName);

      if (key != null) {
        progId = key.getValueAsString('ProgId');
        break;
      }
    }

    if (progId == null) {
      return "";
    }

    return progId;
  }

  String getDefaultBrowserPath() {
    String keyName = '';
    String? progId;
    RegistryKey? key;

    List<String> keyNames = [
      r"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice",
      r"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice",
    ];

    for (var index = 0; index < keyNames.length; index++) {
      keyName = keyNames[index];
      key = _openRegistry(RegistryHive.currentUser, keyName);

      if (key != null) {
        progId = key.getValueAsString('ProgId');
        break;
      }
    }

    if (progId == null) {
      return "";
    }

    keyName = r"SOFTWARE\Classes\" + progId + r"\shell\open\command";

    key = _openRegistry(RegistryHive.localMachine, keyName);

    if (key == null) {
      return "";
    }

    String? value = key.getValueAsString('');

    if (value == null) {
      return "";
    }

    // value looks like this:
    //   "C:\Program Files\Google\Chrome\Application\chrome.exe" --single-argument %1
    // Split the string on the quotes, the second part will be the path to the browser exe

    var parts = value.split('"');

    if (parts.length > 1) {
      if (File(parts[1]).existsSync()) {
        // print("$progId found");
        return parts[1];
      }
    }

    return "";
  }
}
