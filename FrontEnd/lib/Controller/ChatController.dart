import 'package:dio/dio.dart';

class ChatService {
  final String url = 'http://10.0.2.2:9090/api/chat/history';

  Future<List<String>> fetchChatHistory() async {
    var dio = Dio();

    try {
      var response = await dio.get(url);

      if (response.statusCode == 200) {
      return List<String>.from(response.data.map((x) => "${x['username_id']}\n${x['message']}"));
    } else {
      print('Failed to fetch chat history');
      return [];
    }
  } catch (e) {
    print('Exception occurred: $e');
    return [];
  }
  }
}

