import 'dart:io';
import 'package:win32_registry/win32_registry.dart';

// ################################################################################
// NOTE: This code directly accesses the Windows Registry.
//
// A better method is to probably use the Win32 AssocQueryString() function
// ################################################################################

/// This class represents the BrowserDetect interface
abstract class _BrowserDetect {
  /// Return the default browser registry entry name
  String getDefaultBrowser();

  /// Return the default browser exe path
  String getDefaultBrowserPath();

  /// Return List<Browser> for each installed browser
  List<Browser> getInstalledBrowsers();
}

/// This class represents an installed browser
class Browser {
  /// Windows Registry Hive
  String hive = '';

  /// Windows registry key name
  String keyName = '';

  /// Application name
  String applicationName = '';

  /// Application description
  String description = '';

  /// Application exe path
  String command = '';
}

/// This class supports detecting installed and default browsers
class BrowserDetect extends _BrowserDetect {
  /// Return the default browser registry entry name
  @override
  String getDefaultBrowser() {
    List<String> keyNames = [
      r"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice",
      r"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice",
    ];

    for (var index = 0; index < keyNames.length; index++) {
      var keyName = keyNames[index];

      var key = _openRegistry(RegistryHive.currentUser, keyName);

      if (key != null) {
        var progId = key.getValueAsString('ProgId');

        if (progId != null) return progId;
      }
    }

    return "";
  }

  /// Return the default browser exe path
  @override
  String getDefaultBrowserPath() {
    String keyName = '';
    String? progId;
    RegistryKey? key;

    progId = getDefaultBrowser();

    if (progId.isEmpty) return "";

    keyName = r"SOFTWARE\Classes\" + progId + r"\shell\open\command";

    key = _openRegistry(RegistryHive.localMachine, keyName);

    if (key == null) return "";

    String? value = key.getValueAsString('');

    if (value == null) return "";

    // value looks like this:
    //   "C:\Program Files\Google\Chrome\Application\chrome.exe" --single-argument %1
    // Split the string on the quotes, the second part will be the path to the browser exe

    var parts = value.split('"');

    if (parts.length == 1) {
      if (File(parts[0]).existsSync()) {
        return parts[0];
      }
    }

    if (parts.length > 1) {
      if (File(parts[1]).existsSync()) {
        return parts[1];
      }
    }

    return "";
  }

  /// Return a list of installed browsers
  @override
  List<Browser> getInstalledBrowsers() {
    List<Browser> browsers = [];
    List<Browser> list = [];
    String keyName = r"SOFTWARE\Clients\StartMenuInternet";

    list = _getInstalledBrowsersFromHive(RegistryHive.localMachine, keyName);

    for (var browser in list) {
      browser.hive = "HKLM";
      browsers.add(browser);
    }

    list = _getInstalledBrowsersFromHive(RegistryHive.currentUser, keyName);

    for (var browser in list) {
      browser.hive = "HKCU";
      browsers.add(browser);
    }

    return browsers;
  }

  RegistryKey? _openRegistry(RegistryHive hive, String keyName) {
    try {
      return Registry.openPath(hive, path: keyName);
    } catch (e) {
      return null;
    }
  }

  List<Browser> _getInstalledBrowsersFromHive(
      RegistryHive hive, String keyName) {
    List<Browser> browsers = [];
    RegistryKey? key;

    key = _openRegistry(hive, keyName);

    if (key == null) return browsers;

    for (var subkey in key.subkeyNames) {
      Browser browser = Browser();

      // Save the registry key name
      browser.keyName = subkey;

      // Get the browser default application name (required for Internet Explorer
      String keyName1 = keyName + r"\" + subkey;

      var key1 = _openRegistry(hive, keyName1);

      if (key1 != null) {
        String? applicationName = key1.getValueAsString('');

        if (applicationName != null) {
          browser.applicationName = applicationName;
        }
      }

      // Get the browser application name if it exists in the registry
      String keyName2 = keyName + r"\" + subkey + r"\Capabilities";

      var key2 = _openRegistry(hive, keyName2);

      if (key2 != null) {
        if (browser.applicationName.isEmpty) {
          String? applicationName = key2.getValueAsString('ApplicationName');

          if (applicationName != null) {
            browser.applicationName = applicationName;
          }
        }

        if (browser.description.isEmpty) {
          String? description = key2.getValueAsString('ApplicationDescription');

          if (description != null) {
            browser.description = description;
          }
        }
      }

      // Get the browser command (exe)
      String keyName3 = keyName + r"\" + subkey + r"\shell\open\command";

      var key3 = _openRegistry(hive, keyName3);

      if (key3 != null) {
        String? command = key3.getValueAsString('');

        if (command != null) {
          browser.command = command.replaceAll('"', ''); // Remove string quotes
        }
      }

      browsers.add(browser);
    }

    return browsers;
  }
}
