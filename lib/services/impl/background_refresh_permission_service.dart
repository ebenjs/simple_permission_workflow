import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWBackgroundRefreshPermission
    extends SPWPermissionService<SPWBackgroundRefreshPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.backgroundRefresh.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.backgroundRefresh.status;
  }
}
