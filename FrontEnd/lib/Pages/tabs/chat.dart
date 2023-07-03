import 'package:attendance/Controller/ChatController.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IOWebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isComposing = false;
  String? _username;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    try {
      channel = IOWebSocketChannel.connect('ws://10.0.2.2:9090/user');
      channel.stream.listen((message) {
        print('Received message: $message');
        List<String> parts = message.split(':');
        if (parts.length == 2) {
          String username = parts[0].trim();
          String text = parts[1].trim();
          setState(() {
            _messages.add("$username\n$text");
            // Move the _scrollToBottom call inside the setState
            _scrollToBottom();
          });
        }
      });


      SharedPreferences.getInstance().then((prefs) {
        _username = prefs.getString('username');
        ChatService().fetchChatHistory().then((savedMessages) {
          setState(() {
            _messages.addAll(savedMessages);
            // Scroll to bottom after adding chat history
            _scrollToBottom();
          });
        });
      });

      _controller.addListener(() {
        setState(() {
          _isComposing = _controller.text.isNotEmpty;
        });
      });
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

 void _scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  });
}


  void _sendMessage(String text) {
    String message = text;
    channel.sink.add("$_username: $message");
    setState(() {
      _messages.add("$_username\n$message");
    });
    _controller.clear();

    _scrollToBottom(); // Scroll to bottom when a message is sent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                List<String> parts = _messages[index].split('\n');
                String username = parts[0];
                String message = parts[1];
                return Container(
                  alignment: username == _username ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: username == _username ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: username == _username ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(message),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Send a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _sendMessage(_controller.text)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}




