import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWCalendarFullAccessPermission
    extends SPWPermissionService<SPWCalendarFullAccessPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.calendarFullAccess.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.calendarFullAccess.status;
  }
}
