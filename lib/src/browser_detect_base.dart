import 'dart:io';
import 'package:win32_registry/win32_registry.dart';

/// This class represents an installed browser
class Browser {
  String keyName = '';		// Windows registry key name
  String applicationName = '';	// Application name
  String command = '';		// Exe path
}

/// This class supports detecting installed and default browsers
class BrowserDetect {
  RegistryKey? _openRegistry(RegistryHive hive, String keyName) {
    try {
      return Registry.openPath(hive, path: keyName);
    } catch (e) {
      return null;
    }
  }

  /// Return List<Browser> for each installed browser
  List<Browser> getInstalledBrowsers() {
    List<Browser> browsers = [];
    RegistryKey? key;

    String keyName = r"SOFTWARE\Clients\StartMenuInternet";

    key = _openRegistry(RegistryHive.localMachine, keyName);

    if (key == null) {
      return browsers;
    }

    for (var subkey in key.subkeyNames) {
      Browser browser = Browser();

      // Save the registry key name
      browser.keyName = subkey;

      // Get the browser application name
      String keyName2 = keyName + r"\" + subkey + r"\Capabilities";

      var key2 = _openRegistry(RegistryHive.localMachine, keyName2);

      if (key2 != null) {
        String? applicationName = key2.getValueAsString('ApplicationName');

        if (applicationName != null) {
          browser.applicationName = applicationName;
        }
      }

      // Get the browser command (exe)
      String keyName3 = keyName + r"\" + subkey + r"\shell\open\command";

      var key3 = _openRegistry(RegistryHive.localMachine, keyName3);

      if (key3 != null) {
        String? command = key3.getValueAsString('');

        if (command != null) {
          browser.command = command.replaceAll('"', '');	// Remove string quotes
        }
      }

      browsers.add(browser);
   }

   return browsers;
  }

  /// Return the default browser registry entry name
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

  /// Return the default browser exe path
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
