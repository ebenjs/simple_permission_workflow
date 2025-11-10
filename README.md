![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/ebenjs/simple_permission_workflow?utm_source=oss&utm_medium=github&utm_campaign=ebenjs%2Fsimple_permission_workflow&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)
# simple_permission_workflow

A small Dart/Flutter library that simplifies usage of the `permission_handler` inner library by offering a centralized permission workflow (status check, rationale dialog, request, open app settings).

> Important: you must always declare the required permissions in the platform configuration files (for example `AndroidManifest.xml` for Android, `Info.plist` for iOS) before using helpers that read system data (contacts, location, etc.).

## Features
- Single workflow to check and request permissions.
- Optional rationale UI support via `withRationale`.
- Injection of service factories to replace real permission services with fakes for tests.
- Returns a structured `SPWResponse` describing the result.

## Supported permissions
The following permissions are exposed by the `SPWPermission` enum and handled by the library:

| Permission (enum) | Description | Main platforms |
|---|---|---|
| `accessMediaLocation` | Access to media location metadata (photos) | Android |
| `accessNotificationPolicy` | Access to notification policy settings (e.g. Do Not Disturb) | Android |
| `activityRecognition` | Physical activity recognition | Android |
| `appTrackingTransparency` | App Tracking Transparency (ATT) | iOS |
| `assistant` | Assistant permission (if applicable) | Android/iOS (platform dependent) |
| `audio` | Microphone / audio recording | Android/iOS |
| `contacts` | Access to device contacts | Android/iOS |
| `notifications` | Permission to send notifications | Android/iOS |
| `location` | Location (coarse/fine depending on platform) | Android/iOS |
| `photos` | Access to photos / gallery | Android/iOS |

> Note: depending on the platform and OS version, some permissions can behave differently (e.g. `limited` on iOS for photos). Make sure to add the required keys in `Info.plist` and the necessary permissions in `AndroidManifest.xml`.

## Quick highlights
- Avoids direct calls to native `permission_handler` code in tests by allowing to inject fake services.
- Designed to be small and testable.

## Installation
Add the package to your `pubspec.yaml` (adjust source as required):

```yaml
dependencies:
  simple_permission_workflow: 0.0.8
```

Then run:

```bash
flutter pub get
```

## Usage

Basic usage:

```dart
final spw = SimplePermissionWorkflow();
final response = await spw.launchWorkflow(SPWPermission.contacts);

if (response.granted) {
  // permission granted
} else {
  // handle denied or permanently denied
}
```

Using `withRationale` (optional): supply widgets to display rationale dialogs before requesting permissions.

```dart
final spw = SimplePermissionWorkflow().withRationale(
  buildContext: context,
  rationaleWidget: MyRationaleWidget(),               // shown when rationale needed
  permanentlyDeniedRationaleWidget: MyPermanentWidget(), // shown when permanently denied
  openSettingsOnDismiss: true, // optional: open app settings after dismiss
);

final response = await spw.launchWorkflow(SPWPermission.location);
```

openSettingsOnDismiss (option):

- Type: `bool`
- Default: `false`

The public parameter provided to `withRationale` is called `openSettingsOnDismiss` (internally the class uses the private field `_openSettingsOnDismiss`). When set to `true`, if the final status is `permanentlyDenied` or `restricted` (either from the initial status check or after the request), the library will first display the `permanentlyDeniedRationaleWidget` (if provided). After that dialog is dismissed (or immediately if no dialog is provided), the library will call `openAppSettings()` to open the app settings so the user can enable the permission manually.

Example enabling automatic opening of app settings after dismissing the permanently-denied rationale dialog:

```dart
final spw = SimplePermissionWorkflow().withRationale(
  buildContext: context,
  rationaleWidget: MyRationaleWidget(),
  permanentlyDeniedRationaleWidget: MyPermanentWidget(),
  openSettingsOnDismiss: true, // open settings after permanently-denied dialog dismiss
);

final response = await spw.launchWorkflow(SPWPermission.contacts);
```

Use this option thoughtfully: opening settings interrupts the app flow and may not be appropriate in all UX contexts (consider platform conventions and user expectations).

Service factory injection (recommended for testing):

```dart
final fakeResponse = SPWResponse()
  ..granted = true
  ..reason = 'granted';

final plugin = SimplePermissionWorkflow({
  SPWPermission.contacts: () => FakeContactsService(fakeResponse),
});

final res = await plugin.launchWorkflow(SPWPermission.contacts);
```

`FakeContactsService` is any implementation of `SPWPermissionService` that returns the expected `SPWResponse`.

## Contacts helper methods

The library exposes a typed way to access the concrete contacts permission service and helper methods that leverage the `fast_contacts` plugin for fast contact fetching and simple cleanup.

Example usage (explicitly shown):

```dart
final spw = SimplePermissionWorkflow();

// 1) Ensure permission is granted via workflow
final response = await spw.launchWorkflow(SPWPermission.contacts);
if (!response.granted) {
  // handle denied / permanently denied
  return;
}

// 2) Get the concrete contacts service instance (typed)
SPWContactsPermission perm =
    spw.getServiceInstance<SPWContactsPermission>(SPWPermission.contacts);

// 3) Fetch contacts (uses fast_contacts internally)
List<Contact> fetchedContacts = await perm.retrieveContacts();

// 4) Order contacts by display name
List<Contact> orderedContacts = await perm.orderContacts(fetchedContacts);

// 5) Clean up contacts: remove empty names and contacts without phones
final nonEmptyNames = await perm.removeEmptyNames(orderedContacts);
final withPhones = await perm.removeEmptyPhoneNumbers(nonEmptyNames);
```

Notes:
- `retrieveContacts()` returns a `List<Contact>` from the `fast_contacts` package.
- `orderContacts(...)` returns a new list ordered by `displayName` (case-insensitive).
- `removeEmptyNames(...)` filters out contacts whose `displayName` is empty or only whitespace.
- `removeEmptyPhoneNumbers(...)` filters out contacts that don't have at least one phone number.
- Make sure your Android `AndroidManifest.xml` and iOS `Info.plist` contain the required permission entries for reading contacts when using these helpers.

## API notes

- `SimplePermissionWorkflow([Map<SPWPermission, SPWPermissionService Function()>? factories])`
  - By default the plugin registers real service factories (e.g. `SPWContactsPermission`). Passing a map allows overriding any permission service with a factory returning a custom or fake implementation (useful for tests).

- `Future<SPWResponse> launchWorkflow(SPWPermission permission)`
  - Finds the factory for `permission`, instantiates the service and runs its `request` method. If no factory is found, it throws `ArgumentError`.

- `SimplePermissionWorkflow.withRationale(...)` supports an optional `openSettingsOnDismiss` boolean parameter (default `false`). When true, the workflow will call `openAppSettings()` after permanently denied / restricted status is shown and the permanently-denied rationale dialog (if any) is dismissed. For contacts flows that fetch or enumerate device contacts, prefer to call `retrieveContacts()` only after `launchWorkflow` returns granted to avoid platform exceptions.

## Testing

To avoid `MissingPluginException` and binding errors in tests:

1. Initialize Flutter bindings at top of your test `main()`:
```dart
TestWidgetsFlutterBinding.ensureInitialized();
```

2. Inject fake services instead of using the platform MethodChannel implementations:

```
class FakeService implements SPWPermissionService {
  final PermissionStatus status;
  FakeService(this.status);
  @override
  Future<PermissionStatus> request() async => status;
}

final plugin = SimplePermissionWorkflow({
  SPWPermission.contacts: () => FakeService(PermissionStatus.granted),
});
```

3. To test a `Future` that should throw, use the forms below (don't directly await a Future expected to throw):

```dart
expect(plugin.launchWorkflow(SPWPermission.location), throwsArgumentError);
// or
await expectLater(plugin.launchWorkflow(SPWPermission.location), throwsArgumentError);
```

4. Compare fields of `SPWResponse` (e.g. `res.granted`) rather than instance identity unless `==` is implemented.

Run tests:

```bash
flutter test
```

## Development notes

- To add a new permission type: implement an `SPWPermissionService` in `lib/services/impl/` and register its factory or override via constructor injection.
- Keep UI rationale widgets out of core logic; `withRationale` only holds references and triggers dialogs when a valid `BuildContext` is available.

## Contributing
See `CONTRIBUTING.md` for contribution guidelines and PR process.

## Changelog
See `CHANGELOG.md` for recent changes. (0.0.8 includes additional permissions added to `SPWPermission`.)

## License
Apache-2.0 — see `LICENSE` for the full text.
