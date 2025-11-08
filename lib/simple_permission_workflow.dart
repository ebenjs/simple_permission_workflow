import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';
import 'package:simple_permission_workflow/services/impl/contacts_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/notifications_permission_service.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

import 'simple_permission_workflow_platform_interface.dart';

class SimplePermissionWorkflow {
  BuildContext? _buildContext;
  Widget? _rationaleWidget;
  Widget? _permanentlyDeniedRationaleWidget;
  bool _openSettingsOnDismiss = false;
  late final Map<SPWPermission, SPWPermissionService Function()>?
  _instanceFactory;

  Future<String?> getPlatformVersion() {
    return SimplePermissionWorkflowPlatform.instance.getPlatformVersion();
  }

  SimplePermissionWorkflow([
    Map<SPWPermission, SPWPermissionService Function()>? factory,
  ]) {
    _instanceFactory = factory ?? _factory;
  }

  SimplePermissionWorkflow withRationale({
    required BuildContext buildContext,
    required Widget rationaleWidget,
    Widget? permanentlyDeniedRationaleWidget,
    bool? openSettingsOnDismiss,
  }) {
    _buildContext = buildContext;
    _rationaleWidget = rationaleWidget;
    _permanentlyDeniedRationaleWidget = permanentlyDeniedRationaleWidget;
    _openSettingsOnDismiss = openSettingsOnDismiss ?? false;
    return this;
  }

  Future<SPWResponse> launchWorkflow(SPWPermission permission) async {
    final factory = _instanceFactory![permission];
    if (factory == null) {
      throw ArgumentError(
        'Service not found for permission type ${permission.toString()}',
      );
    }
    final service = factory();

    SPWResponse spwResponse = SPWResponse();
    PermissionStatus checkStatus = await service.checkStatus();

    switch (checkStatus) {
      case PermissionStatus.granted:
        spwResponse.granted = true;
        spwResponse.reason = "already granted";
        break;
      case PermissionStatus.limited:
        spwResponse.granted = true;
        spwResponse.reason = "limited access granted";
        break;
      case PermissionStatus.provisional:
        spwResponse.granted = true;
        spwResponse.reason = "provisional access granted";
        break;
      case PermissionStatus.denied:
        spwResponse.granted = false;
        spwResponse.reason = "permission denied";
        if (_rationaleWidget != null && _buildContext != null) {
          await _showCustomDialog(
            context: _buildContext!,
            dialog: _rationaleWidget!,
          );
        }
        final requestResult = await service.request();
        switch (requestResult) {
          case PermissionStatus.granted:
            spwResponse.granted = true;
            spwResponse.reason = "granted after permission request";
            break;
          case PermissionStatus.limited:
            spwResponse.granted = true;
            spwResponse.reason = "limited access granted after request";
            break;
          case PermissionStatus.provisional:
            spwResponse.granted = true;
            spwResponse.reason = "provisional access granted after request";
            break;
          case PermissionStatus.denied:
            spwResponse.granted = false;
            spwResponse.reason = "permission denied after request";
            break;
          case PermissionStatus.permanentlyDenied:
          case PermissionStatus.restricted:
            spwResponse.granted = false;
            spwResponse.reason =
                requestResult == PermissionStatus.permanentlyDenied
                ? "permanently denied after request"
                : "restricted after request";
            if (_permanentlyDeniedRationaleWidget != null &&
                _buildContext != null) {
              await _showCustomDialog(
                context: _buildContext!,
                dialog: _permanentlyDeniedRationaleWidget!,
              );
            }
            if (_openSettingsOnDismiss) {
              await openAppSettings();
            }
            break;
        }
        break;
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        spwResponse.granted = false;
        spwResponse.reason = checkStatus == PermissionStatus.permanentlyDenied
            ? "permanently denied"
            : "restricted by OS";
        if (_permanentlyDeniedRationaleWidget != null &&
            _buildContext != null) {
          await _showCustomDialog(
            context: _buildContext!,
            dialog: _permanentlyDeniedRationaleWidget!,
          );
        }
        if (_openSettingsOnDismiss) {
          await openAppSettings();
        }
        break;
    }

    return spwResponse;
  }

  void openSettings() => openAppSettings();

  final Map<SPWPermission, SPWPermissionService Function()> _factory = {
    SPWPermission.contacts: () => SPWContactsPermission(),
    SPWPermission.notifications: () => SPWNotificationsPermission(),
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
