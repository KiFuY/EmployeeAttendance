import 'package:attendance/informationPage/result.dart';
import 'package:flutter/material.dart';


class DetailPage extends StatelessWidget {
  final Result result;

  DetailPage({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text('ID: ${result.username}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Sign-in time:', style: TextStyle(fontSize: 18)),
                ),
                Expanded(
                  child: Text('Sign-out time:', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('${result.signInTime}', style: TextStyle(fontSize: 18)),
                ),
                Expanded(
                  child: Text('${result.signOutTime}', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            SizedBox(height: 20), // Increase the gap
            Text('Location: ${result.location}', style: TextStyle(fontSize: 18)),
            Divider(color: Colors.black),
            Text('Notice: ${result.notice}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}



