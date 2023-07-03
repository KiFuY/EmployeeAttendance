import 'package:attendance/Pages/tabs.dart';
import 'package:attendance/changeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:attendance/login/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';


Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

   runApp(
    ChangeNotifierProvider(
      create: (context) => UnreadMessagesModel(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unreadMessagesModel = Provider.of<UnreadMessagesModel>(context, listen: false);
    final channel = IOWebSocketChannel.connect('ws://10.0.2.2:9090/user');
    channel.stream.listen((message) {
      unreadMessagesModel.increment();
    });

    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: isLoggedIn ? '/tabs' : '/login',  // Set initial route based on login status
      routes: {
        '/login': (context) => const LoginPage(),
        '/tabs' :(context) => const Tabs(),
      },
    );
  }
}













