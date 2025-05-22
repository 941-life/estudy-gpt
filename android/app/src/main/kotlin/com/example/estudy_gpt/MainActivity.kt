package com.example.estudy_gpt

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.Context
import androidx.annotation.NonNull
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app/text_processing"
    private var methodChannel: MethodChannel? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        // Intent로부터 텍스트 가져오기
        handleIntent(intent)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        // ACTION_PROCESS_TEXT 처리 (기존 코드)
        if (intent?.action == Intent.ACTION_PROCESS_TEXT) {
            val text = intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)
            if (text != null) {
                // Flutter로 텍스트 전달
                methodChannel?.invokeMethod("processText", text)
            }
        }
        
        // ACTION_SEND 처리 (URL 공유)
        else if (intent?.action == Intent.ACTION_SEND) {
            if ("text/plain" == intent.type) {
                val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                if (sharedText != null) {
                    Log.d("MainActivity", "Received shared URL: $sharedText")
                    // URL인지 확인 (http:// 또는 https://로 시작하는지)
                    if (sharedText.startsWith("http://") || sharedText.startsWith("https://")) {
                        // Flutter로 URL 전달
                        methodChannel?.invokeMethod("receivedUrl", sharedText)
                    } else {
                        // 일반 텍스트로 처리
                        methodChannel?.invokeMethod("receivedText", sharedText)
                    }
                }
            }
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }
}
