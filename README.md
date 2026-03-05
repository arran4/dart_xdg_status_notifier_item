[![Pub Package](https://img.shields.io/pub/v/dart_xdg_status_notifier_item.svg)](https://pub.dev/packages/dart_xdg_status_notifier_item)
[![codecov](https://codecov.io/gh/canonical/xdg_status_notifier_item.dart/branch/main/graph/badge.svg?token=QW1N0AQQOY)](https://codecov.io/gh/canonical/xdg_status_notifier_item.dart)

This is a fork of the original [xdg_status_notifier_item](https://pub.dev/packages/xdg_status_notifier_item) package.

Allows status notifications (i.e. system tray) on Linux desktops using the [StatusNotifierItem specification](https://www.freedesktop.org/wiki/Specifications/StatusNotifierItem/).

## Installation

### Add to `pubspec.yaml`
```yaml
dependencies:
  dart_xdg_status_notifier_item: ^0.0.1
```

### Or using `dart pub add`
```bash
dart pub add dart_xdg_status_notifier_item
```

### Or using `flutter pub add`
```bash
flutter pub add dart_xdg_status_notifier_item
```

## Sample

```dart
import 'package:dart_xdg_status_notifier_item/xdg_status_notifier_item.dart';

late final StatusNotifierItemClient client;

void main() async {
  client = StatusNotifierItemClient(
      id: 'test-client',
      iconName: 'computer-fail-symbolic',
      menu: DBusMenuItem(children: [
        DBusMenuItem(label: 'Hello'),
        DBusMenuItem(label: 'World', enabled: false),
        DBusMenuItem.separator(),
        DBusMenuItem(
            label: 'Quit', onClicked: () async => await client.close()),
      ]));
  await client.connect();
}
```

## Contributing to xdg_status_notifier_item.dart

We welcome contributions! 
