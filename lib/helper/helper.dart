import 'package:shared_preferences/shared_preferences.dart';

class Helper_functions {
  static String user_logged_in_key = "LOGGEDINKEY";
  static String user_name_key = "USERNAMEKEY";
  static String user_email_key = "USEREMAILKEY";

  static Future<bool?> get_user_logged_in_status() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(user_logged_in_key);
  }
}
