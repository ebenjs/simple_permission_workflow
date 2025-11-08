import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWLocationPermission
    extends SPWPermissionService<SPWLocationPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.location.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.location.status;
  }
}
