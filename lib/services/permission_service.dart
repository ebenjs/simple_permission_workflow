import 'package:simple_permission_workflow/core/spw_check_status_response.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';

abstract class SPWPermissionService {
  Future<SPWCheckStatusResponse> checkStatus(SPWPermission permission);
  Future<SPWResponse> request(SPWPermission permission);
}