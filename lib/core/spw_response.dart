class SPWResponse {
  late final bool _granted;
  late final String _reason;

  bool get granted => _granted;

  String get reason => _reason;

  set granted(bool value) {
    _granted = value;
  }

  set reason(String value) {
    _reason = value;
  }
}
