import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWPhotosPermission extends SPWPermissionService<SPWPhotosPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.photos.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.photos.status;
  }
}
