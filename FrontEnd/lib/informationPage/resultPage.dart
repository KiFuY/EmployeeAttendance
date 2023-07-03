
import 'package:attendance/informationPage/attendanceRatePage.dart';
import 'package:attendance/informationPage/result.dart';
import 'package:flutter/material.dart';
import 'package:attendance/Controller/ResultController.dart';

import 'detailPage.dart';
import 'summaryPage.dart';

class ResultPage extends StatelessWidget {
  final String username;
  final String date;

  ResultPage({required this.username, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        actions: <Widget>[
          if (username == '10086') ...[
            IconButton(
              icon: Icon(Icons.pie_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceRatePage(date: date),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.article_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryPage(username: username, date: date),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: FutureBuilder<List<Result>>(
           future: search(username, date, context, isAdmin: username == '10086'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Result> results = snapshot.data!; 

                for (var result in results) {
                  print('Username: ${result.username}, SignInTime: ${result.signInTime}, SignOutTime: ${result.signOutTime}');
                }

                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.black),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(results[index].username), // Access the username property
                      subtitle: Text(results[index].signInTime), // Access the signInTime property
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(result: results[index]),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          )
    );
  }
}









