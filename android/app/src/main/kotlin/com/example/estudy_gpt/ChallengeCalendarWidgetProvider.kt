package com.example.estudy_gpt

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class ChallengeCalendarWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.challenge_calendar_widget)

            // 데이터 가져오기
            val widgetData = HomeWidgetPlugin.getData(context)
            val hasCreatedNote = widgetData.getBoolean("has_created_note", false)
            val message = widgetData.getString("motivational_message", "오늘도 화이팅!")

            // 이미지 업데이트
            views.setImageViewResource(
                R.id.widget_image,
                if (hasCreatedNote) R.drawable.thumbup else R.drawable.sad
            )

            // 메시지 업데이트
            views.setTextViewText(R.id.widget_message, message)

            // 클릭 이벤트 설정
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                action = "WIDGET_CLICK"
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // 위젯 전체에 클릭 리스너 설정
            views.setOnClickPendingIntent(R.id.widget_layout, pendingIntent)

            // 위젯 업데이트
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
} 