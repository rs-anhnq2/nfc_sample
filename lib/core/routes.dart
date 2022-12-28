import 'package:flutter/material.dart';
import 'package:nfc_sample/screens/child_screen.dart';

class Routes {
  static const String childScreenRouteName = '/child';

  static final Map<String, WidgetBuilder> routes = {
    childScreenRouteName: (context) => const ChildScreen(),
  };
}
