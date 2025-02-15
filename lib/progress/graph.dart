import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime? _selectedDate;
  Map<String, Map<String, dynamic>> dummyData = {
    "2025-01-01": {"hours": 2, "activity": "Pranayama"},
    "2025-01-02": {"hours": 5, "activity": "Pranayama"},
    "2025-01-03": {"hours": 7, "activity": "Pranayama"},
    "2025-01-04": {"hours": 1, "activity": "Pranayama"},
    "2025-01-05": {"hours": 2, "activity": "Pranayama"},
  };

  Map<DateTime, List<Map<String, dynamic>>> get markedDates {
    return dummyData.map((key, value) {
      DateTime parsedDate = DateTime.parse(key);
      return MapEntry(parsedDate, [value]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = dummyData.values.fold<int>(
      0,
          (sum, item) => sum + (item["hours"] as int),
    );

    final dataList = dummyData.entries.toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Color(0xFF6C63FF),
        centerTitle: true,
      ),
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
        color: Color(0xFF6C63FF),
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

  Widget _buildStatsSection(int totalHours) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard("${dummyData.length}", "Days Used"),
          _buildStatCard("5", "Max Streak"),
          _buildStatCard("$totalHours hrs", "Total Hours"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1DB954), Color(0xFF1AA34A)],
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                color: Color(0xFF1DB954),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.white),
              markerDecoration: BoxDecoration(
                color: Color(0xFF1DB954),
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (date) => markedDates[date] ?? [],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final selectedDateStr = _selectedDate!.toLocal().toString().split(' ')[0];
    final data = dummyData[selectedDateStr];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Data for $selectedDateStr:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            data != null
                ? "${data['hours']} hours of ${data['activity']}."
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        dataList[index].value['hours'].toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: Color(0xFF6C63FF),
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Color(0xFF6C63FF).withOpacity(0.3),
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
                          '${dataList[barSpot.spotIndex].key}\n${barSpot.y.toInt()} hrs',
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
