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
- [ ] Support icon data transmission over DBusMenu to render icons correctly in system trays (e.g. `icon-name` or `icon-data`).
- [ ] Better tracking of menu item changes using the correct DBusMenu signals to allow real-time updates of properties.
- [ ] Add support for dynamically loading menu item layouts asynchronously to improve startup time.

## Desktop Environments (KDE, GTK, Ayatana, etc.)
- [ ] KDE (`org.kde.StatusNotifierWatcher`): Expand KDE-specific dbusmenu features if needed.
- [x] Ayatana (`org.ayatana.StatusNotifierWatcher`): Add an `ayatana` backend enum to support Ubuntu/AppIndicator environments explicitly without relying on fallback specs.
- [ ] Ubuntu (`com.canonical.dbusmenu`): Fully support canonical dbusmenu extensions.
- [ ] Fallback support: For older desktop environments that do not support StatusNotifierItem at all, consider fallback paths (e.g., GtkStatusIcon/XEmbed), although this may be outside the pure DBus scope.

## Internal / Housekeeping
- [ ] Make `Status` an enum mapped properly in client state updates.
- [ ] Update DBus Menu item `Status` properties and manage state dynamically.
- [ ] Add tests for property changes and signal emissions once implemented.
