class Result<T> {
  bool? success;
  T? data;
  String? errorMessage;

  Result({this.success, this.data, this.errorMessage});
}
