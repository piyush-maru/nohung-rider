import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanGetProfile.dart';

import 'package:rider_app/model/getCureentOrders.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/screen/OrderScreen.dart';
import 'package:rider_app/screen/StartDeliveryScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/PrefManager.dart';
import 'package:rider_app/utils/Utils.dart';
import '../res.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String order_id = '';
  String order_items_id = '';
  String deliveryAddress = '';
  bool acceptedOrders = false;

  var _visible = true;
  AnimationController? animationController;
  Animation<double>? animation;

  startTime(bool acceptedOrder, bool OrderStatus) async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, () {
      navigationPage(acceptedOrder, OrderStatus);
    });
  }

  void navigationPage(bool acceptedOrder, bool OrderStatus) async {
    bool? isLogin = await getLogin();

    if (isLogin == true) {
      bool isLogined = false;
      try {
        isLogined = await PrefManager.getBool(AppConstant.session);
      } catch (e) {
        isLogined = false;
      }
      if (isLogined) {
        if (acceptedOrder) {
          // if (OrderStatus) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => OrderScreen(0)));
          // } else {
          //   Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => StartDeliveryScreen(
          //               deliveryAddress, order_id, order_items_id)));
          // }
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/loginSignUp');
      }
    } else {
      Timer(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/loginSignUp');
      });
    }
  }

  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));

    animation = new CurvedAnimation(
        parent: animationController!, curve: Curves.bounceInOut);
    // animation!.addListener(() => this.setState(() {}));
    animationController!.forward();
    getProfile(context);
    // setState(() {
    _visible = !_visible;
    // });
  }

  @override
  dispose() {
    animationController!.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Stack(
        children: [
          Image.asset(
            Res.ic_bg,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
          Center(
            child: Image.asset(Res.ic_logo,
                width: animation!.value * 100, height: animation!.value * 100),
          ),
        ],
      ),
    ));
  }

  Future getCurrentOrders(BuildContext context) async {
    try {
      var user = await Utils.getUser();

      FormData from =
          FormData.fromMap({"userid": user.data!.userId, "token": "123456789"});

      GetCurrentOrdersModel bean = await ApiProvider().getCurrentOrders(from);
      if (bean.status == true) {
        setState(() {
          acceptedOrders = bean.status ?? false;
          order_id = bean.data![0].orderId ?? "";
          order_items_id = bean.data![0].orderitemsId ?? '';
          deliveryAddress = bean.data![0].deliveryaddress ?? '';

          startTime(acceptedOrders,
              bean.data![0].status == 'Assign to rider' ? true : false);
        });
        return bean;
      } else {
        setState(() {
          acceptedOrders = false;
          startTime(acceptedOrders, false);
        });
      }

      // await getProfile(context);
      return null;
    } on HttpException catch (exception) {
      print(exception);
    } on FormatException catch (e) {
      var _duration = new Duration(seconds: 3);
      Timer(_duration, () {
        Navigator.pushReplacementNamed(context, '/loginSignUp');
      });
    } catch (exception) {
      print(exception);
    }
  }

  Future getProfile(BuildContext context) async {
    try {
      bool? isLogin = await getLogin();
      if (isLogin == true) {
        var user = await Utils.getUser();
        FormData from = FormData.fromMap(
            {"user_id": user.data!.userId, "token": "123456789"});
        GetProfile beanDetails = await ApiProvider().getProfile(from);
        if (beanDetails.status == true) {
          if (beanDetails.data![0].acceptenceStatus == '0') {
            saveRiderStatus(false);
            Utils.showToast("Session Expired Please login Again");
            Navigator.pushReplacementNamed(context, '/loginSignUp');
          } else if (beanDetails.data![0].status == '0') {
            saveRiderStatus(false);
            Utils.showToast("Session Expired Please login Again");
            Navigator.pushReplacementNamed(context, '/loginSignUp');
          }
          await getCurrentOrders(context);
          return beanDetails;
        } else {
          Utils.showToast("Session Expired Please login Again");
          saveLogin(false);
          PrefManager.clear();
          Navigator.pushReplacementNamed(context, '/loginSignUp');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/loginSignUp');
      }
      return null;
    } on HttpException catch (exception) {
      print(exception);
    } catch (exception) {
      print(exception);
    }
  }
}
