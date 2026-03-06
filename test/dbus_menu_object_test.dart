import 'package:dbus/dbus.dart';
import 'package:dart_xdg_status_notifier_item/src/dbus_menu_object.dart';
import 'package:test/test.dart';

void main() {
  test(
    'DBusMenuObject out-of-bounds item id returns UnknownId error',
    () async {
      // Create a simple menu with one item.
      // Menu root is item 0.
      final rootMenu = DBusMenuItem(
        children: [
          DBusMenuItem(label: 'Item 1'), // Item 1
        ],
      );

      // Creates DBusMenuObject which registers ids recursively.
      // _items will contain 2 items: root (0), and "Item 1" (1).
      final menuObject = DBusMenuObject(DBusObjectPath('/MenuBar'), rootMenu);

      // Try to call AboutToShow with an out-of-bounds id (id = 2).
      final methodCall = DBusMethodCall(
        sender: 'org.freedesktop.DBus',
        interface: 'com.canonical.dbusmenu',
        name: 'AboutToShow',
        values: [DBusInt32(2)],
      );

      final response = await menuObject.handleMethodCall(methodCall);

      expect(response, isA<DBusMethodErrorResponse>());
      final errorResponse = response as DBusMethodErrorResponse;
      expect(errorResponse.errorName, 'com.canonical.dbusmenu.UnknownId');
    },
  );

  test('DBusMenuObject in-bounds item id returns success', () async {
    final rootMenu = DBusMenuItem(
      children: [
        DBusMenuItem(label: 'Item 1'), // Item 1
      ],
    );

    final menuObject = DBusMenuObject(DBusObjectPath('/MenuBar'), rootMenu);

    // Call AboutToShow with an in-bounds id (id = 1).
    final methodCall = DBusMethodCall(
      sender: 'org.freedesktop.DBus',
      interface: 'com.canonical.dbusmenu',
      name: 'AboutToShow',
      values: [DBusInt32(1)],
    );

    final response = await menuObject.handleMethodCall(methodCall);

    expect(response, isA<DBusMethodSuccessResponse>());
  });
}
