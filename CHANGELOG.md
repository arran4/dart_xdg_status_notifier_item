# Changelog

## 1.1.1

* Clarified DBus menu update semantics: `DBusMenuObject.update()` and `StatusNotifierItemClient.updateMenu()` now explicitly document that they only support property/state updates on an unchanged menu layout.
* Added `DBusMenuObject.replace()` and `StatusNotifierItemClient.replaceMenu()` for structural menu changes (including empty-to-populated menu installation).
* Improved update invariant error messaging with actionable guidance to use `replace` for layout changes.
* Added tests covering strict `update()` invariants and structural replacement behavior.

## 1.1.0

* **Enhanced Developer Experience:** Updated `README.md` with more comprehensive examples to help new developers integrate the package more easily.
* **Improved Out-of-the-Box Compatibility:** The default backend mode is now `auto`, which includes fallbacks for `ayatana`, ensuring the status icon works correctly across a wider range of Linux desktop environments (like MATE and KDE) without manual configuration.
* **Streamlined CI/CD:** Added automated release workflows to build and upload example binaries (Linux) on GitHub release tags, and optimized CI concurrency cancellation to prevent conflicting workflow runs.
* **Code Health:** Enforced consistent code formatting (`dart format`) across the repository.

## 0.0.3

* Version bump to prepare for upcoming release

## 0.0.2

* Rename library file to `dart_xdg_status_notifier_item.dart` to match package name
* Update Dart SDK constraints

## 0.0.1

* Initial release
