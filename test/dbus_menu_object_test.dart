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

  test('DBusMenuObject EventGroup parses struct correctly', () async {
    final rootMenu = DBusMenuItem(
      children: [
        DBusMenuItem(label: 'Item 1'), // Item 1
      ],
    );

    final menuObject = DBusMenuObject(DBusObjectPath('/MenuBar'), rootMenu);

    // Call EventGroup with an in-bounds id (id = 1).
    final methodCall = DBusMethodCall(
      sender: 'org.freedesktop.DBus',
      interface: 'com.canonical.dbusmenu',
      name: 'EventGroup',
      values: [
        DBusArray(DBusSignature('(isvu)'), [
          DBusStruct([
            DBusInt32(1), // id
            DBusString('clicked'), // eventId
            DBusVariant(DBusString('')), // data
            DBusUint32(0), // timestamp
          ]),
        ]),
      ],
    );

    final response = await menuObject.handleMethodCall(methodCall);

    expect(response, isA<DBusMethodSuccessResponse>());
    final successResponse = response as DBusMethodSuccessResponse;
    expect(successResponse.values.length, 1);
    expect(successResponse.values[0].signature.value, 'ai');
    final idErrors = successResponse.values[0].asInt32Array().toList();
    expect(idErrors, isEmpty);
  });

  test(
    'DBusMenuObject.update throws ArgumentError if children count changes',
    () async {
      final rootMenu = DBusMenuItem(
        children: [
          DBusMenuItem(label: 'Item 1'), // Item 1
        ],
      );

      final menuObject = DBusMenuObject(DBusObjectPath('/MenuBar'), rootMenu);
      final updatedMenu = DBusMenuItem(
        children: [
          DBusMenuItem(label: 'Item 1 updated'),
          DBusMenuItem(label: 'Item 2 added'),
        ],
      );

      expect(
        () => menuObject.update(updatedMenu),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Use DBusMenuObject.replace()'),
          ),
        ),
      );
    },
  );

  test(
    'DBusMenuObject.update throws on empty-to-populated menu and points to replace',
    () async {
      final menuObject = DBusMenuObject(
        DBusObjectPath('/MenuBar'),
        DBusMenuItem(),
      );

      final populatedMenu = DBusMenuItem(
        children: [DBusMenuItem(label: 'Installed later')],
      );

      expect(
        () => menuObject.update(populatedMenu),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('DBusMenuObject.replace()'),
          ),
        ),
      );
    },
  );

  test('DBusMenuObject.replace allows structural menu changes', () async {
    final menuObject = DBusMenuObject(
      DBusObjectPath('/MenuBar'),
      DBusMenuItem(),
    );

    final replacedMenu = DBusMenuItem(
      children: [
        DBusMenuItem(
          label: 'Root item',
          children: [DBusMenuItem(label: 'Nested')],
        ),
      ],
    );

    await menuObject.replace(replacedMenu);

    final methodCall = DBusMethodCall(
      sender: 'org.freedesktop.DBus',
      interface: 'com.canonical.dbusmenu',
      name: 'GetLayout',
      values: [
        DBusInt32(0),
        DBusInt32(-1),
        DBusArray.string([]),
      ],
    );

    final response = await menuObject.handleMethodCall(methodCall);
    expect(response, isA<DBusMethodSuccessResponse>());

    final successResponse = response as DBusMethodSuccessResponse;
    final rootLayout = successResponse.values[1] as DBusStruct;
    final rootChildren = rootLayout.children[2].asArray();
    expect(rootChildren.length, 1);

    final firstChild = rootChildren.first as DBusStruct;
    final firstChildProperties = firstChild.children[1].asStringVariantDict();
    expect(firstChildProperties['label']?.asString(), 'Root item');
  });

}
