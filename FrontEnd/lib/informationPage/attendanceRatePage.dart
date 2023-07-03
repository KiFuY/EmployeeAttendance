import 'package:attendance/Controller/AttendanceRateController.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceRatePage extends StatefulWidget {
  final String date;

  AttendanceRatePage({required this.date});

  @override
  _AttendanceRatePageState createState() => _AttendanceRatePageState();
}

class _AttendanceRatePageState extends State<AttendanceRatePage> {
  late Future<Map<String, dynamic>> futureData;
  final controller = AttendanceRateController();

  @override
  void initState() {
    super.initState();
    futureData = controller.fetchAttendanceRate(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Rate'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            int totalUsers = snapshot.data!['totalUsers'];
            int signedInUsers = snapshot.data!['signedInUsers'];
            int notSignedInUsers = totalUsers - signedInUsers;
            double attendanceRate = signedInUsers / totalUsers;

            return Column(
              children: <Widget>[
                SizedBox(height: 100),  
                Text('DATE: ${widget.date}', style: TextStyle(fontSize: 24)),
                SizedBox(height: 10),  
                Expanded(
                  flex: 6, 
                  child: Stack(
                    children: <Widget>[
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 80,
                          sectionsSpace: 0,
                          sections: [
                            PieChartSectionData(
                              value: signedInUsers.toDouble(),
                              color: Colors.green,
                              title: '',
                            ),
                            PieChartSectionData(
                              value: notSignedInUsers.toDouble(),
                              color: Colors.red,
                              title: '',
                            ),
                          ],
                          centerSpaceColor: Colors.white,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${(attendanceRate * 100).toStringAsFixed(2)}%',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(width: 20, height: 20, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Signed-In: $signedInUsers'),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(width: 20, height: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Not Signed-In: $notSignedInUsers'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 100), 
              ],
            );
          }
        },
      ),
    );
  }
}

