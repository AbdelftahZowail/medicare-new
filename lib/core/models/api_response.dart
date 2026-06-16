class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final List<String>? errors;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return ApiResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }

  factory ApiResponse.listFromJson(
    Map<String, dynamic> json,
    T Function(dynamic) itemFromJson,
  ) {
    return ApiResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? itemFromJson(json['data']) : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }
}
