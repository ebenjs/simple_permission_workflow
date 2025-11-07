import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';
import 'package:simple_permission_workflow/services/impl/contacts_permission_service.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

import 'simple_permission_workflow_platform_interface.dart';

class SimplePermissionWorkflow {
  BuildContext? _buildContext;
  Widget? _rationaleWidget;
  Widget? _permanentlyDeniedRationaleWidget;

  Future<String?> getPlatformVersion() {
    return SimplePermissionWorkflowPlatform.instance.getPlatformVersion();
  }

  SimplePermissionWorkflow([
    Map<SPWPermission, SPWPermissionService Function()>? factory,
  ]) {
    _factory =
        factory ?? {SPWPermission.contacts: () => SPWContactsPermission()};
  }

  SimplePermissionWorkflow withRationale({
    required BuildContext buildContext,
    required Widget rationaleWidget,
    Widget? permanentlyDeniedRationaleWidget,
  }) {
    _buildContext = buildContext;
    _rationaleWidget = rationaleWidget;
    _permanentlyDeniedRationaleWidget = permanentlyDeniedRationaleWidget;
    return this;
  }

  Future<SPWResponse> launchWorkflow(SPWPermission permission) async {
    final factory = _factory[permission];
    if (factory == null) {
      throw ArgumentError(
        'Service not found for permission type ${permission.toString()}',
      );
    }
    final service = factory();

    SPWResponse spwResponse = SPWResponse();

    PermissionStatus checkStatus = await service.checkStatus();

    if (checkStatus == PermissionStatus.granted) {
      spwResponse.granted = true;
      spwResponse.reason = "already granted";
    } else if (checkStatus == PermissionStatus.denied) {
      spwResponse.granted = false;
      spwResponse.reason = "permission denied";
      if (_rationaleWidget != null && _buildContext != null) {
        await _showCustomDialog(
          context: _buildContext!,
          dialog: _rationaleWidget!,
        );
      }
      PermissionStatus requestResult = await service.request();
      if (requestResult.isGranted) {
        spwResponse.granted = true;
        spwResponse.reason = "granted after permission request";
      } else if (requestResult.isDenied) {
        spwResponse.granted = false;
        spwResponse.reason = "permission denied after request";
      } else if (requestResult.isPermanentlyDenied) {
        spwResponse.granted = false;
        spwResponse.reason = "permanently denied after request";
        if (_permanentlyDeniedRationaleWidget != null && _buildContext != null) {
          await _showCustomDialog(
            context: _buildContext!,
            dialog: _permanentlyDeniedRationaleWidget!,
          );
        }
        await openAppSettings();
      }
    } else if (checkStatus == PermissionStatus.permanentlyDenied) {
      spwResponse.granted = false;
      spwResponse.reason = "permanently denied";
      if (_permanentlyDeniedRationaleWidget != null && _buildContext != null) {
        await _showCustomDialog(
          context: _buildContext!,
          dialog: _permanentlyDeniedRationaleWidget!,
        );
      }
      await openAppSettings();
    }

    return spwResponse;
  }

  Map<SPWPermission, SPWPermissionService Function()> _factory = {
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
