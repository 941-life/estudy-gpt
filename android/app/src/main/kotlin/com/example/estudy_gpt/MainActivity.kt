package com.example.estudy_gpt

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.Context
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private var methodChannel: MethodChannel? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/text_processing")
        
        // Intent로부터 텍스트 가져오기
        handleProcessTextIntent()
    }
    
    private fun handleProcessTextIntent() {
        if (intent?.action == Intent.ACTION_PROCESS_TEXT) {
            val text = intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)
            if (text != null) {
                // Flutter로 텍스트 전달
                methodChannel?.invokeMethod("processText", text)
            }
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleProcessTextIntent()
    }
}
