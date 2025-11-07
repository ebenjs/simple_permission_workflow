import 'package:permission_handler/permission_handler.dart';

abstract class SPWPermissionService {
  Future<PermissionStatus> checkStatus();
  Future<PermissionStatus> request();
}