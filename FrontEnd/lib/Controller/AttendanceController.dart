import 'package:dio/dio.dart';

class AttendanceController {
  final Dio _dio = Dio();

Future<Map<String, dynamic>> saveAttendance(Map<String, dynamic> attendance) async {
  try {
    final response = await _dio.post(
      'http://10.0.2.2:9090/api/attendance', // replace with actual server URL
      data: attendance,
    );

    if (response.statusCode == 200) {
      print('Attendance saved successfully');
      return response.data; // Return the entire response data
    } else {
      print('Failed to save attendance');
      throw Exception('Failed to save attendance');
    }
  } catch (e) {
    print('Failed to save attendance: $e');
    throw e;
  }
}



  Future<void> saveSignOut(Map<String, dynamic> attendance) async {
    try {
      final response = await _dio.post(
        'http://10.0.2.2:9090/api/attendance', // replace with actual server URL
        data: attendance,
      );

      if (response.statusCode == 200) {
        print('Sign out saved successfully');
      } else {
        print('Failed to save sign out');
      }
    } catch (e) {
      print('Failed to save sign out: $e');
    }
  }

Future<void> updateNotice(Map<String, String> notice) async {
  try {
    final response = await _dio.put(
      'http://10.0.2.2:9090/api/attendance/${notice['attendanceId']}', // replace with actual server URL
      data: {'notice': notice['notice']},
    );

    if (response.statusCode == 200) {
      print('Notice updated successfully');
    } else {
      print('Failed to update notice');
    }
  } catch (e) {
    print('Failed to update notice: $e');
  }
}

}
