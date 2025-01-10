import 'package:flutter/widgets.dart';
import 'package:flutter_app_core/src/helpers/unit.dart';

abstract class BaseViewModel {
  void initState() {}

  void afterFirstLayout() {}

  void disposeState() {}

  @protected
  Future<Unit> handleError(dynamic error);

  @protected
  Future<bool> run(
    dynamic Function() handler, {
    bool shouldHandleError = true,
  }) async {
    var success = true;
    try {
      final result = handler();
      if (result is Future) {
        await result;
      }
    } catch (error) {
      success = false;
      if (shouldHandleError) {
        await handleError(error);
      }
    }
    return success;
  }
}
