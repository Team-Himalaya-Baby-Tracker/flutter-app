import 'dart:convert';

import 'package:baby_tracker/utils/ApiResponse.dart';
import 'package:baby_tracker/utils/dialogue.dart';
import 'package:baby_tracker/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = apiUrl;
  late SharedPreferences sharedPreferences;

  static Future<ApiResponse> get(String url) async {
    ApiResponse _apiResponse = ApiResponse();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${sharedPreferences.getString('token')}"
    };

    try {
      Uri urlUri = Uri.parse('$apiUrl$url');

      final response = await http.get(
        urlUri,
        headers: userHeader,
      );

      _apiResponse.statusCode = response.statusCode;

      switch (response.statusCode) {
        case 200:
          {
            _apiResponse.data = (json.decode(response.body));

            break;
          }

        default:
          {
            _apiResponse.apiError =
                ApiError.fromJson(json.decode(response.body));
          }
      }
    } catch (e) {
      _apiResponse.apiError = ApiError(error: "Server error. Please retry");
    }
    return _apiResponse;
  }

  static Future<ApiResponse> post(String url, dynamic body) async {
    ApiResponse _apiResponse = ApiResponse();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${sharedPreferences.getString('token')}"
    };

    try {
      Uri urlUri = Uri.parse('$apiUrl$url');

      final response = await http.post(
        urlUri,
        headers: userHeader,
        body: jsonEncode(body),
      );

      _apiResponse.statusCode = response.statusCode;

      switch (response.statusCode) {
        case 200:
          {
            _apiResponse.data = (json.decode(response.body));

            break;
          }

        default:
          {
            _apiResponse.apiError =
                ApiError.fromJson(json.decode(response.body));
          }
      }
    } catch (e) {
      _apiResponse.apiError = ApiError(error: "Server error. Please retry");
    }
    return _apiResponse;
  }

  static Future<ApiResponse> put(String url, dynamic body) async {
    ApiResponse _apiResponse = ApiResponse();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${sharedPreferences.getString('token')}"
    };

    try {
      Uri urlUri = Uri.parse('$apiUrl$url');

      final response = await http.put(
        urlUri,
        headers: userHeader,
        body: jsonEncode(body),
      );

      _apiResponse.statusCode = response.statusCode;

      switch (response.statusCode) {
        case 200:
          {
            _apiResponse.data = (json.decode(response.body));

            break;
          }

        default:
          {
            _apiResponse.apiError =
                ApiError.fromJson(json.decode(response.body));
          }
      }
    } catch (e) {
      _apiResponse.apiError = ApiError(error: "Server error. Please retry");
    }
    return _apiResponse;
  }

  static Future<ApiResponse> delete(String url) async {
    ApiResponse _apiResponse = ApiResponse();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${sharedPreferences.getString('token')}"
    };

    try {
      Uri urlUri = Uri.parse('$apiUrl$url');

      final response = await http.delete(
        urlUri,
        headers: userHeader,
      );

      _apiResponse.statusCode = response.statusCode;

      switch (response.statusCode) {
        case 200:
          {
            _apiResponse.data = (json.decode(response.body));

            break;
          }

        default:
          {
            _apiResponse.apiError =
                ApiError.fromJson(json.decode(response.body));
          }
      }
    } catch (e) {
      _apiResponse.apiError = ApiError(error: "Server error. Please retry");
    }
    return _apiResponse;
  }
}
