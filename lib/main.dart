import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:rider_app/screen/AgreementAndPolicyScreen.dart';
import 'package:rider_app/screen/CustomerFeedback.dart';
import 'package:rider_app/screen/CustomerChatScreen.dart';
import 'package:rider_app/screen/FeedbackScreen.dart';
import 'package:rider_app/screen/FilterScreen.dart';
import 'package:rider_app/screen/ForgotPasswordScreen.dart';  
import 'package:rider_app/screen/HomeScreen.dart';
import 'package:rider_app/screen/LoginSignUpScreen.dart';
import 'package:rider_app/screen/OrderScreen.dart';
import 'package:rider_app/screen/ProfileScreen.dart';
import 'package:rider_app/screen/SplashScreen.dart';
import 'package:rider_app/screen/OrderHistoryscreen.dart';
import 'package:rider_app/utils/Log.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  _initLog();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) async {
    runApp(App());
  });
}

void _initLog() {
  Log.init();
  Log.setLevel(Level.ALL);  
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Rider App",
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => makeRoute(
                context: context,
                routeName: settings.name ?? '',
                arguments: settings.arguments ?? ''),
            maintainState: true,
            fullscreenDialog: false,
          );
        });
  }

  Widget makeRoute(
      {required BuildContext context,
      required String routeName,
      Object? arguments}) {
    final Widget child = _buildRoute(
        context: context, routeName: routeName, arguments: arguments);
    return child;
  }

  Widget _buildRoute({
    required BuildContext context,
    required String routeName,
    Object? arguments,
  }) {
    switch (routeName) {
      case '/':
        return SplashScreen();
      case '/loginSignUp':
        return LoginSignUpScreen();
      case '/home':
        return HomeScreen();
      case '/order':
        return OrderScreen(0);
      case '/customerfeedback':
        return CustomerFeedback();
      case '/feedback':
        return FeedbackScreen();
      case '/forgot':
        return ForgotPasswordScreen();
      case '/orderhistory':
        return OrderHistoryscreen("", "", "", "");
      case '/filter':
        return FilterScreen();
      case '/profile':
        return ProfileScreen();
      case '/chat':
        return CustomerChatScreen();
      case '/policy':
        return AgreementAndPolicyScreen();
      default: 
        throw 'Route $routeName is not defined';
    }
  }
}

Future<bool?> getLogin() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool("login");
}

Future<bool> saveLogin(bool isLogin) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return await preferences.setBool("login", isLogin);
}

Future<String?> getSessionId() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString("session_id");
}

Future<bool> saveSessionId(String name) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return await preferences.setString("session_id", name);
}

Future<bool?> getRiderStatus() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool('rider_status');
}

Future<bool> saveRiderStatus(bool riderStatus) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return await preferences.setBool("rider_status", riderStatus);
}

Future<int?> getOrdersCount() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getInt('orders_count');
}

Future<bool> saveOrdersCount(int ordersCount) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return await preferences.setInt("orders_count", ordersCount);
}

Future<List<String>?> getReassignedOrders() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getStringList('reassigned_orders');
}

Future<bool> saveReassignedOrders(String orderNumber) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<String>? reassigedlist = await getReassignedOrders();
  reassigedlist == null
      ? reassigedlist = [orderNumber]
      : reassigedlist.add(orderNumber);
  var seen = Set<String>();
  List<String>? newList =
      reassigedlist.where((orderNumber) => seen.add(orderNumber)).toList();
  return await preferences.setStringList("reassigned_orders", newList);
}
