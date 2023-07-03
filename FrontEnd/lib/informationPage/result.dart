import 'package:intl/intl.dart';

class Result {
  final String username;
  final String signInTime;
  final String signOutTime;
  final String location; 
  final String notice; 

  Result({
    required this.username,
    required this.signInTime,
    required this.signOutTime,
    required this.location,
    required this.notice,
  });

  factory Result.fromJson(Map<String, dynamic> jsonSignIn, Map<String, dynamic>? jsonSignOut) {
    DateTime signInDateTime = DateTime.parse(jsonSignIn['time']);
    String formattedSignInTime = DateFormat('HH:mm').format(signInDateTime);

    DateTime? signOutDateTime;
    String formattedSignOutTime = 'N/A';

    if (jsonSignOut != null) {
      signOutDateTime = DateTime.parse(jsonSignOut['time']);
      formattedSignOutTime = DateFormat('HH:mm').format(signOutDateTime);
    }

    return Result(
      username: jsonSignIn['username'].toString(),
      signInTime: formattedSignInTime,
      signOutTime: formattedSignOutTime,
      location: jsonSignIn['location'] ?? "N/A",
      notice: jsonSignIn['notice'] ?? "N/A",
    );
  }
}





