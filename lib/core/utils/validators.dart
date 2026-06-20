class Validators {
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.\-]+@[\w\-]+\.[\w.\-]+$');
    return re.hasMatch(v) ? null : 'Enter a valid email';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return v.length >= 6 ? null : 'Minimum 6 characters';
  }

  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;
}
