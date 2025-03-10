import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime? _selectedDate;
  // Daily usage data is stored with keys in "YYYY-MM-DD" format.
  Map<String, Map<String, dynamic>> usageData = {};

  Map<DateTime, List<Map<String, dynamic>>> get markedDates {
    return usageData.map((key, value) {
      DateTime parsedDate = DateTime.parse(key);
      return MapEntry(parsedDate, [value]);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  /// Fetch usage data from SharedPreferences.
  /// It assumes that a list of days used is stored under "days_used_<uid>" and for each day
  /// there is a key "usage_<uid>_YYYY-MM-DD" that stores the usage time in seconds.
  Future<void> _loadUsageData() async {
    // Ensure that there is a logged in user.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final daysUsedKey = 'days_used_$uid';
    List<String> daysUsed = prefs.getStringList(daysUsedKey) ?? [];
    Map<String, Map<String, dynamic>> fetchedData = {};

    for (var day in daysUsed) {
      // Retrieve the usage seconds for that day.
      final dailyUsageKey = "usage_${uid}_$day";
      int seconds = prefs.getInt(dailyUsageKey) ?? 0;
      // Convert seconds to hours (as a double).
      double hours = seconds / 3600.0;
      // Here, we assume the activity is "Pranayama" as before.
      fetchedData[day] = {"hours": hours, "activity": "Pranayama"};
    }

    // Update state with the fetched data.
    setState(() {
      usageData = fetchedData;
    });
  }

  /// Calculate the maximum continuous streak (in days) based on usageData.
  int _calculateMaxStreak() {
    if (usageData.isEmpty) return 0;
    // Convert keys (date strings) into DateTime objects.
    List<DateTime> dates = usageData.keys.map((key) => DateTime.parse(key)).toList();
    dates.sort((a, b) => a.compareTo(b));

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      // Check if the difference between consecutive days is exactly one day.
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total hours from the fetched usage data.
    final totalHours = usageData.values.fold<double>(
      0,
          (sum, item) => sum + (item["hours"] as double),
    );

    // Convert the usageData map to a list of entries and sort by date.
    final dataList = usageData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      backgroundColor: const Color(0xffd8e1e8), // Background/Neutral
      // Removed the AppBar to eliminate the top heading and refresh icon.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildStatsSection(totalHours),
            SizedBox(height: 20),
            _buildCalendarSection(),
            SizedBox(height: 20),
            if (_selectedDate != null) _buildSelectedDateInfo(),
            SizedBox(height: 20),
            _buildGraphSection(dataList),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 60),
      decoration: BoxDecoration(
        color: const Color(0xff304674), // Accent
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            "Progress Screen",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "Track your yoga journey and consistency",
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(double totalHours) {
    int maxStreak = _calculateMaxStreak();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard("${usageData.length}", "Days Used"),
          _buildStatCard("$maxStreak", "Max Streak"),
          _buildStatCard("${totalHours.toStringAsFixed(1)} hrs", "Total Hours"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff304674), // Accent
            Color(0xff98bad5), // Primary
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Calendar",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff304674)),
          ),
          SizedBox(height: 10),
          TableCalendar(
            firstDay: DateTime(2025, 1, 1),
            lastDay: DateTime(2025, 12, 31),
            focusedDay: _selectedDate ?? DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: const Color(0xff98bad5), // Primary
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.white),
              markerDecoration: BoxDecoration(
                color: const Color(0xff98bad5), // Primary
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (date) => markedDates[date] ?? [],
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, focusedDay) {
                // Format the date to match the keys in usageData ("YYYY-MM-DD")
                String formattedDate =
                    "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                // If usage data exists for this day, highlight it with the blue accent.
                if (usageData.containsKey(formattedDate)) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff304674),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                // Return null to use the default day cell if there's no usage data.
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final selectedDateStr = _selectedDate!.toLocal().toString().split(' ')[0];
    final data = usageData[selectedDateStr];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Data for $selectedDateStr:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff304674)),
          ),
          SizedBox(height: 10),
          Text(
            data != null
                ? "${data['hours'].toStringAsFixed(1)} hours of ${data['activity']}."
                : "No data available for this day.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphSection(List<MapEntry<String, Map<String, dynamic>>> dataList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Consistency Graph",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff304674)),
          ),
          SizedBox(height: 10),
          Container(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      dataList.length,
                          (index) => FlSpot(
                        index.toDouble(),
                        dataList[index].value['hours'] as double,
                      ),
                    ),
                    isCurved: true,
                    color: const Color(0xff304674), // Accent
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xff304674).withOpacity(0.3), // Accent with opacity
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dataList.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dataList[index].key.split("-")[2],
                              style: TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          '${dataList[barSpot.spotIndex].key}\n${(barSpot.y).toStringAsFixed(1)} hrs',
                          TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension MapConversion<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() => {for (var e in this) e.key: e.value};
}
