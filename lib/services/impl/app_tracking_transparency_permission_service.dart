import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWAppTrackingTransparencyPermission
    extends SPWPermissionService<SPWAppTrackingTransparencyPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.appTrackingTransparency.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.appTrackingTransparency.status;
  }
}
