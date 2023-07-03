import 'package:attendance/Controller/ResultController.dart';
import 'package:attendance/informationPage/result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class SummaryPage extends StatelessWidget {
  final String username;
  final String date;


  SummaryPage({required this.username, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: FutureBuilder<List<Result>>(
        future: search(username, date, context, isAdmin: username == '10086'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Date: $date'),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Sign-in Time')),
                        DataColumn(label: Text('Sign-out Time')),
                      ],
                      rows: snapshot.data!.map((result) => DataRow(
                        cells: <DataCell>[
                          DataCell(Text(result.username)),
                          DataCell(Text(result.signInTime)),
                          DataCell(Text(result.signOutTime)), 
                        ],
                      )).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}





















