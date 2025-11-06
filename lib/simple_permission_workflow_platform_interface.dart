import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'simple_permission_workflow_method_channel.dart';

abstract class SimplePermissionWorkflowPlatform extends PlatformInterface {
  /// Constructs a SimplePermissionWorkflowPlatform.
  SimplePermissionWorkflowPlatform() : super(token: _token);

  static final Object _token = Object();

  static SimplePermissionWorkflowPlatform _instance = MethodChannelSimplePermissionWorkflow();

  /// The default instance of [SimplePermissionWorkflowPlatform] to use.
  ///
  /// Defaults to [MethodChannelSimplePermissionWorkflow].
  static SimplePermissionWorkflowPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SimplePermissionWorkflowPlatform] when
  /// they register themselves.
  static set instance(SimplePermissionWorkflowPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
