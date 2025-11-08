![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/ebenjs/simple_permission_workflow?utm_source=oss&utm_medium=github&utm_campaign=ebenjs%2Fsimple_permission_workflow&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)
# simple_permission_workflow

A small Dart/Flutter library that simplifies usage of the `permission_handler` inner library by offering a centralized permission workflow (status check, rationale dialog, request, open app settings).

## Features
- Single workflow to check and request permissions.
- Optional rationale UI support via `withRationale`.
- Injection of service factories to replace real permission services with fakes for tests.
- Returns a structured `SPWResponse` describing the result.

## Quick highlights
- Avoids direct calls to native `permission_handler` code in tests by allowing to inject fake services.
- Designed to be small and testable.

## Installation
Add the package to your `pubspec.yaml` (adjust source as required):

```yaml
dependencies:
  simple_permission_workflow:
    path: ../simple_permission_workflow
```

Then run:

```shell
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
  permanentlyDeniedRationaleWidget: MyPermanentWidget()// shown when permanently denied
);

final response = await spw.launchWorkflow(SPWPermission.location);
```

openSettingsOnDismiss (optional):

- Type: `bool`
- Default: `false`

When set to `true`, if the permission is permanently denied or restricted (either from the initial status check or after a permission request), the library will—after showing the `permanentlyDeniedRationaleWidget` (if provided) and after that dialog is dismissed—call `openAppSettings()` to open the platform app settings so the user can enable the permission manually. If no `permanentlyDeniedRationaleWidget` is provided but `openSettingsOnDismiss` is `true`, the plugin will still open the app settings when it detects a permanently denied / restricted status.

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

## API notes

- `SimplePermissionWorkflow([Map<SPWPermission, SPWPermissionService Function()>? factories])`  
  By default the plugin registers real service factories (e.g. `SPWContactsPermission`). Passing a map allows overriding any permission service with a factory returning a custom or fake implementation.

- `Future<SPWResponse> launchWorkflow(SPWPermission permission)`  
  Finds the factory for `permission`, instantiates the service and runs its `request` method. If no factory is found, it throws `ArgumentError`.

- `SimplePermissionWorkflow.withRationale(...)` supports an optional `openSettingsOnDismiss` boolean parameter. Default `false`. When true, the workflow will call `openAppSettings()` after permanently denied / restricted status is shown and the permanently-denied rationale dialog (if any) is dismissed.

## Testing

To avoid `MissingPluginException` and binding errors in tests:

1. Initialize Flutter bindings at top of your test `main()`:
```dart
TestWidgetsFlutterBinding.ensureInitialized();
```

2. Inject fake services instead of using platform `MethodChannel` based implementations:

```dart
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

3. To test a `Future` that should throw, do NOT `await` it directly. Use one of these forms:
```dart
// let expect handle the Future
expect(plugin.launchWorkflow(SPWPermission.location), throwsArgumentError);

// or await expectLater
await expectLater(plugin.launchWorkflow(SPWPermission.location), throwsArgumentError);
```

4. Compare fields of `SPWResponse` (e.g. `res.granted`) rather than instance identity unless `==` is implemented.

Run tests:

```bash
flutter test
```

## Development notes

- The project exposes `SimplePermissionWorkflowPlatform` and a MethodChannel implementation for runtime use. Tests should avoid swapping to platform MethodChannel unless the platform is properly mocked.
- To add a new permission type: implement an `SPWPermissionService` in `services/impl/`, register its factory in the default constructor map or rely on injection.
- Keep UI rationale widgets out of core logic; `withRationale` simply holds references and triggers dialogs only if a valid `BuildContext` is given.

## Contributing
See `CONTRIBUTING.md` for contribution guidelines, testing conventions and PR process.

## License
Choose a license and add it to the repository (e.g. MIT, BSD, etc.).
