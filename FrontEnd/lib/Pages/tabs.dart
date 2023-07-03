import 'package:attendance/changeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import './tabs/chat.dart';
import './tabs/history.dart';
import './tabs/home.dart';

class Tabs extends StatefulWidget {
  const Tabs({Key? key}) : super(key: key);

  @override
  _Tabs createState() => _Tabs();
}

class _Tabs extends State<Tabs> {
  int _currentIndex = 0;
  late UnreadMessagesModel unreadMessagesModel;

  final List<Widget> _children = [
    HomePage(),
    HistoryPage(),
    ChatPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 2) { // If the chat tab is selected, reset the unread messages count
      unreadMessagesModel.reset();
    }
  }

  @override
  void initState() {
    super.initState();
    unreadMessagesModel = UnreadMessagesModel();
    final channel = IOWebSocketChannel.connect('ws://10.0.2.2:9090/user');
    channel.stream.listen((message) {
      if (_currentIndex != 2) { // If the chat tab is not selected, increment the unread messages count
        unreadMessagesModel.increment();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: unreadMessagesModel,
      child: Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.black,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Consumer<UnreadMessagesModel>(
                builder: (context, unreadMessagesModel, child) => Stack(
                  children: [
                    Icon(Icons.chat),
                    if (unreadMessagesModel.count > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            unreadMessagesModel.count > 99 ? '99+' : unreadMessagesModel.count.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}











