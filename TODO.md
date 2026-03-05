# TODO

This document lists the shortcomings and features that are not yet implemented or supported based on the StatusNotifierItem specification and the current state of desktop environments.

## StatusNotifierItem Specification

### Properties and Signals
- [x] Implement `NewTitle` signal to notify the host when `Title` changes.
- [x] Implement `NewIcon` signal to notify the host when `IconName` or `IconPixmap` changes.
- [x] Implement `NewAttentionIcon` signal to notify the host when `AttentionIconName` or `AttentionIconPixmap` changes.
- [x] Implement `NewOverlayIcon` signal to notify the host when `OverlayIconName` or `OverlayIconPixmap` changes.
- [x] Implement `NewToolTip` signal to notify the host when `ToolTip` changes.
- [x] Implement `NewStatus` signal to notify the host when `Status` changes.
- [x] Fully implement `IconPixmap`, `OverlayIconPixmap`, and `AttentionIconPixmap` properties (currently they return empty arrays).
- [x] Fully implement `ToolTip` property content serialization (currently returns an empty struct).

### Menus
- [x] Support icon data transmission over DBusMenu to render icons correctly in system trays (e.g. `icon-name` or `icon-data`).
- [x] Better tracking of menu item changes using the correct DBusMenu signals to allow real-time updates of properties.
- [x] Add support for dynamically loading menu item layouts asynchronously to improve startup time.

## Specification Coverage
- [ ] Ensure everything from `StatusNotifierItem` is fully covered (e.g., scroll events).
- [ ] Ensure everything from `StatusNotifierWatcher` is fully covered.
- [ ] Support markup AND escaping markup when it's not desired (based on the Markup spec).
- [ ] Implement data sanitizers for icons and other inputs (based on the Icons spec and real-world web details).

## Desktop Environments (KDE, GTK, Ayatana, etc.)
- [ ] KDE (`org.kde.StatusNotifierWatcher`): Implement KDE baring in mind that we are increasing the bar as to the feature set we want to support.
- [x] Ayatana (`org.ayatana.StatusNotifierWatcher`): Add an `ayatana` backend enum to support Ubuntu/AppIndicator environments explicitly without relying on fallback specs.
- [ ] Make sure backends adhere to the same interface at initialization, but in a way that doesn't limit or make using unique advanced features of a specific backend difficult.
- [ ] Ubuntu (`com.canonical.dbusmenu`): Fully support canonical dbusmenu extensions.
- [ ] Fallback support: For older desktop environments that do not support StatusNotifierItem at all, consider fallback paths (e.g., GtkStatusIcon/XEmbed), although this may be outside the pure DBus scope.

## Integration Requirements
- [x] Ensure full API support for `tray_manager` (`destroy`, `setIcon`, `setContextMenu`).
- [x] Ensure full API support for `system_tray` (`initSystemTray`, `setSystemTrayInfo`, `setImage`, `setContextMenu`, `destroy`).

## Documentation
- [ ] Add update documentation and an EXTENSIVE `README.md` with samples showing the full extent of additions.
- [ ] Ensure the `README.md` covers everything that is in `dart_libayatana_appindicator`.

## Internal / Housekeeping
- [ ] Make `Status` an enum mapped properly in client state updates.
- [ ] Update DBus Menu item `Status` properties and manage state dynamically.
- [ ] Add tests for property changes and signal emissions once implemented.
