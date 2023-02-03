extension IsNumber on String {
  bool isNumber() {
    return (double.tryParse(this).runtimeType == int ||
        double.tryParse(this).runtimeType == double);
  }
}
