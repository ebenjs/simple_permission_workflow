import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';
import 'package:simple_permission_workflow/services/impl/activity_recognition_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/app_tracking_transparency_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/assistant_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/audio_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/background_refresh_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/bluetooth_advertise_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/bluetooth_connect_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/bluetooth_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/bluetooth_scan_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/calendar_full_access_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/calendar_write_only_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/camera_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/contacts_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/critical_alerts_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/location_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/media_location_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/notification_policy_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/notifications_permission_service.dart';
import 'package:simple_permission_workflow/services/impl/photos_permission_service.dart';
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

  T getServiceInstance<T extends SPWPermissionService<T>>(
    SPWPermission permission,
  ) {
    final concreteService = _getConcreteService(permission);
    var concreteServiceInstance = concreteService.instance as T;
    return concreteServiceInstance.instance;
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
    final service = _getConcreteService(permission);

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
    SPWPermission.accessNotificationPolicy: () =>
        SPWNotificationPolicyPermission(),
    SPWPermission.accessMediaLocation: () => SPWMediaLocationPermission(),
    SPWPermission.activityRecognition: () => SPWActivityRecognitionPermission(),
    SPWPermission.appTrackingTransparency: () =>
        SPWAppTrackingTransparencyPermission(),
    SPWPermission.assistant: () => SPWAssistantPermission(),
    SPWPermission.audio: () => SPWAudioPermission(),
    SPWPermission.backgroundRefresh: () => SPWBackgroundRefreshPermission(),
    SPWPermission.bluetooth: () => SPWBluetoothPermission(),
    SPWPermission.bluetoothAdvertise: () => SPWBluetoothAdvertisePermission(),
    SPWPermission.bluetoothConnect: () => SPWBluetoothConnectPermission(),
    SPWPermission.bluetoothScan: () => SPWBluetoothScanPermission(),
    SPWPermission.calendarFullAccess: () => SPWCalendarFullAccessPermission(),
    SPWPermission.calendarWriteOnly: () => SPWCalendarWriteOnlyPermission(),
    SPWPermission.camera: () => SPWCameraPermission(),
    SPWPermission.contacts: () => SPWContactsPermission(),
    SPWPermission.criticalAlerts: () => SPWCriticalAlertsPermission(),
    SPWPermission.notifications: () => SPWNotificationsPermission(),
    SPWPermission.location: () => SPWLocationPermission(),
    SPWPermission.photos: () => SPWPhotosPermission(),
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

  SPWPermissionService _getConcreteService(SPWPermission permission) {
    final factory = _instanceFactory![permission];
    if (factory == null) {
      throw ArgumentError(
        'Service not found for permission type ${permission.toString()}',
      );
    }
    return factory();
  }
}
