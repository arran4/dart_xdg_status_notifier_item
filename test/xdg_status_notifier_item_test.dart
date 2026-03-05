import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:xdg_status_notifier_item/xdg_status_notifier_item.dart';
import 'package:test/test.dart';

class MockNotifierWatcherObject extends DBusObject {
  final String namespace;

  MockNotifierWatcherObject(this.namespace)
      : super(DBusObjectPath('/StatusNotifierWatcher'));

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != '$namespace.StatusNotifierWatcher') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'RegisterStatusNotifierItem':
        return DBusMethodSuccessResponse();

      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

class MockNotifierWatcherServer extends DBusClient {
  late final MockNotifierWatcherObject _root;
  final String namespace;

  MockNotifierWatcherServer(DBusAddress clientAddress, this.namespace)
      : super(clientAddress) {
    _root = MockNotifierWatcherObject(namespace);
  }

  Future<void> start() async {
    await requestName('$namespace.StatusNotifierWatcher');
    await registerObject(_root);
  }
}

void main() {
  test('connect (spec backend)', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async {
      await server.close();
    });

    var watcher = MockNotifierWatcherServer(clientAddress, 'org.freedesktop');
    await watcher.start();
    addTearDown(() async {
      await watcher.close();
    });

    var client = StatusNotifierItemClient(
        id: 'test',
        backend: StatusNotifierItemBackend.spec,
        menu: DBusMenuItem(),
        bus: DBusClient(clientAddress));
    addTearDown(() async {
      await client.close();
    });
    await client.connect();
  });

  test('connect (kde backend)', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async {
      await server.close();
    });

    var watcher = MockNotifierWatcherServer(clientAddress, 'org.kde');
    await watcher.start();
    addTearDown(() async {
      await watcher.close();
    });

    var client = StatusNotifierItemClient(
        id: 'test',
        backend: StatusNotifierItemBackend.kde,
        menu: DBusMenuItem(),
        bus: DBusClient(clientAddress));
    addTearDown(() async {
      await client.close();
    });
    await client.connect();
  });
}
