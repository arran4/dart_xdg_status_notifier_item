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
import 'package:dart_xdg_status_notifier_item/dart_xdg_status_notifier_item.dart';

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
### Using dynamic properties

You can change properties and signals dynamically, like the tool tip and the title:

```dart
client.title = 'New Title';
client.toolTip = StatusNotifierToolTip('icon-name', 'New Tool Tip title', 'New Tool Tip body');
client.status = StatusNotifierItemStatus.passive;
```

### Supported environments
The library supports the FreeDesktop specification `org.freedesktop`, KDE `org.kde` and Ayatana `org.ayatana` implementation.
You can specify the backend at initialization:

```dart
  client = StatusNotifierItemClient(
      id: 'test-client',
      backend: StatusNotifierItemBackend.auto,
      iconName: 'computer-fail-symbolic',
      menu: DBusMenuItem(children: [
        DBusMenuItem(label: 'Hello'),
        DBusMenuItem(label: 'World', enabled: false),
        DBusMenuItem.separator(),
        DBusMenuItem(
            label: 'Quit', onClicked: () async => await client.close()),
      ]));
```
