import 'package:dio/dio.dart';

Future<int> sendData(String username, String password) async {
  var dio = Dio();
  
  try {
    var response = await dio.post(
      'http://10.0.2.2:9090/api/login',
      data: {
        'username': username,
        'password': password,
      },
    );
  
    if (response.statusCode == 200) {
      print('Data sent successfully');
      return response.data;  // Return the status value
    } else {
      print('Failed to send data');
      return -1;  // Return -1 to indicate that the request failed
    }
  } catch (e) {
    print('Exception occurred: $e');
    return -1;  // Return -1 to indicate that an exception occurred
  }
}

