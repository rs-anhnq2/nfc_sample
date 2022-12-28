import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_plugin/models/nfc_event.dart';
import 'package:flutter_nfc_plugin/models/nfc_message.dart';
import 'package:flutter_nfc_plugin/models/nfc_state.dart';
import 'package:flutter_nfc_plugin/nfc_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_sample/core/routes.dart';
import 'package:nfc_sample/utils/utils.dart';

class HomeScreen extends StatefulHookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

// TODO(anhnq2): refactor code -> use riverpod to manage state
class _HomeScreenState extends ConsumerState<HomeScreen>
    with Utils, SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const channel = MethodChannel("com.example.nfc_sample/nfc");
  static const tabRead = 'TOP';
  static const tabWrite = '書き込み';
  static const writeBtn = '書き込み';
  static const writeSuccess = '書き込み成功!';
  static const writting = '書き込み中';
  static const cancelBtn = 'キャンセル';

  ValueNotifier<dynamic> result = ValueNotifier(null);
  TabController? _tabController;
  String nfcState = 'Unknown';
  String nfcError = '';
  String nfcMessage = '';
  String nfcTechList = '';
  String? nfcId = '';
  NfcMessage? nfcMessageStartedWith;
  bool isWriting = false;
  NfcPlugin nfcPlugin = NfcPlugin();
  StreamSubscription<NfcEvent>? _nfcMesageSubscription;
  bool isFirstRun = true;
  bool isReadScreen = true;
  bool isLoading = true;
  String route = '';

  @override
  void dispose() {
    _tabController?.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initTabController();
    WidgetsBinding.instance?.addObserver(this);

    _initReadNfcStream().then((_) {
      setState(() {
        isFirstRun = false;
        isLoading = false;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getNfcData().then((value) {
        route = value.split("/").last;

        _gotoChildScreen("/$route")?.then((_) {
          setState(() {
            isFirstRun = false;
          });
        });
      });
    }
  }

  void _initTabController() {
    _tabController = TabController(length: 2, vsync: this);

    _tabController?.addListener(() async {
      final isTabChaneging = _tabController?.indexIsChanging ?? false;

      if (isTabChaneging) {
        return;
      }

      setState(() {
        isWriting = false;
        isReadScreen = _tabController?.index == 0;
      });

      if (_tabController?.index == 1) {
        await _nfcMesageSubscription?.cancel();
        await _listenToWrite();

        setState(() {
          isLoading = false;
        });
      } else {
        await NfcManager.instance.stopSession();
        await _initReadNfcStream();

        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _initReadNfcStream() async {
    NfcState? _nfcState;

    try {
      _nfcState = await nfcPlugin.nfcState;
      log('NFC state is $_nfcState');
    } on PlatformException {
      log('Method "NFC state" exception was thrown');
      return;
    }

    // Handle event open app by NFC
    try {
      final NfcEvent? _nfcEventStartedWith = await nfcPlugin.nfcStartedWith;
      log('NFC event started with is ${_nfcEventStartedWith?.message?.id}');

      if (_nfcEventStartedWith != null &&
          mounted &&
          isReadScreen &&
          isFirstRun) {
        isReadScreen = false;
        setState(() {
          nfcMessageStartedWith = _nfcEventStartedWith.message;
        });

        pushName(context, Routes.childScreenRouteName).then((_) async {
          setState(() {
            isReadScreen = true;
            isFirstRun = false;
            isLoading = false;
          });
        });
      }
    } on PlatformException {
      log('Method "NFC event started with" exception was thrown');
    }

    // Handle event listen NFC tag
    if (_nfcState == NfcState.enabled) {
      _nfcMesageSubscription =
          nfcPlugin.onNfcMessage?.listen((NfcEvent event) async {
        if (mounted && isReadScreen && (event.error?.isNotEmpty ?? false)) {
          setState(() {
            nfcMessage = 'ERROR: ${event.error}';
            nfcId = '';
          });
        } else {
          if (event.message == null) {
            return;
          }

          final _nfcMsg = event.message?.payload;
          final route = _nfcMsg?.first ?? '';

          if (mounted && isReadScreen) {
            setState(() {
              nfcMessage = _nfcMsg.toString();
              nfcTechList = event.message?.techList.toString() ?? '';
              nfcId = event.message?.id;
            });
          }

          _gotoChildScreen(route);
        }
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      nfcState = _nfcState.toString();
    });
  }

  Future<void>? _gotoChildScreen(String route) {
    if (!Routes.routes.keys.contains(route) || !isReadScreen || !mounted) {
      return null;
    }

    setState(() {
      isReadScreen = false;
    });

    return pushName(context, Routes.childScreenRouteName).then((_) {
      setState(() {
        isReadScreen = true;
        isFirstRun = false;
      });
    });
  }

  Future<String> _getNfcData() async {
    try {
      final String? result = await channel.invokeMethod('onNewIntent');
      return result ?? '';
    } on PlatformException catch (e) {
      log("$e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: 'NFC Sample App',
        bottom: TabBar(
          tabs: const <Widget>[
            Tab(text: tabRead),
            Tab(text: tabWrite),
          ],
          controller: _tabController,
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: <Widget>[_readTab(), _writeTab()]),
      ),
    );
  }

  Widget _readTab() {
    return FutureBuilder<bool>(
        future: NfcManager.instance.isAvailable(),
        builder: (context, snapshot) =>
            snapshot.connectionState != ConnectionState.done
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : snapshot.hasError || !snapshot.hasData
                    ? const Center(child: Text('Nfc is disabled!'))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('NFC state: $nfcState\n'),
                            Text('NFC message: $nfcMessage\n'),
                            Text('NFC tech list: $nfcTechList\n'),
                            Text('NFC id: $nfcId\n'),
                            Text(
                                'The app was started with an NFC: ${nfcMessageStartedWith?.id ?? ''}'),
                            ValueListenableBuilder<dynamic>(
                              valueListenable: result,
                              builder: (context, value, _) =>
                                  Text('${value ?? ''}'),
                            ),
                          ],
                        ),
                      ));
  }

  Widget _writeTab() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isWriting ? const Text(writting) : const SizedBox(),
        const SizedBox(height: 20),
        ElevatedButton(
            child: Text(isWriting ? cancelBtn : writeBtn),
            onPressed: () async {
              if (!isWriting) {
                await _ndefWrite();
                return;
              }

              setState(() {
                isWriting = false;
              });
            }),
      ],
    ));
  }

  Future<void> _ndefWrite() async {
    setState(() {
      isWriting = true;
    });
  }

  Future<void> _listenToWrite() {
    return NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      if (!isWriting) {
        return;
      }

      final ndef = Ndef.from(tag);

      if (ndef == null || !ndef.isWritable) {
        log('Write Failed!');
        await showOkAlertDialog(
          context: context,
          title: 'Non-writable',
          message: 'Please try again!',
        );
        _nfcMesageSubscription?.resume();
        setState(() {
          isWriting = false;
        });
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText('/child'),
        NdefRecord.createExternal('android.com', 'pkg',
            Uint8List.fromList('com.example.nfc_sample'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        log('Write Success');

        setState(() {
          isWriting = false;
        });

        await showDialog(
            context: context,
            builder: (context) {
              _nfcMesageSubscription?.resume();
              return AlertDialog(
                title: const Text('NFC Sample'),
                content: const Text(writeSuccess),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  )
                ],
              );
            });
      } catch (e) {
        log(e.toString());
      }
    });
  }
}
