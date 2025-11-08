import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';
import 'package:simple_permission_workflow/simple_permission_workflow.dart';
import 'package:simple_permission_workflow/simple_permission_workflow_method_channel.dart';
import 'package:simple_permission_workflow/simple_permission_workflow_platform_interface.dart';

class FakeService extends SPWPermissionService<FakeService> {
  final PermissionStatus checkResult;
  final PermissionStatus result;

  FakeService(this.checkResult, this.result);

  @override
  Future<PermissionStatus> request() async => result;

  @override
  Future<PermissionStatus> checkStatus() async => checkResult;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final SimplePermissionWorkflowPlatform initialPlatform =
      SimplePermissionWorkflowPlatform.instance;

  tearDown(() {
    SimplePermissionWorkflowPlatform.instance = initialPlatform;
  });

  test('$MethodChannelSimplePermissionWorkflow is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelSimplePermissionWorkflow>(),
    );
  });

  test(
    'launchWorkflow calls the correct service and returns the correct response for permission granted',
    () async {
      final plugin = SimplePermissionWorkflow({
        SPWPermission.contacts: () =>
            FakeService(PermissionStatus.denied, PermissionStatus.granted),
      });

      expect(plugin.launchWorkflow(SPWPermission.nil), throwsArgumentError);

      final res = await plugin.launchWorkflow(SPWPermission.contacts);
      expect(res.granted, isTrue);
      expect(res.reason, equals('granted after permission request'));
    },
  );

  test(
    'launchWorkflow calls the correct service and returns the correct response for permission denied',
    () async {
      final plugin = SimplePermissionWorkflow({
        SPWPermission.contacts: () =>
            FakeService(PermissionStatus.denied, PermissionStatus.denied),
      });

      expect(plugin.launchWorkflow(SPWPermission.nil), throwsArgumentError);

      final res = await plugin.launchWorkflow(SPWPermission.contacts);
      expect(res.granted, isFalse);
      expect(res.reason, equals('permission denied after request'));
    },
  );

  test(
    'launchWorkflow calls the correct service and returns the correct response for permission already granted',
    () async {
      final plugin = SimplePermissionWorkflow({
        SPWPermission.contacts: () =>
            FakeService(PermissionStatus.granted, PermissionStatus.granted),
      });

      expect(plugin.launchWorkflow(SPWPermission.nil), throwsArgumentError);

      final res = await plugin.launchWorkflow(SPWPermission.contacts);
      expect(res.granted, isTrue);
      expect(res.reason, equals('already granted'));
    },
  );
}
