import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWBluetoothConnectPermission
    extends SPWPermissionService<SPWBluetoothConnectPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.bluetoothConnect.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.bluetoothConnect.status;
  }
}
