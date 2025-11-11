import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWNotificationsPermission
    extends SPWPermissionService<SPWNotificationsPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.notification.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.notification.status;
  }
}
