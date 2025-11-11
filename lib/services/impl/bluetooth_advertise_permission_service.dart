import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWBluetoothAdvertisePermission
    extends SPWPermissionService<SPWBluetoothAdvertisePermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.bluetoothAdvertise.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.bluetoothAdvertise.status;
  }
}
