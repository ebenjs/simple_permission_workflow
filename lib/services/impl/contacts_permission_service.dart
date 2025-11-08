import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/services/permission_service.dart';

class SPWContactsPermission
    extends SPWPermissionService<SPWContactsPermission> {
  @override
  Future<PermissionStatus> request() async {
    return await Permission.contacts.request();
  }

  @override
  Future<PermissionStatus> checkStatus() async {
    return await Permission.contacts.status;
  }

  Future<List<Contact>> retrieveContacts() async {
    return await FastContacts.getAllContacts();
  }

  Future<List<Contact>> orderContacts(List<Contact> contacts) async {
    return List<Contact>.from(contacts)..sort(
      (a, b) => (a.displayName).toLowerCase().compareTo(
        (b.displayName).toLowerCase(),
      ),
    );
  }
}
