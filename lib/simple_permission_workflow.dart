import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';
import 'package:simple_permission_workflow/services/impl/contacts_permission_service.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

import 'simple_permission_workflow_platform_interface.dart';

class SimplePermissionWorkflow {
  BuildContext? _buildContext;
  late Widget? _rationalWidget;
  late Widget? _permanentlyDeniedRationalWidget;

  SimplePermissionWorkflow withRationale({
    required BuildContext buildContext,
    required Widget rationalWidget,
    Widget? permanentlyDeniedRationalWidget,
  }) {
    _buildContext = buildContext;
    _rationalWidget = rationalWidget;
    _permanentlyDeniedRationalWidget = permanentlyDeniedRationalWidget;
    return this;
  }

  Future<String?> getPlatformVersion() {
    return SimplePermissionWorkflowPlatform.instance.getPlatformVersion();
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
      if (_rationalWidget != null && _buildContext != null) {
        await _showCustomDialog(
          context: _buildContext!,
          dialog: _rationalWidget!,
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
        if (_permanentlyDeniedRationalWidget != null && _buildContext != null) {
          await _showCustomDialog(
            context: _buildContext!,
            dialog: _permanentlyDeniedRationalWidget!,
          );
        }
        await openAppSettings();
      }
    } else if (checkStatus == PermissionStatus.permanentlyDenied) {
      spwResponse.granted = false;
      spwResponse.reason = "permanently denied";
      if (_permanentlyDeniedRationalWidget != null && _buildContext != null) {
        await _showCustomDialog(
          context: _buildContext!,
          dialog: _permanentlyDeniedRationalWidget!,
        );
      }
      await openAppSettings();
    }

    return spwResponse;
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
