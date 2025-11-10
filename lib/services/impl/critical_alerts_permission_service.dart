import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWCriticalAlertsPermission
    extends SPWPermissionService<SPWCriticalAlertsPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.criticalAlerts.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.criticalAlerts.status;
  }
}
