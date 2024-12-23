import 'package:permission_handler/permission_handler.dart';

class LocationPermissionsHandler {

  Future<bool> checkPermission() async {
    print("checkPermission()");
    final _status = await Permission.location.status;
    print("permission:$_status");
    return _status.isGranted;
  }

  Future<PermissionStatus> requestPermission() async {
    final _request = await Permission.location.request();
    return _request;
  }
}