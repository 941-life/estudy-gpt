package com.example.estudy_gpt

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import java.util.Date
import java.text.SimpleDateFormat
import java.util.Locale

class HomeCalendarWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val intent = Intent(context, CalendarGridService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }

            val views = RemoteViews(context.packageName, R.layout.calendar_widget).apply {
                setRemoteAdapter(R.id.calendarGrid, intent)
                setTextViewText(
                    R.id.monthTitle,
                    SimpleDateFormat("yyyy년 M월", Locale.KOREAN).format(Date())
                )
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
