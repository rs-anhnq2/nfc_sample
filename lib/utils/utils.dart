import 'package:flutter/material.dart';

mixin Utils {
  Future<dynamic> push(
    BuildContext context,
    Widget route, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) async {
    return Navigator.of(context).push<dynamic>(
      MaterialPageRoute<dynamic>(
        builder: (context) => route,
        fullscreenDialog: fullscreenDialog,
        settings: settings,
      ),
    );
  }

  Future<dynamic> pushReplacement(BuildContext context, Widget routerName) {
    return Navigator.of(context).pushReplacement(
        MaterialPageRoute<dynamic>(builder: (context) => routerName));
  }

  Future<dynamic> pushAndRemoveUntil(BuildContext context, Widget routerName) {
    return Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => routerName), (route) => false);
  }

  void unFocusScope(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> snackBar(
    BuildContext context,
    String title,
    Color titlecolor,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
  }

  Future<void> pushName(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  bool isPortrait(context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait;
  }

  AppBar getAppBar({
    required BuildContext context,
    String? title,
    bool centerTitle = true,
    double elevation = 0,
    Color? bgColor,
    Color titleColor = Colors.grey,
    PreferredSizeWidget? bottom,
    List<Widget>? actions,
    String? logoUrl,
    int? unreadCount,
    bool hasSearch = false,
    bool hasClose = false,
    bool hasProfile = false,
    Widget? leading,
    VoidCallback? pressBack,
    dynamic popValue,
    void Function()? actionSearch,
    void Function()? actionProfile,
    void Function()? actionNotify,
  }) {
    final _title = title != null ? Text(title) : null;
    final _actions = <Widget>[];

    if (hasClose) {
      _actions.add(_closeBtn(context, popValue));
    }

    return AppBar(
      elevation: elevation,
      backgroundColor: bgColor,
      title: _title,
      centerTitle: centerTitle,
      leading: _leading(context, leading, logoUrl, pressBack, popValue),
      actions: actions ?? _actions,
      bottom: bottom,
    );
  }

  static Widget? _leading(
    BuildContext context,
    Widget? leading,
    String? logoUrl,
    VoidCallback? pressBack,
    dynamic popValue,
  ) {
    Widget? _leading;

    _leading = leading ??
        (pressBack != null ? _backBtn(context, pressBack, popValue) : null);

    return _leading;
  }

  static Widget _backBtn(
      BuildContext context, VoidCallback? pressBack, dynamic popValue) {
    return InkWell(
      onTap: pressBack ??
          () {
            Navigator.of(context).pop(popValue);
          },
      child: const Icon(
        Icons.arrow_back_ios,
        color: Colors.black,
        size: 20,
      ),
    );
  }

  static Widget _closeBtn(BuildContext context, dynamic popValue) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(popValue),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: const Icon(Icons.close, size: 20),
      ),
    );
  }
}
