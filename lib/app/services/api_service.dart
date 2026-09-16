import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiResult<T> {
  const ApiResult({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final T? data;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String baseUrl = "http://app.maklife.in:9025/api/";

  static const Duration _timeout = Duration(seconds: 20);

  Future<ApiResult<String>> login({
    required String username,
    required String password,
  }) async {
    final response = await _send(
      () => http.post(
        Uri.parse("${baseUrl}Auth"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserName": username,
          "Password": password,
        }),
      ),
    );
    return _parseSimple(response);
  }

  Future<ApiResult<String>> getCenterName({
    required String centerId,
  }) async {
    final response = await _send(
      () => http.get(
        Uri.parse("${baseUrl}GetCenterName?centerId=$centerId"),
      ),
    );
    return _parseSimple(response);
  }

  Future<ApiResult<String>> insertPin({
    required String centerId,
    required String pin,
  }) async {
    final uri = Uri.parse("${baseUrl}InsertPIn?CenterId=$centerId&Pin=$pin");
    final response = await _send(
      () => http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"CenterId": centerId, "Pin": pin}),
      ),
    );
    return _parseData(response, dataKey: "Pin");
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(_timeout);
      return response;
    } on TimeoutException {
      throw ApiException("Request timed out. Please try again.");
    } on http.ClientException {
      throw ApiException("Connection failed. Please check your internet.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Connection failed. Please check your internet.");
    }
  }

  ApiResult<String> _parseSimple(http.Response response) {
    final Map<String, dynamic> json = _decode(response);
    return ApiResult<String>(
      success: (json["Success"] as bool?) ?? false,
      message: (json["Message"] as String?) ?? "Something went wrong.",
      data: json["Data"]?.toString(),
    );
  }

  ApiResult<String> _parseData(
    http.Response response, {
    required String dataKey,
  }) {
    final Map<String, dynamic> json = _decode(response);
    final dynamic rawData = json["Data"];
    String? data;
    if (rawData is Map<String, dynamic>) {
      data = rawData[dataKey]?.toString();
    } else if (rawData != null) {
      data = rawData.toString();
    }
    return ApiResult<String>(
      success: (json["Success"] as bool?) ?? false,
      message: (json["Message"] as String?) ?? "Something went wrong.",
      data: data,
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) json = decoded;
    } on FormatException {
      json = null;
    }

    final isEnvelope = json != null &&
        (json.containsKey("Success") ||
            json.containsKey("Message") ||
            json.containsKey("Data"));

    if (json != null && isEnvelope) return json;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        "Server error (${response.statusCode}). Please try again.",
      );
    }
    throw ApiException("Unexpected server response.");
  }
}