import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../Controller/AttendanceController.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  loc.LocationData? _currentPosition;
  final loc.Location _location = loc.Location();
  String _currentPlaceName = 'Loading...';
  String _currentFullPlaceName = 'Loading...';
  bool _isSignedIn = false;
  String? username;
  String? _attendanceId;
  String? _notice = '';
  StreamSubscription<loc.LocationData>? _locationSubscription;
  DateTime now = DateTime.now();
  String formattedTime = DateFormat.Hm().format(DateTime.now());
  String formattedWeekday = DateFormat.EEEE().format(DateTime.now());
  String formattedDate = DateFormat.yMMMMd().format(DateTime.now());
  TextEditingController _noticeController = TextEditingController();
  Timer? _timer;

   void _startLocationUpdates() {
  _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
    if (_currentPosition == null) {
      _getLocation();
    } else {
      timer.cancel();
    }
  });
}


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getLocation();
    _getUsername();
    _getSignInStatus();
    _startLocationUpdates();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        now = DateTime.now();
        formattedTime = DateFormat.Hm().format(now);
        formattedWeekday = DateFormat.EEEE().format(now);
        formattedDate = DateFormat.yMMMMd().format(now);
      });
    });
  }

  void _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
  }

  void _getSignInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSignedIn = prefs.getBool('isSignedIn') ?? false;
    _attendanceId = prefs.getString('attendanceId');
    _notice = prefs.getString('notice');
    _noticeController.text = _notice ?? '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getLocation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getLocation();
  }

  _getLocation() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    await _location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 10,
    );

    _locationSubscription = _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _currentPosition = currentLocation;
        });
        _getPlaceName(_currentPosition!.latitude!, _currentPosition!.longitude!);
      }
    });

    if (mounted) {
      _currentPosition = await _location.getLocation();
      if (_currentPosition != null) {
        _getPlaceName(_currentPosition!.latitude!, _currentPosition!.longitude!);
      }
    }
  }

   void _getPlaceName(double latitude, double longitude) async {
      List<geocoding.Placemark> placemarks =
      await geocoding.placemarkFromCoordinates(latitude, longitude);
      geocoding.Placemark place = placemarks[0];

      if (mounted) { 
      setState(() {
      _currentFullPlaceName = '${place.street}, ${place.locality}';  
      _currentPlaceName = place.street != null && place.street!.length > 20 ? '${place.street!.substring(0, 20)}...' : place.street ?? '';  // Update current place name with street, truncate if too long
      });
    }
}




  final AttendanceController _attendanceController = AttendanceController();

  void _signIn() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign In'),
          content: Text('Do you want to sign in?'),
          actions: <Widget>[
            TextButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('YES'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm) {
      final attendance = {
        'username': username,
        'time': DateTime.now().toIso8601String(),
        'status': 1,
        'location': _currentFullPlaceName,
      };

      // Get the response data
      final response = await _attendanceController.saveAttendance(attendance);

      // Extract and save sessionId from the response
      String sessionId = response['sessionId'];
      _attendanceId = response['id'].toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('sessionId', sessionId);
      prefs.setString('attendanceId', _attendanceId!);

      prefs.setBool('isSignedIn', true);

      setState(() {
        _isSignedIn = true;
      });
    }
  }

  void _signOut() async {
    final attendance = {
      'username': username, // replace with actual username
      'time': DateTime.now().toIso8601String(),
      'status': 0,
    };

    await _attendanceController.saveSignOut(attendance);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSignedIn', false);
    prefs.remove('attendanceId');
    prefs.remove('notice');
    prefs.setBool('isLoggedIn', false); // Set isLoggedIn to false

    setState(() {
      _isSignedIn = false;
      _notice = '';
    });
  }

  void _saveNotice() async {
    if (_attendanceId == null) {
      print("Error: attendanceId is null");
      return;
    }

    final notice = {
      'attendanceId': _attendanceId!,
      'notice': _notice ?? '',
    };

    await _attendanceController.updateNotice(notice);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notice', _notice ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notice Saved'),
          content: Text('Your notice has been saved.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
}


    Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.setBool('isLoggedIn', false);  // Add this line
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();  // Here you cancel the subscription
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.5;

     return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Icon(Icons.location_on),
            SizedBox(width: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,  // Adjust this value as needed
              child: Text(
                _currentPlaceName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          ],
        ),
            actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: containerHeight,
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        formattedTime,
                        style: TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        formattedWeekday,
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: _isSignedIn ? null : _signIn,
                            child: Text('Sign In'),
                          ),
                          ElevatedButton(
                            onPressed: _isSignedIn ? _signOut : null,
                            child: Text('Sign Out'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 400,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Notice(optional):',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _noticeController,
                    onChanged: (value) {
                      setState(() {
                        _notice = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your notice here',
                    ),
                    maxLines: null, // Allow TextField to expand vertically
                    minLines: 1, // Set minimum height of TextField
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isSignedIn ? _saveNotice : null,
                    child: Text('Save Notice'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}








