import 'package:permission_handler/permission_handler.dart';

abstract class SPWPermissionService<T extends SPWPermissionService<T>> {
  Future<PermissionStatus> checkStatus();
  Future<PermissionStatus> request();
  T get instance => this as T;
}
