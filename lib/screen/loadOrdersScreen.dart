import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanAcceptOrder.dart';
import 'package:rider_app/model/BeanGetOrder.dart';
// import 'package:rider_app/model/GetOrderDetails.dart';
import 'package:rider_app/model/BeanSignUp.dart' as userSi;
import 'package:rider_app/model/BeanrejectOrder.dart';
import 'package:rider_app/model/getCureentOrders.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/res.dart';
import 'package:rider_app/screen/OrderScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';

class OrdersScreen extends StatefulWidget {
  int? tabIndex;
  OrdersScreen(this.tabIndex);
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

enum riderCancelReasons {
  location_so_far,
  vehicle_ssue,
  previous_order_pending,
  other
}

class _OrdersScreenState extends State<OrdersScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog? progressDialog;

  bool locationSoFar = false;
  bool vehicleIssue = false;
  bool previousOrderPending = false;
  bool other = false;
  var description_controller = TextEditingController();
  bool? isBackground = false;
  riderCancelReasons? _cancelOp;

  String numberOfOrders = '';

  Location location = new Location();
  var expectedEarning = "";
  var tripDistance = "";
  var deliveryLat = "";
  var deliveryLong = "";
  Timer? timer;
  bool? riderStatus = true;
  userSi.BeanSignUp? user;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<BeanGetOrder?>? _future;
  int oldOrderLenght = 0;
  @override
  void initState() {
    getUserData();
    Future.delayed(Duration.zero, () async {
      _future = getOrders(context);
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState != null) {
      // _stateHistoryList.add(WidgetsBinding.instance.lifecycleState!);
    }
    const twentyMillis = Duration(seconds: 20);
    timer = Timer.periodic(twentyMillis, (timer) {
      if (riderStatus == true) {
        _future = getOrders(context);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationData _currentPosition = await location.getLocation();
    setState(() {
      deliveryLong = _currentPosition.longitude.toString();
      deliveryLat = _currentPosition.latitude.toString();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      setState(() {
        isBackground = true;
      });
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        isBackground = false;
      });
    } else if (AppLifecycleState.paused == state) {
      setState(() {
        isBackground = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<void> getUserData() async {
    riderStatus = await getRiderStatus();
    var userdata = await Utils.getUser();
    setState(() {
      user = userdata;
      riderStatus = riderStatus;
    });
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration.zero, () {
      getUserData();
      if (riderStatus == true) {
        setState(() {
          _future = getOrders(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    progressDialog = ProgressDialog(context);
    return riderStatus ?? true
        ? _future != null
            ? FutureBuilder<BeanGetOrder?>(
                future: _future,
                builder: (context, projectSnap) {
                  if (projectSnap.connectionState == ConnectionState.done) {
                    var result;
                    if (projectSnap.data != null) {
                      result = projectSnap.data!.data;
                      if (result != null) {
                        numberOfOrders = result.length.toString();

                        return (result.length == 0)
                            ? RefreshIndicator(
                                key: _refreshIndicatorKey,
                                onRefresh: _pullRefresh,
                                child: SingleChildScrollView(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        1.5,
                                    child: Center(
                                      child: Text(
                                        "No Order Available",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontFamily: AppConstant.fontBold),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                key: _refreshIndicatorKey,
                                onRefresh: _pullRefresh,
                                // child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  // physics: AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return getOrdersList(result[index]);
                                  },
                                  itemCount: result.length,
                                ),
                                // ),
                              );
                      } else {
                        RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _pullRefresh,
                          child: SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 1.5,
                              child: Center(
                                child: Text(
                                  "No Order Available",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: AppConstant.fontBold),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _pullRefresh,
                        child: SingleChildScrollView(
                          child: Container(
                            height: MediaQuery.of(context).size.height / 1.5,
                            child: Center(
                              child: Text(
                                "No Order Available",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: AppConstant.fontBold),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        color: Colors.yellow,
                      ),
                    ),
                  );
                },
              )
            : RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _pullRefresh,
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: Center(
                      child: Text(
                        "No Order Available",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: AppConstant.fontBold),
                      ),
                    ),
                  ),
                ),
              )
        : RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _pullRefresh,
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height / 1.4,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 151, 41, 41),
                      border: Border.all(
                          color: const Color.fromARGB(255, 151, 41, 41)),
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.15),
                            blurRadius: 30),
                      ],
                    ),

                    margin: EdgeInsets.fromLTRB(_w / 30, 0, _w / 30, 0),
                    // height: _w / 5,
                    padding: EdgeInsets.all(_w / 30),

                    // child: const Padding(
                    //   padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      child: const Text(
                        "Your Status is Offline.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // ),
                  ),
                ),
              ),
              physics: AlwaysScrollableScrollPhysics(),
            ),
          );
  }

  Widget getOrdersList(Data result) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppConstant.lightGreen)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Image.asset(
                  Res.ic_circle_avatar,
                  width: 50,
                  height: 50,
                ),
              ),
              Expanded(
                child: Padding(
                  child: Text(
                    result.kitchenName.toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: AppConstant.fontBold),
                  ),
                  padding: EdgeInsets.only(left: 16),
                ),
              ),
              InkWell(
                onTap: () {
                  acceptOrder(result.orderId ?? "", result.orderItemsId ?? "");
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => OrderScreen()),
                  // );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, right: 16),
                  child: Image.asset(
                    Res.ic_check,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              InkWell(
                onTap: () => {
                  showCancelDialog(context, result),
                  // rejectOrder(result.orderId ?? '', result.orderItemsId ?? '');
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 1, top: 10, right: 16),
                  child: Image.asset(
                    Res.ic_cross,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                child: Text(
                  "Order No:",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: AppConstant.fontBold),
                ),
                padding: EdgeInsets.only(left: 75, bottom: 6),
              ),
              Padding(
                child: Text(
                  "${result.orderNumber}",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: AppConstant.fontBold),
                ),
                padding: EdgeInsets.only(left: 16),
              ),
            ],
          ),
          Divider(
            color: Colors.grey,
          ),
          SizedBox(
            height: 5,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: EdgeInsets.only(left: 15),
                // width: MediaQuery.of(context).size.width / 1.8,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green.shade300, // red as border color
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Pickup-By",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: AppConstant.fontBold),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          Res.ic_time,
                          width: 15,
                          height: 15,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          " ${result.deliveryDate} ${result.pickTime}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: AppConstant.fontBold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                // width: MediaQuery.of(context).size.width / 1.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Pickup Distance",
                      style: TextStyle(
                          color: Color.fromARGB(255, 101, 97, 97),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          Res.ic_location,
                          width: 16,
                          height: 16,
                        ),
                        Text(
                          " ${result.pickDistance} km",
                          style: TextStyle(
                              color: Color.fromARGB(255, 101, 97, 97),
                              fontSize: 14,
                              fontFamily: AppConstant.fontBold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 10),
                    child: Image.asset(
                      Res.ic_location,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      child: Text(
                        result.kitchenAddress.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: AppConstant.fontBold),
                      ),
                      padding: EdgeInsets.only(left: 5),
                    ),
                  )
                ],
              )
            ],
          ),
          Divider(
            color: Colors.grey,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: EdgeInsets.only(left: 15),
                // width: MediaQuery.of(context).size.width / 1.8,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green.shade300, // red as border color
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Delivery By ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: AppConstant.fontBold),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          Res.ic_time,
                          width: 15,
                          height: 15,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          " ${result.deliveryDate} ${result.deliveryTime}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: AppConstant.fontBold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                // width: MediaQuery.of(context).size.width / 1.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Delivery Distance",
                      style: TextStyle(
                        color: Color.fromARGB(255, 101, 97, 97),
                        fontSize: 14,
                        fontFamily: AppConstant.fontBold,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Image.asset(
                          Res.ic_location,
                          width: 16,
                          height: 16,
                        ),
                        Text(
                          " ${result.delDistance} km",
                          style: TextStyle(
                              color: Color.fromARGB(255, 101, 97, 97),
                              fontSize: 14,
                              fontFamily: AppConstant.fontBold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 10),
                    child: Image.asset(
                      Res.ic_location,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      child: Text(
                        result.deliveryAddress.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: AppConstant.fontBold),
                      ),
                      padding: EdgeInsets.only(left: 5),
                    ),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Future<BeanGetOrder?>? getOrders(BuildContext context) async {
    try {
      // var user = await Utils.getUser();
      FormData from2 = FormData.fromMap(
          {"userid": user!.data!.userId, "token": "123456789"});
      GetCurrentOrdersModel bean1 = await ApiProvider().getCurrentOrders(from2);
      if (bean1.status == true && bean1.data!.length > widget.tabIndex!) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => OrderScreen(0)));
      } else {
        FormData from;
        // var user = await Utils.getUser();
        if (isBackground == false) {
          LocationData _currentPosition = await location.getLocation();
          setState(() {
            deliveryLong = _currentPosition.longitude.toString();
            deliveryLat = _currentPosition.latitude.toString();
          });
          from = FormData.fromMap({
            "userid": user!.data!.userId,
            "longitude": _currentPosition.longitude.toString(),
            "latitude": _currentPosition.latitude.toString(),
            // "longitude": '80.3875088',
            // "latitude": '16.9554852',
            "token": "123456789"
          });
        } else {
          from = FormData.fromMap({
            "userid": user!.data!.userId,
            "longitude": deliveryLong,
            "latitude": deliveryLat,
            // "longitude": '80.3875088',
            // "latitude": '16.9554852',
            "token": "123456789"
          });
        }
        BeanGetOrder bean = await ApiProvider().getOrder(from);
        if (bean.status == true && bean.data != null) {
          if (bean.status == true &&
              bean.data!.length > 0 &&
              riderStatus == true) {
            int? lenght = await getOrdersCount();
            if (bean.data!.length > (lenght ?? 0)) {
              PerfectVolumeControl.setVolume(1);
              AudioPlayer().play(AssetSource('notification_sound.mp3'));
            }
            setState(() {
              saveOrdersCount(bean.data!.length);
              oldOrderLenght = bean.data!.length;
              expectedEarning = bean.global!.expectedEarnings.toString();
              tripDistance = bean.global!.tripDistance.toString();
              numberOfOrders = bean.data!.length.toString();
              deliveryLat = bean.data![0].deliveryLat ?? "";
              deliveryLong = bean.data![0].deliveryLong ?? "";
            });

            return bean;
          } else {
            setState(() {
              if (bean.data!.length == 0) {
                saveOrdersCount(0);
              }
              expectedEarning = '0';
              tripDistance = '0';
              numberOfOrders = '0';
            });
            return bean;
          }
        } else {
          setState(() {
            _future = null;
            saveOrdersCount(0);
            expectedEarning = '';
            tripDistance = '';
            numberOfOrders = '0';
          });
          return null;
        }
      }
    } on HttpException catch (exception) {
      print(exception);
    } catch (exception) {
      print(exception);
    }
  }

  void rejectOrderValidation(String? orderid, String? orderitemsId) {
    if (_cancelOp!.name == null) {
      Utils.showToast("Please select Rejecting Reason!");
    } else if (_cancelOp!.name == "other" &&
        description_controller.text == '') {
      Utils.showToast("Please Enter the Description!");
    } else {
      rejectOrder(orderid ?? '0', orderitemsId ?? '0');
    }
  }

  Future<BeanRejectOrder?> rejectOrder(
      String orderid, String orderitems_id) async {
    progressDialog!.show();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": orderid,
        'orderitems_id': orderitems_id,
        'reason': (_cancelOp!.name == "location_so_far"
            ? "Location So Far,"
            : (_cancelOp!.name == "vehicle_ssue"
                ? "Vehicle Issue"
                : (_cancelOp!.name == "previous_order_pending"
                    ? "Previous Order Pending"
                    : "Others"))),
        // 'reason': ((locationSoFar == true ? "Location So Far," : "") +
        //     (vehicleIssue == true ? "Vehicle Issue," : '') +
        //     (previousOrderPending == true ? "Previous Order Pending," : "") +
        //     (other == true ? "Other" : "")),
        'description': description_controller.text
      });
      BeanRejectOrder bean = await ApiProvider().rejectOrder(from);

      if (bean.status == true) {
        progressDialog!.dismiss();
        Utils.showToast(bean.message ?? "");
        Navigator.pop(context, 'Cancel');
        setState(() {
          _future = getOrders(context);
        });

        return bean;
      } else {
        progressDialog!.dismiss();
      }

      return null;
    } on HttpException catch (exception) {
      progressDialog!.dismiss();
      print(exception);
    } catch (exception) {
      progressDialog!.dismiss();
      print(exception);
    }
  }

  Future<BeanAcceptOrder?> acceptOrder(
      String orderid, String orderitems_id) async {
    progressDialog?.show();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": orderid,
        "orderitems_id": orderitems_id
      });
      BeanAcceptOrder bean = await ApiProvider().acceptOrder(from);

      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        Navigator.pop(context, 'Cancel');
        progressDialog!.dismiss();
        timer!.cancel();
        setState(() {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderScreen(widget.tabIndex)));
        });
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => OrderScreen()),
        // ).then((value) {
        //   setState(() {
        //     _future = getOrders(context);
        //   });
        // });

        return bean;
      } else {
        progressDialog!.dismiss();
        Utils.showToast(bean.message ?? "");
        // setState(() {
        //   Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => OrderScreen(widget.tabIndex)));
        // });
      }

      return null;
    } on HttpException catch (exception) {
      progressDialog?.dismiss();
      print(exception);
    } catch (exception) {
      progressDialog?.dismiss();
      print(exception);
    }
  }

  Future<void> showCancelDialog(BuildContext context, Data result) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Cancel Ride'),
              content: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _cancelOp = riderCancelReasons.location_so_far;
                            });
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: const Text(
                                "Location So Far",
                                style: TextStyle(fontSize: 14),
                              )),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 5,
                          child: Radio<riderCancelReasons>(
                            activeColor: Colors.green[400],
                            value: riderCancelReasons.location_so_far,
                            groupValue: _cancelOp,
                            onChanged: (riderCancelReasons? value) {
                              setState(() {
                                _cancelOp = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _cancelOp = riderCancelReasons.vehicle_ssue;
                            });
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: const Text(
                                "Vehicle Issue",
                                style: TextStyle(fontSize: 14),
                              )),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 5,
                          child: Radio<riderCancelReasons>(
                            activeColor: Colors.green[400],
                            value: riderCancelReasons.vehicle_ssue,
                            groupValue: _cancelOp,
                            onChanged: (riderCancelReasons? value) {
                              setState(() {
                                _cancelOp = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _cancelOp =
                                  riderCancelReasons.previous_order_pending;
                            });
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: const Text(
                                "Previous Order Pending",
                                style: TextStyle(fontSize: 14),
                              )),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 5,
                          child: Radio<riderCancelReasons>(
                            activeColor: Colors.green[400],
                            value: riderCancelReasons.previous_order_pending,
                            groupValue: _cancelOp,
                            onChanged: (riderCancelReasons? value) {
                              setState(() {
                                _cancelOp = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _cancelOp = riderCancelReasons.other;
                            });
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: const Text(
                                "Other",
                                style: TextStyle(fontSize: 14),
                              )),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 5,
                          child: Radio<riderCancelReasons>(
                            activeColor: Colors.green[400],
                            value: riderCancelReasons.other,
                            groupValue: _cancelOp,
                            onChanged: (riderCancelReasons? value) {
                              setState(() {
                                _cancelOp = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            maxLines: 8, //or null
                            decoration: InputDecoration.collapsed(
                                hintText: "Description"),
                            controller: description_controller,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        elevation: 10, // Change this
                        shadowColor: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, 'Cancel'),
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 5, right: 5, bottom: 5, top: 5),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff7ED39C),
                              Color(0xff7ED39C),
                              Color(0xff7ED39C),
                              Color(0xff089E90)
                            ],
                            begin: Alignment.bottomLeft,
                            stops: [0, 0, 0, 1],
                          ),
                        ),
                        child: Center(
                          child: Center(
                            child: Text(
                              "Back",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: AppConstant.fontBold,
                                  fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () => {
                        rejectOrderValidation(
                            result.orderId ?? '', result.orderItemsId ?? '')
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 5, right: 5, bottom: 5, top: 5),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 233, 181, 136),
                              Color.fromARGB(255, 211, 187, 126),
                              Color.fromARGB(255, 213, 186, 89),
                              Color.fromARGB(255, 229, 191, 21)
                            ],
                            begin: Alignment.bottomLeft,
                            stops: [0, 0, 0, 1],
                          ),
                        ),
                        child: Center(
                          child: Center(
                            child: Text(
                              "Cancel Ride",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: AppConstant.fontBold,
                                  fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }
}
