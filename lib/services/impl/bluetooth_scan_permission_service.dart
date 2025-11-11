import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWBluetoothScanPermission
    extends SPWPermissionService<SPWBluetoothScanPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.bluetoothScan.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.bluetoothScan.status;
  }
}
