import 'package:flutter/material.dart';
import 'package:simple_permission_workflow/core/spw_check_status_response.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';
import 'package:simple_permission_workflow/services/impl/contacts_permission_service.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

import 'simple_permission_workflow_platform_interface.dart';

class SimplePermissionWorkflow {
  late BuildContext _buildContext;
  late Widget? _rationalWidget;

  SimplePermissionWorkflow withRational({
    required BuildContext buildContext,
    required Widget rationalWidget,
  }) {
    _buildContext = buildContext;
    _rationalWidget = rationalWidget;
    return this;
  }

  Future<String?> getPlatformVersion() {
    return SimplePermissionWorkflowPlatform.instance.getPlatformVersion();
  }

  Future<SPWResponse> launchWorkflow(SPWPermission permission) async {
    final factory = _factory[permission];
    if (factory == null) {
      throw ArgumentError(
        'Service non trouvé pour le type ${permission.toString()}',
      );
    }
    final service = factory();

    // check status
    SPWCheckStatusResponse checkStatus = await service.checkStatus(permission);
    if (checkStatus == SPWCheckStatusResponse.denied) {
      // show context dialog
      if (_rationalWidget != null) {
        _showCustomDialog(context: _buildContext, dialog: _rationalWidget!);
      }
      // ask permission
    }

    return await service.request(permission);
  }

  final Map<SPWPermission, SPWPermissionService Function()> _factory = {
    SPWPermission.contacts: () => SPWContactsPermission(),
  };

  Future<T?> _showCustomDialog<T>({
    required BuildContext context,
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );
  }
}
