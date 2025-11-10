## 0.0.8
- Added additional permissions to the `SPWPermission` enum.

## 0.0.7
- expose contact cleanup helper methods on `SPWContactsPermission`: `removeEmptyNames(List<Contact>)` and `removeEmptyPhoneNumbers(List<Contact>)`
- documented contact helper usage and example showing `retrieveContacts()` and `orderContacts(...)`, and how to combine helpers

## 0.0.6
- added support for location permission
- added support for photos permission
## 0.0.5
- expose contact helper methods on `SPWContactsPermission`: `retrieveContacts()` and `orderContacts(List<Contact>)`
- contact fetching implemented using `fast_contacts` (add runtime dependency if you use helpers)

## 0.0.4
- added openSettingsOnDismiss option
- improved documentation
## 0.0.3

- notifications permission added

## 0.0.2

- bug fixes

## 0.0.1

- first implementation of the library
- contacts permission support
