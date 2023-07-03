import 'package:attendance/Controller/ResultController.dart';
import 'package:attendance/informationPage/resultPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart'; 
import 'package:table_calendar/table_calendar.dart'; 

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String loggedInUsername = '';


  @override
  void initState() {
    super.initState();
    _getLoggedInUsername();
  }

  void _getLoggedInUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUsername = prefs.getString('username') ?? '';
    });
  }

  // Search button click event
  void onDateSelected(DateTime selectedDay, DateTime focusedDay) async {
    String username = loggedInUsername;
    String date = DateFormat('yyyy-MM-dd').format(selectedDay);


    // Navigate to ResultPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultPage(username: username, date: date),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TableCalendar(
              onDaySelected: onDateSelected,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              }, // Only show month format
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}



