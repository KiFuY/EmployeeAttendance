import 'dart:convert';
import 'package:dio/dio.dart';

class AttendanceRateController {
  Future<Map<String, dynamic>> fetchAttendanceRate(String date) async {
    var dio = Dio();
    final response = await dio.get('http://10.0.2.2:9090/api/attendanceRate', queryParameters: {'date': date});
    if (response.statusCode == 200) {
      print(response.data);  // 打印响应数据
      return response.data;
    } else {
      throw Exception('Failed to load attendance rate');
    }
  }
}