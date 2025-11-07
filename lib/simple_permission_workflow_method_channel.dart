import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'simple_permission_workflow_platform_interface.dart';

/// An implementation of [SimplePermissionWorkflowPlatform] that uses method channels.
class MethodChannelSimplePermissionWorkflow
    extends SimplePermissionWorkflowPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('simple_permission_workflow');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
