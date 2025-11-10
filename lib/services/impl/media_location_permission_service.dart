import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWMediaLocationPermission
    extends SPWPermissionService<SPWMediaLocationPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.accessMediaLocation.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.accessMediaLocation.status;
  }
}
