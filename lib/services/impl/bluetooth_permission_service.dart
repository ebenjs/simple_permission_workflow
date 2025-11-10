import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWBluetoothPermission
    extends SPWPermissionService<SPWBluetoothPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.bluetooth.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.bluetooth.status;
  }
}
