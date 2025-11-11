import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWCameraPermission extends SPWPermissionService<SPWCameraPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.camera.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.camera.status;
  }
}
