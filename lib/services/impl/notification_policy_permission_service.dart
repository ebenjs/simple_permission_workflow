import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWNotificationPolicyPermission
    extends SPWPermissionService<SPWNotificationPolicyPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.accessNotificationPolicy.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.accessNotificationPolicy.status;
  }
}
