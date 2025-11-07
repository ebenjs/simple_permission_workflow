import 'package:flutter_test/flutter_test.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';
import 'package:simple_permission_workflow/simple_permission_workflow.dart';
import 'package:simple_permission_workflow/simple_permission_workflow_platform_interface.dart';
import 'package:simple_permission_workflow/simple_permission_workflow_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSimplePermissionWorkflowPlatform
    with MockPlatformInterfaceMixin
    implements SimplePermissionWorkflowPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
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

  test('getPlatformVersion', () async {
    SimplePermissionWorkflow simplePermissionWorkflowPlugin =
        SimplePermissionWorkflow();
    MockSimplePermissionWorkflowPlatform fakePlatform =
        MockSimplePermissionWorkflowPlatform();
    SimplePermissionWorkflowPlatform.instance = fakePlatform;

    expect(await simplePermissionWorkflowPlugin.getPlatformVersion(), '42');
  });

  // test('launchWorkflow', () async {
  //   SimplePermissionWorkflow simplePermissionWorkflowPlugin =
  //       SimplePermissionWorkflow();
  //   MockSimplePermissionWorkflowPlatform fakePlatform =
  //       MockSimplePermissionWorkflowPlatform();
  //   SimplePermissionWorkflowPlatform.instance = fakePlatform;
  //   final SPWResponse mpckResponse = SPWResponse()
  //     ..granted = true
  //     ..reason = 'granted';
  //
  //   expect(await simplePermissionWorkflowPlugin.getPlatformVersion(), '42');
  //
  //   expect(
  //     simplePermissionWorkflowPlugin.launchWorkflow(SPWPermission.location),
  //     throwsArgumentError,
  //   );
  //
  //   final SPWResponse res = await simplePermissionWorkflowPlugin.launchWorkflow(
  //     SPWPermission.contacts,
  //   );
  //   expect(res.granted, isTrue);
  //   expect(res.reason, equals('granted'));
  // });
}
