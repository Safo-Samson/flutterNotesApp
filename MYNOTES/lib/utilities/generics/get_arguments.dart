import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final route = ModalRoute.of(this); // get the current build context
    if (route == null) return null;
    final args = route.settings.arguments;
    if (args != null && args is T) {
      return args as T;
    }
    return null;
  }
}
