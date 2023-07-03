import 'package:flutter/material.dart';

class UnreadMessagesModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    if (_count < 99) {
      _count++;
    }
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}



