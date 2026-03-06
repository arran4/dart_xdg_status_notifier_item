import 'dart:async';
import 'package:dart_xdg_status_notifier_item/src/dbus_menu_object.dart';
import 'package:dbus/dbus.dart';

void main() async {
  var menu = DBusMenuItem(
    children: List.generate(
        100,
        (i) => DBusMenuItem(
              label: 'Item $i',
              enabled: true,
              visible: true,
              iconName: 'icon-$i',
              status: DBusMenuStatus.normal,
              toggleState: 1,
              toggleType: 'checkmark',
              children: List.generate(
                  10,
                  (j) => DBusMenuItem(
                        label: 'Subitem $i-$j',
                      )),
            )),
  );

  var newMenu = DBusMenuItem(
    children: List.generate(
        100,
        (i) => DBusMenuItem(
              label: 'Item $i',
              enabled: i % 2 == 0,
              visible: true,
              iconName: 'icon-$i',
              status: DBusMenuStatus.normal,
              toggleState: 0,
              toggleType: 'checkmark',
              children: List.generate(
                  10,
                  (j) => DBusMenuItem(
                        label: 'Subitem $i-$j',
                      )),
            )),
  );

  var obj = DBusMenuObject(DBusObjectPath('/test'), menu);

  // Warmup
  for (var i = 0; i < 5; i++) {
    await obj.update(newMenu);
    await obj.update(menu);
  }

  // Benchmark
  var watch = Stopwatch()..start();
  for (var i = 0; i < 100; i++) {
    await obj.update(newMenu);
    await obj.update(menu);
  }
  watch.stop();

  print('Benchmark took ${watch.elapsedMilliseconds} ms');
}
