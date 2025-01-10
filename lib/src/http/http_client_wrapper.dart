import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app_core/src/helpers/unit.dart';
import 'package:flutter_app_core/src/http/http_error.dart';
import 'package:flutter_app_core/src/http/oauth2/oauth2_manager.dart';
import 'package:logger/logger.dart';

typedef UnauthorizedResponseHandler = void Function({
  required HttpError httpError,
});

typedef ErrorMessageParser = String? Function({
  required HttpError httpError,
});

class HttpClientWrapper {
  final Dio dio = Dio();
  final Logger? _logger;
  final UnauthorizedResponseHandler? _unauthorizedResponseHandler;
  final Oauth2Manager? _oauth2Manager;
  final ErrorMessageParser _errorMessageParser;

  HttpClientWrapper({
    required BaseOptions options,
    Logger? logger,
    bool verbose = false,
    UnauthorizedResponseHandler? unauthorizedResponseHandler,
    Oauth2Manager? oauth2Manager,
    List<Interceptor>? extraInterceptors,
    ErrorMessageParser errorMessageParser = laravelErrorMessageParser,
  })  : _logger = logger,
        _unauthorizedResponseHandler = unauthorizedResponseHandler,
        _oauth2Manager = oauth2Manager,
        _errorMessageParser = errorMessageParser {
    dio.options = options;
    dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest, onError: onError));

    if (_logger != null) {
      if (verbose) {
        dio.interceptors.add(LogInterceptor(logPrint: _logger!.v, requestBody: true, responseBody: true));
      } else {
        dio.interceptors.add(LogInterceptor(logPrint: _logger!.d));
      }
    }

    if (extraInterceptors != null) {
      dio.interceptors.addAll(extraInterceptors);
    }
  }

  Future<Unit> onRequest(RequestOptions option, RequestInterceptorHandler handler) async {
    option.headers['Accept'] = 'application/json';

    final accessToken = await _oauth2Manager?.getAccessToken();
    if (accessToken != null) {
      option.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(option);

    return unit;
  }

  void onError(DioException e, ErrorInterceptorHandler handler) {
    final httpError = HttpError(
      dioException: e,
      errorMessageParser: _errorMessageParser,
    );

    if (httpError.response?.statusCode == HttpStatus.unauthorized) {
      _logger?.w('Http Unauthorized Response');
      _unauthorizedResponseHandler?.call(httpError: httpError);
    }

    handler.next(httpError);
  }
}
