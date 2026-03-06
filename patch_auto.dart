import 'dart:io';

void main() {
  final file = File('lib/src/status_notifier_item_client.dart');
  var content = file.readAsStringSync();

  // Need to update the way connect() probes.
  // Instead of trying to register with all 3 simultaneously, which leaves dead properties and mixed watchers if successful across multiple namespaces,
  // we probe to find ONE working watcher and use it.

  print('Done');
}
