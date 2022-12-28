import 'package:flutter/material.dart';
import 'package:nfc_sample/utils/utils.dart';

class ChildScreen extends StatefulWidget {
  const ChildScreen({Key? key}) : super(key: key);

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> with Utils {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(context: context, title: 'B画面'),
        body: const Center(
          child: Text('B画面'),
        ));
  }
}
