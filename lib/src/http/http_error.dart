import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app_core/src/http/http_client_wrapper.dart';

class HttpError extends DioException {
  final ErrorMessageParser? _errorMessageParser;

  HttpError({
    required DioException dioException,
    ErrorMessageParser? errorMessageParser,
  })  : _errorMessageParser = errorMessageParser,
        super(
          requestOptions: dioException.requestOptions,
          response: dioException.response,
          type: dioException.type,
          error: dioException.error,
        );

  @override
  String? get message {
    if (error is SocketException) {
      return 'Cannot connect to server. Please check network and try again!';
    }

    final parsedMessage = _errorMessageParser?.call(httpError: this);
    if (parsedMessage != null) {
      return parsedMessage;
    }

    return super.message;
  }

  @override
  String toString() {
    return message ?? 'Empty message';
  }
}

String? laravelErrorMessageParser({
  required HttpError httpError,
}) {
  if (httpError.response?.data is Map) {
    final Map data = httpError.response?.data as Map;
    if (data.containsKey('message')) {
      return data['message'].toString();
    } else {
      final StringBuffer buffer = StringBuffer();
      data.forEach((key, value) {
        if (buffer.isNotEmpty) {
          buffer.write('\n');
        }
        if (value is List) {
          buffer.write(value.join('\n'));
        } else {
          buffer.write(value);
        }
      });
      return buffer.toString();
    }
  }
  return null;
}
