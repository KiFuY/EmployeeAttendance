import 'dart:convert';
import 'package:attendance/informationPage/result.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

Future<List<Result>> search(String username, String date, BuildContext context, {bool isAdmin = false}) async {
  var dio = Dio();
  try {
    Map<String, dynamic> queryParameters = {'date': date};

    queryParameters['username'] = isAdmin ? "10086" : username;

    final response = await dio.get('http://10.0.2.2:9090/api/search', queryParameters: queryParameters);
    if (response.statusCode == 200) {
      Iterable l = response.data;
      List<Result> results = [];
      Map<String, dynamic> signInRecords = {};

      // 分类签到记录
      for (var item in l) {
        if (item['status'] == 1) {
          signInRecords[item['sessionId']] = item;
        }
      }

      // 匹配签出记录并创建Result对象
      for (var item in l) {
        if (item['status'] == 0) {
          var signInRecord = signInRecords[item['sessionId']];
          if (signInRecord != null) {
            results.add(Result.fromJson(signInRecord, item));
          }
        }
      }

      return results;
    } else {
      throw Exception('Failed to load search results');
    }
  } catch (e) {
    return []; // return empty list on failure
  }
}













