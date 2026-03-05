# Gap Analysis: `xdg_status_notifier_item` vs `tray_manager` & `system_tray`

This document outlines the API gaps between the `xdg_status_notifier_item` Dart package and what the popular cross-platform Flutter tray plugins `tray_manager` and `system_tray` expect for their Linux implementations.

## Requirements from `tray_manager`

Based on the [tray_manager README](https://github.com/leanflutter/tray_manager), the following methods are supported and required for Linux:

- **`destroy`**: Destroys the tray icon immediately.
- **`setIcon`**: Sets the image associated with this tray icon.
- **`setContextMenu`**: Sets the context menu for this icon.

*Note: methods like `setIconPosition`, `setToolTip`, `popUpContextMenu`, and `getBounds` are explicitly marked as not supported on Linux in `tray_manager`.*

## Requirements from `system_tray`

Based on the [system_tray README](https://github.com/antler119/system_tray), the following methods are supported and required for Linux:

- **`initSystemTray`**: Initialize system tray.
- **`setSystemTrayInfo`**: Modify the tray info (specifically `icon` on Linux).
- **`setImage`**: Modify the tray image.
- **`setContextMenu`**: Set the tray context menu.
- **`destroy`**: Destroy the tray.

*Note: methods like `setTooltip`, `setTitle` / `getTitle`, `popUpContextMenu`, and `registerSystemTrayEventHandler` are explicitly marked as not supported on Linux in `system_tray`.*

## Current Capabilities of `xdg_status_notifier_item`

The `xdg_status_notifier_item` package exposes a `StatusNotifierItemClient` that wraps the underlying D-Bus properties and methods.

### What is currently supported:

1. **Initialization (`initSystemTray`)**: The client can be instantiated and registered using `client.connect()`.
2. **Context Menus (`setContextMenu`)**: The client constructor requires a `DBusMenuItem` for the menu, and `updateMenu` can be used to update it later.

### Gaps Addressed:

1. **Dynamically updating the icon (`setIcon`, `setImage`, `setSystemTrayInfo`)**:
   We now provide setters for `iconName`, `iconPixmap`, `status`, `title`, and other core properties. Using these will dynamically update the internal DBus object and emit the appropriate update signal to the active watchers.

2. **Setting icons from raw image data/pixels**:
   `StatusNotifierIconPixmap` is fully implemented and mapped to the `(iiay)` DBus signature, allowing direct transmission of raw image buffers for cross-platform app plugins like `tray_manager` and `system_tray`.

3. **Explicit Destruction (`destroy`)**:
   `StatusNotifierItemClient.close()` has been updated to explicitly release the requested D-Bus name and gracefully unregister the exposed D-Bus objects before closing the D-Bus connection. This accurately aligns with the DBus protocol specification for tearing down services.
