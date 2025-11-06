import 'package:simple_permission_workflow/core/spw_check_status_response.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWContactsPermission implements SPWPermissionService {
  @override
  Future<SPWResponse> request(SPWPermission permission) async {
    final SPWResponse response = SPWResponse();
    response.granted = true;
    response.reason = "Granted";
    return response;
  }

  @override
  Future<SPWCheckStatusResponse> checkStatus(SPWPermission permission) async {
    return SPWCheckStatusResponse.denied;
  }
}
