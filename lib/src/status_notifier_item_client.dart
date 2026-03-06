import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dbus/dbus.dart';
import 'package:logging/logging.dart';
import 'utils.dart';

import 'dbus_menu_object.dart';

/// Backend for the status notifier item.
enum StatusNotifierItemBackend {
  /// The standard FreeDesktop specification (org.freedesktop).
  spec,

  /// The KDE implementation (org.kde).
  kde,

  /// The Ayatana implementation (org.ayatana).
  ayatana,
}

/// Category for notifier items.
enum StatusNotifierItemCategory {
  applicationStatus,
  communications,
  systemServices,
  hardware,
}

/// Status for notifier items.
enum StatusNotifierItemStatus { passive, active, needsAttention }

const _categoryNames = {
  StatusNotifierItemCategory.applicationStatus: 'ApplicationStatus',
  StatusNotifierItemCategory.communications: 'Communications',
  StatusNotifierItemCategory.systemServices: 'SystemServices',
  StatusNotifierItemCategory.hardware: 'Hardware',
};

const _statusNames = {
  StatusNotifierItemStatus.passive: 'Passive',
  StatusNotifierItemStatus.active: 'Active',
  StatusNotifierItemStatus.needsAttention: 'NeedsAttention',
};

String _encodeCategory(StatusNotifierItemCategory value) =>
    _categoryNames[value] ?? '';

String _encodeStatus(StatusNotifierItemStatus value) =>
    _statusNames[value] ?? '';

/// A class representing raw image data for a status notifier item icon.
class StatusNotifierIconPixmap {
  final int width;
  final int height;
  final Uint8List pixels;

  StatusNotifierIconPixmap({
    required this.width,
    required this.height,
    required this.pixels,
  });

  DBusStruct toDBusStruct() {
    return DBusStruct([
      DBusInt32(width),
      DBusInt32(height),
      DBusArray.byte(pixels),
    ]);
  }
}

/// A class representing a tooltip for a status notifier item.
class StatusNotifierToolTip {
  final String iconName;
  final List<StatusNotifierIconPixmap> iconPixmap;
  final String title;
  final String body;

  StatusNotifierToolTip({
    required String iconName,
    required this.iconPixmap,
    required this.title,
    required this.body,
  }) : iconName = sanitizeIconName(iconName);

  DBusStruct toDBusStruct() {
    return DBusStruct([
      DBusString(iconName),
      DBusArray(
        DBusSignature('(iiay)'),
        iconPixmap.map((e) => e.toDBusStruct()),
      ),
      DBusString(title),
      DBusString(body),
    ]);
  }
}

class _StatusNotifierItemObject extends DBusObject {
  final StatusNotifierItemCategory category;
  final String id;
  String title;
  StatusNotifierItemStatus status;
  int windowId;
  bool itemIsMenu;
  String iconName;
  List<StatusNotifierIconPixmap> iconPixmap;
  String overlayIconName;
  List<StatusNotifierIconPixmap> overlayIconPixmap;
  String attentionIconName;
  List<StatusNotifierIconPixmap> attentionIconPixmap;
  String attentionMovieName;
  StatusNotifierToolTip? toolTip;
  final DBusObjectPath menu;
  Future<void> Function(int x, int y)? onContextMenu;
  Future<void> Function(int x, int y)? onActivate;
  Future<void> Function(int x, int y)? onSecondaryActivate;
  Future<void> Function(int delta, String orientation)? onScroll;

  _StatusNotifierItemObject({
    this.category = StatusNotifierItemCategory.applicationStatus,
    required this.id,
    this.title = '',
    this.status = StatusNotifierItemStatus.active,
    this.windowId = 0,
    this.itemIsMenu = false,
    this.iconName = '',
    this.iconPixmap = const [],
    this.overlayIconName = '',
    this.overlayIconPixmap = const [],
    this.attentionIconName = '',
    this.attentionIconPixmap = const [],
    this.attentionMovieName = '',
    this.toolTip,
    this.menu = DBusObjectPath.root,
    this.onContextMenu,
    this.onActivate,
    this.onSecondaryActivate,
    this.onScroll,
  }) : super(DBusObjectPath('/StatusNotifierItem'));

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(
        'org.freedesktop.StatusNotifierItem',
        methods: [
          DBusIntrospectMethod(
            'ContextMenu',
            args: [
              DBusIntrospectArgument(
                DBusSignature('i'),
                DBusArgumentDirection.in_,
                name: 'x',
              ),
              DBusIntrospectArgument(
                DBusSignature('i'),
                DBusArgumentDirection.in_,
                name: 'y',
              ),
            ],
          ),
          DBusIntrospectMethod(
            'Activate',
            args: [
              DBusIntrospectArgument(
                DBusSignature('i'),
                DBusArgumentDirection.in_,
                name: 'x',
              ),
              DBusIntrospectArgument(
                DBusSignature('i'),
                DBusArgumentDirection.in_,
                name: 'y',
              ),
            ],
          ),
          DBusIntrospectMethod(
            'SecondaryActivate',
            args: [
              DBusIntrospectArgument(
                DBusSignature('i'),
                DBusArgumentDirection.in_,
                name: 'x',
              ),
              DBusIntrospectArgument(
                DBusSignature('i'),
                DBusArgumentDirection.in_,
                name: 'y',
              ),
            ],
          ),
          DBusIntrospectMethod(
            'Scroll',
            args: [
              DBusIntrospectArgument(
                DBusSignature('i'),
                DBusArgumentDirection.in_,
                name: 'delta',
              ),
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.in_,
                name: 'orientation',
              ),
            ],
          ),
          DBusIntrospectMethod(
            'ProvideXdgActivationToken',
            args: [
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.in_,
                name: 'token',
              ),
            ],
          ),
        ],
        signals: [
          DBusIntrospectSignal('NewTitle'),
          DBusIntrospectSignal('NewIcon'),
          DBusIntrospectSignal('NewAttentionIcon'),
          DBusIntrospectSignal('NewOverlayIcon'),
          DBusIntrospectSignal('NewToolTip'),
          DBusIntrospectSignal(
            'NewStatus',
            args: [
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.out,
                name: 'status',
              ),
            ],
          ),
        ],
        properties: [
          DBusIntrospectProperty(
            'Category',
            DBusSignature('s'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'Id',
            DBusSignature('s'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'Title',
            DBusSignature('s'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'Status',
            DBusSignature('s'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'WindowId',
            DBusSignature('i'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'IconName',
            DBusSignature('s'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'IconPixmap',
            DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'OverlayIconName',
            DBusSignature('s'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'OverlayIconPixmap',
            DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'AttentionIconName',
            DBusSignature('s'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'AttentionIconPixmap',
            DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'AttentionMovieName',
            DBusSignature('s'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'ToolTip',
            DBusSignature('(sa(iiay))'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'ItemIsMenu',
            DBusSignature('b'),
            access: DBusPropertyAccess.read,
          ),
          DBusIntrospectProperty(
            'Menu',
            DBusSignature('o'),
            access: DBusPropertyAccess.read,
          ),
        ],
      ),
    ];
  }

  void emitNewTitle() {
    emitSignal('org.freedesktop.StatusNotifierItem', 'NewTitle', []);
  }

  void emitNewIcon() {
    emitSignal('org.freedesktop.StatusNotifierItem', 'NewIcon', []);
  }

  void emitNewAttentionIcon() {
    emitSignal('org.freedesktop.StatusNotifierItem', 'NewAttentionIcon', []);
  }

  void emitNewOverlayIcon() {
    emitSignal('org.freedesktop.StatusNotifierItem', 'NewOverlayIcon', []);
  }

  void emitNewToolTip() {
    emitSignal('org.freedesktop.StatusNotifierItem', 'NewToolTip', []);
  }

  void emitNewStatus(StatusNotifierItemStatus newStatus) {
    emitSignal('org.freedesktop.StatusNotifierItem', 'NewStatus', [
      DBusString(_encodeStatus(newStatus)),
    ]);
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.freedesktop.StatusNotifierItem') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'ContextMenu':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onContextMenu?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'Activate':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onActivate?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'SecondaryActivate':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onSecondaryActivate?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'Scroll':
        if (methodCall.signature != DBusSignature('is')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var delta = methodCall.values[0].asInt32();
        var orientation = methodCall.values[1].asString();
        await onScroll?.call(delta, orientation);
        return DBusMethodSuccessResponse();
      case 'ProvideXdgActivationToken':
        if (methodCall.signature != DBusSignature('s')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return DBusMethodSuccessResponse();
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  Map<String, DBusValue> get _properties => {
        'Category': DBusString(_encodeCategory(category)),
        'Id': DBusString(id),
        'Title': DBusString(title),
        'Status': DBusString(_encodeStatus(status)),
        'WindowId': DBusInt32(windowId),
        'IconName': DBusString(iconName),
        'IconPixmap': DBusArray(
          DBusSignature('(iiay)'),
          iconPixmap.map((e) => e.toDBusStruct()),
        ),
        'OverlayIconName': DBusString(overlayIconName),
        'OverlayIconPixmap': DBusArray(
          DBusSignature('(iiay)'),
          overlayIconPixmap.map((e) => e.toDBusStruct()),
        ),
        'AttentionIconName': DBusString(attentionIconName),
        'AttentionIconPixmap': DBusArray(
          DBusSignature('(iiay)'),
          attentionIconPixmap.map((e) => e.toDBusStruct()),
        ),
        'AttentionMovieName': DBusString(attentionMovieName),
        'ToolTip': toolTip?.toDBusStruct() ??
            DBusStruct([
              DBusString(''),
              DBusArray(DBusSignature('(iiay)'), []),
              DBusString(''),
              DBusString(''),
            ]),
        'ItemIsMenu': DBusBoolean(itemIsMenu),
        'Menu': menu,
      };

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface != 'org.freedesktop.StatusNotifierItem') {
      return DBusMethodErrorResponse.unknownProperty();
    }

    var value = _properties[name];
    if (value != null) {
      return DBusGetPropertyResponse(value);
    }

    return DBusMethodErrorResponse.unknownProperty();
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    return DBusGetAllPropertiesResponse(_properties);
  }
}

/// A client that registers status notifier items.
class StatusNotifierItemClient {
  final _logger = Logger('xdg_status_notifier_item');

  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  late final DBusMenuObject _menuObject;
  late final _StatusNotifierItemObject _notifierItemObject;

  // Expose notifier item object for testing purposes
  DBusObject get notifierItemObjectForTest => _notifierItemObject;
  DBusObject get menuObjectForTest => _menuObject;

  /// The backend to use.
  final StatusNotifierItemBackend _backend;

  /// Gets the current title.
  String get title => _notifierItemObject.title;

  /// Sets the title and emits a NewTitle signal.
  set title(String value) {
    if (_notifierItemObject.title != value) {
      _notifierItemObject.title = value;
      _notifierItemObject.emitNewTitle();
    }
  }

  /// Gets the current status.
  StatusNotifierItemStatus get status => _notifierItemObject.status;

  /// Sets the status and emits a NewStatus signal.
  set status(StatusNotifierItemStatus value) {
    if (_notifierItemObject.status != value) {
      _notifierItemObject.status = value;
      _notifierItemObject.emitNewStatus(value);
    }
  }

  /// Gets the current windowId.
  int get windowId => _notifierItemObject.windowId;

  /// Sets the windowId. (No DBus signal is defined for NewWindowId in the spec).
  set windowId(int value) {
    _notifierItemObject.windowId = value;
  }

  /// Gets whether this item is exclusively a menu.
  bool get itemIsMenu => _notifierItemObject.itemIsMenu;

  /// Sets whether this item is exclusively a menu.
  set itemIsMenu(bool value) {
    _notifierItemObject.itemIsMenu = value;
  }

  /// Gets the current iconName.
  String get iconName => _notifierItemObject.iconName;

  /// Sets the iconName and emits a NewIcon signal.
  set iconName(String value) {
    var sanitizedValue = sanitizeIconName(value);
    if (_notifierItemObject.iconName != sanitizedValue) {
      _notifierItemObject.iconName = sanitizedValue;
      _notifierItemObject.emitNewIcon();
    }
  }

  /// Gets the current iconPixmap.
  List<StatusNotifierIconPixmap> get iconPixmap =>
      _notifierItemObject.iconPixmap;

  /// Sets the iconPixmap and emits a NewIcon signal.
  set iconPixmap(List<StatusNotifierIconPixmap> value) {
    _notifierItemObject.iconPixmap = value;
    _notifierItemObject.emitNewIcon();
  }

  /// Gets the current overlayIconName.
  String get overlayIconName => _notifierItemObject.overlayIconName;

  /// Sets the overlayIconName and emits a NewOverlayIcon signal.
  set overlayIconName(String value) {
    var sanitizedValue = sanitizeIconName(value);
    if (_notifierItemObject.overlayIconName != sanitizedValue) {
      _notifierItemObject.overlayIconName = sanitizedValue;
      _notifierItemObject.emitNewOverlayIcon();
    }
  }

  /// Gets the current overlayIconPixmap.
  List<StatusNotifierIconPixmap> get overlayIconPixmap =>
      _notifierItemObject.overlayIconPixmap;

  /// Sets the overlayIconPixmap and emits a NewOverlayIcon signal.
  set overlayIconPixmap(List<StatusNotifierIconPixmap> value) {
    _notifierItemObject.overlayIconPixmap = value;
    _notifierItemObject.emitNewOverlayIcon();
  }

  /// Gets the current attentionIconName.
  String get attentionIconName => _notifierItemObject.attentionIconName;

  /// Sets the attentionIconName and emits a NewAttentionIcon signal.
  set attentionIconName(String value) {
    var sanitizedValue = sanitizeIconName(value);
    if (_notifierItemObject.attentionIconName != sanitizedValue) {
      _notifierItemObject.attentionIconName = sanitizedValue;
      _notifierItemObject.emitNewAttentionIcon();
    }
  }

  /// Gets the current attentionIconPixmap.
  List<StatusNotifierIconPixmap> get attentionIconPixmap =>
      _notifierItemObject.attentionIconPixmap;

  /// Sets the attentionIconPixmap and emits a NewAttentionIcon signal.
  set attentionIconPixmap(List<StatusNotifierIconPixmap> value) {
    _notifierItemObject.attentionIconPixmap = value;
    _notifierItemObject.emitNewAttentionIcon();
  }

  /// Gets the current attentionMovieName.
  String get attentionMovieName => _notifierItemObject.attentionMovieName;

  /// Sets the attentionMovieName and emits a NewAttentionIcon signal.
  set attentionMovieName(String value) {
    if (_notifierItemObject.attentionMovieName != value) {
      _notifierItemObject.attentionMovieName = value;
      _notifierItemObject.emitNewAttentionIcon();
    }
  }

  /// Gets the current toolTip.
  StatusNotifierToolTip? get toolTip => _notifierItemObject.toolTip;

  /// Sets the toolTip and emits a NewToolTip signal.
  set toolTip(StatusNotifierToolTip? value) {
    _notifierItemObject.toolTip = value;
    _notifierItemObject.emitNewToolTip();
  }

  /// Creates a new status notifier item client. If [bus] is provided connect to the given D-Bus server.
  StatusNotifierItemClient({
    required String id,
    StatusNotifierItemBackend backend = StatusNotifierItemBackend.spec,
    StatusNotifierItemCategory category =
        StatusNotifierItemCategory.applicationStatus,
    String title = '',
    StatusNotifierItemStatus status = StatusNotifierItemStatus.active,
    int windowId = 0,
    bool itemIsMenu = false,
    String iconName = '',
    List<StatusNotifierIconPixmap> iconPixmap = const [],
    String overlayIconName = '',
    List<StatusNotifierIconPixmap> overlayIconPixmap = const [],
    String attentionIconName = '',
    List<StatusNotifierIconPixmap> attentionIconPixmap = const [],
    String attentionMovieName = '',
    StatusNotifierToolTip? toolTip,
    required DBusMenuItem menu,
    Future<void> Function(int x, int y)? onContextMenu,
    Future<void> Function(int x, int y)? onActivate,
    Future<void> Function(int x, int y)? onSecondaryActivate,
    Future<void> Function(int delta, String orientation)? onScroll,
    DBusClient? bus,
  })  : _backend = backend,
        _bus = bus ?? DBusClient.session(),
        _closeBus = bus == null {
    _menuObject = DBusMenuObject(DBusObjectPath('/Menu'), menu);
    _notifierItemObject = _StatusNotifierItemObject(
      id: id,
      category: category,
      title: title,
      status: status,
      windowId: windowId,
      itemIsMenu: itemIsMenu,
      iconName: iconName,
      iconPixmap: iconPixmap,
      overlayIconName: overlayIconName,
      overlayIconPixmap: overlayIconPixmap,
      attentionIconName: attentionIconName,
      attentionIconPixmap: attentionIconPixmap,
      attentionMovieName: attentionMovieName,
      toolTip: toolTip,
      menu: _menuObject.path,
      onContextMenu: onContextMenu,
      onActivate: onActivate,
      onSecondaryActivate: onSecondaryActivate,
      onScroll: onScroll,
    );
  }

  String? _requestedName;
  DBusRemoteObject? _watcherRemoteObject;
  StreamSubscription<DBusSignal>? _hostRegisteredSubscription;

  /// Triggered when the IsStatusNotifierHostRegistered property changes or when the StatusNotifierHostRegistered signal is received.
  Future<void> Function(bool)? onHostRegisteredChanged;

  /// Returns whether a StatusNotifierHost is currently registered and running.
  Future<bool> get isHostRegistered async {
    if (_watcherRemoteObject == null) return false;
    var result = await _watcherRemoteObject!.getProperty(
      '${_getNamespace()}.StatusNotifierWatcher',
      'IsStatusNotifierHostRegistered',
    );
    return result.asBoolean();
  }

  /// Returns the protocol version of the StatusNotifierWatcher.
  Future<int> get protocolVersion async {
    if (_watcherRemoteObject == null) return -1;
    var result = await _watcherRemoteObject!.getProperty(
      '${_getNamespace()}.StatusNotifierWatcher',
      'ProtocolVersion',
    );
    return result.asInt32();
  }

  /// Returns the currently registered status notifier items.
  Future<List<String>> get registeredStatusNotifierItems async {
    if (_watcherRemoteObject == null) return [];
    var result = await _watcherRemoteObject!.getProperty(
      '${_getNamespace()}.StatusNotifierWatcher',
      'RegisteredStatusNotifierItems',
    );
    return result.asStringArray().toList();
  }

  String _getNamespace() {
    switch (_backend) {
      case StatusNotifierItemBackend.spec:
        return 'org.freedesktop';
      case StatusNotifierItemBackend.kde:
        return 'org.kde';
      case StatusNotifierItemBackend.ayatana:
        return 'org.ayatana';
    }
  }

  // Connect to D-Bus and register this notifier item.
  Future<void> connect() async {
    String namespace = _getNamespace();

    var name = '$namespace.StatusNotifierItem-$pid-1';
    var requestResult = await _bus.requestName(name);
    assert(requestResult == DBusRequestNameReply.primaryOwner);
    _requestedName = name;

    // Register the menu.
    await _bus.registerObject(_menuObject);

    // Put the item on the bus.
    await _bus.registerObject(_notifierItemObject);

    _watcherRemoteObject = DBusRemoteObject(
      _bus,
      name: '$namespace.StatusNotifierWatcher',
      path: DBusObjectPath('/StatusNotifierWatcher'),
    );

    // Register the item.
    await _bus.callMethod(
      destination: '$namespace.StatusNotifierWatcher',
      path: DBusObjectPath('/StatusNotifierWatcher'),
      interface: '$namespace.StatusNotifierWatcher',
      name: 'RegisterStatusNotifierItem',
      values: [DBusString(name)],
      replySignature: DBusSignature.empty,
    );

    // Listen for host registered signal
    _hostRegisteredSubscription = DBusSignalStream(
      _bus,
      sender: '$namespace.StatusNotifierWatcher',
      path: DBusObjectPath('/StatusNotifierWatcher'),
      interface: '$namespace.StatusNotifierWatcher',
      name: 'StatusNotifierHostRegistered',
      signature: DBusSignature.empty,
    ).listen((signal) {
      onHostRegisteredChanged?.call(true);
    });

    try {
      var hostReg = await isHostRegistered;
      _logger.info('IsStatusNotifierHostRegistered: $hostReg');
    } catch (e) {
      _logger.warning(
        'Failed to get IsStatusNotifierHostRegistered property: $e',
      );
    }
  }

  /// Updates the menu shown.
  Future<void> updateMenu(DBusMenuItem menu) async {
    await _menuObject.update(menu);
  }

  /// Gets the current menu status.
  String get menuStatus => _menuObject.status;

  /// Sets the menu status dynamically.
  set menuStatus(String value) {
    _menuObject.status = value;
  }

  /// Terminates all active connections and unregisters the item. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    await _hostRegisteredSubscription?.cancel();
    if (_requestedName != null) {
      await _bus.releaseName(_requestedName!);
      _requestedName = null;
    }
    await _bus.unregisterObject(_menuObject);
    await _bus.unregisterObject(_notifierItemObject);

    if (_closeBus) {
      await _bus.close();
    }
  }
}
