package com.example.nfc_sample

import android.app.PendingIntent
import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.example.nfc_sample/nfc"
    private var routeStr = ""

    protected override fun onResume() {
        super.onResume()
        var intent = Intent().addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        var pendingIntent = PendingIntent.getActivity(applicationContext, 0, intent, 0)

        NfcAdapter.getDefaultAdapter(applicationContext)
                .enableForegroundDispatch(this, pendingIntent, null, null)
    }

    protected override fun onPause() {
        super.onPause()
        var nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        nfcAdapter.disableForegroundDispatch(this)
    }

    public override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
                call,
                result ->
            if (call.method == "onNewIntent") {
                result.success(routeStr)
                routeStr = ""
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        if (NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action) {
            intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)?.also { rawMessages ->
                val messages = rawMessages.map { it as NdefMessage }

                // Process the messages array.
                val bytes: ByteArray = messages.first().records.first().payload ?: return
                routeStr = String(bytes)
            }
        }
    }
}
