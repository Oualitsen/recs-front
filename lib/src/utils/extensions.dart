extension OnString on String? {
  bool isBlank() {
    return this == null || this!.trim().isEmpty;
  }
}
