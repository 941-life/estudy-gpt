package com.example.estudy_gpt

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
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

            // 위젯 업데이트
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
} 