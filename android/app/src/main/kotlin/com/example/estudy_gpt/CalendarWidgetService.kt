package com.example.estudy_gpt

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone

class CalendarWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CalendarWidgetFactory(applicationContext)
    }
}

class CalendarWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var events: List<JSONObject> = listOf()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val sharedPreferences = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val jsonString = sharedPreferences.getString("calendar_events", "[]") ?: "[]"
        val eventsArray = JSONArray(jsonString)
        val tempList = mutableListOf<JSONObject>()
        for (i in 0 until eventsArray.length()) {
            tempList.add(eventsArray.getJSONObject(i))
        }
        events = tempList
    }

    override fun getCount(): Int = events.size

    override fun getViewAt(position: Int): RemoteViews {
        val event = events[position]
        val title = event.optString("title", "제목 없음")
        val rawDate = event.optString("date", "")
        val formattedDate = formatDate(rawDate)

        val rv = RemoteViews(context.packageName, R.layout.calendar_widget_list_item)
        rv.setTextViewText(R.id.itemTitle, title)
        rv.setTextViewText(R.id.itemDate, formattedDate)
        return rv
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
    override fun onDestroy() {}

    private fun formatDate(isoDate: String): String {
        return try {
            val inputFormat = SimpleDateFormat(
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                Locale.getDefault()
            ).apply {
                timeZone = TimeZone.getTimeZone("UTC")
            }
            val date = inputFormat.parse(isoDate)
            SimpleDateFormat("yyyy년 M월 d일 (E)", Locale.KOREAN).format(date!!)
        } catch (e: Exception) {
            isoDate
        }
    }
}
