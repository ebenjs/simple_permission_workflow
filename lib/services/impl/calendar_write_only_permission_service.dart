import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWCalendarWriteOnlyPermission
    extends SPWPermissionService<SPWCalendarWriteOnlyPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.calendarWriteOnly.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.calendarWriteOnly.status;
  }
}
