package com.example.estudy_gpt

import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Locale

class CalendarGridService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CalendarGridFactory(applicationContext)
    }
}

class CalendarGridFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {

    private var days: List<Map<String, Any>> = listOf()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        try {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val data = prefs.getString("calendar_events", "{}") ?: "{}"
            Log.d("WidgetDebug", "수신 데이터: $data")

            val json = JSONObject(data)
            days = parseDays(json.getJSONArray("days"))
        } catch (e: Exception) {
            Log.e("WidgetError", "데이터 파싱 실패", e)
            days = listOf()
        }
    }

    private fun parseDays(daysArray: JSONArray): List<Map<String, Any>> {
        return List(daysArray.length()) { i ->
            val dayObj = daysArray.getJSONObject(i)
            mapOf(
                "date" to dayObj.getString("date"),
                "events" to dayObj.getJSONArray("events").let {
                    List(it.length()) { idx -> it.getString(idx) }
                }
            )
        }
    }

    override fun getCount(): Int = days.size

    override fun getViewAt(position: Int): RemoteViews {
        val day = days[position]
        return try {
            val date = SimpleDateFormat("yyyy-MM-dd", Locale.KOREAN).parse(day["date"].toString())!!
            RemoteViews(context.packageName, R.layout.calendar_grid_item).apply {
                setTextViewText(R.id.dayText, date.date.toString())
                setViewVisibility(
                    R.id.eventIndicator,
                    if ((day["events"] as List<*>).isNotEmpty()) View.VISIBLE else View.INVISIBLE
                )
            }
        } catch (e: Exception) {
            RemoteViews(context.packageName, R.layout.calendar_grid_item).apply {
                setTextViewText(R.id.dayText, "ERR")
            }
        }
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
    override fun onDestroy() {}
}
