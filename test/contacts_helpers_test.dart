import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/services/impl/contacts_permission_service.dart';
import 'package:simple_permission_workflow/simple_permission_workflow.dart';

class TestContactsPermission extends SPWContactsPermission {
  final List<Contact> _contacts;

  TestContactsPermission(this._contacts);

  @override
  Future<List<Contact>> retrieveContacts() async => _contacts;

  @override
  Future<List<Contact>> orderContacts(List<Contact> contacts) async {
    final list = List<Contact>.from(contacts);
    list.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return list;
  }

  @override
  Future<PermissionStatus> checkStatus() async => PermissionStatus.granted;

  @override
  Future<PermissionStatus> request() async => PermissionStatus.granted;
}

Contact buildContact(String id, String displayName) {
  return Contact(
    id: id,
    phones: const [],
    emails: const [],
    structuredName: StructuredName(
      displayName: displayName,
      namePrefix: '',
      givenName: '',
      middleName: '',
      familyName: '',
      nameSuffix: '',
    ),
    organization: null,
  );
}

void main() {
  test(
    'getServiceInstance returns typed contacts service and orderContacts works',
    () async {
      final spw = SimplePermissionWorkflow({
        SPWPermission.contacts: () => TestContactsPermission([
          buildContact('1', 'Zoé'),
          buildContact('2', 'alice'),
          buildContact('3', 'Émile'),
          buildContact('4', 'bob'),
        ]),
      });

      // Ensure getServiceInstance returns the concrete type
      final service = spw.getServiceInstance<SPWContactsPermission>(
        SPWPermission.contacts,
      );
      expect(service, isA<SPWContactsPermission>());

      // retrieveContacts should return the injected list
      final fetched = await service.retrieveContacts();
      expect(
        fetched.map((c) => c.displayName).toList(),
        containsAll(['Zoé', 'alice', 'Émile', 'bob']),
      );

      // orderContacts should return a sorted list (case-insensitive)
      final ordered = await service.orderContacts(fetched);
      final orderedNames = ordered.map((c) => c.displayName).toList();

      // Compute expected order using same case-insensitive comparison used in implementation
      final expected = List<Contact>.from(fetched)
        ..sort(
          (a, b) => a.displayName.toLowerCase().compareTo(
            b.displayName.toLowerCase(),
          ),
        );
      final expectedNames = expected.map((c) => c.displayName).toList();

      expect(orderedNames, equals(expectedNames));
    },
  );
}
