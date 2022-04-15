class ApiResponse {
  // _data will hold any response converted into
  // its own object. For example user.
  late Object _data;
  // _apiError will hold the error object
  late ApiError _apiError;
  late Object _statusCode;

  Object get data => _data;
  set data(Object data) => _data = data;

  Object get statusCode => _statusCode;
  set statusCode(Object statusCode) => _statusCode = statusCode;

  ApiError get apiError => _apiError as ApiError;
  set apiError(ApiError error) => _apiError = error;
}

class ApiError {
  late String _error;

  ApiError({required String error}) {
    _error = error;
  }

  String get error => _error;
  set error(String error) => _error = error;

  ApiError.fromJson(Map<String, dynamic> json) {
    _error = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = _error;
    return data;
  }
}
