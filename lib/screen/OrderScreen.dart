import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanGetOrder.dart';
import 'package:rider_app/model/getCureentOrders.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/res.dart';
import 'package:rider_app/screen/MyDrawer.dart';
import 'package:rider_app/screen/StartDeliveryScreen.dart';
import 'package:rider_app/screen/loadAcceptedOrderScreen.dart';
import 'package:rider_app/screen/loadOrdersScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rider_app/model/BeanSignUp.dart' as userSi;

class OrderScreen extends StatefulWidget {
  int? tabIndex;
  OrderScreen(this.tabIndex);
  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  var isSelected = 1;
  var pickupBy = "";
  var kitchenName = "";
  // var location = "";
  var name = "";
  var deliveryAddress = "";
  var itemDetails = "";
  var kitchenContact = "";
  var orderNumber = '';
  Location _locationTracker = new Location();
  var status = "";
  bool _hasCallSupport = false;

  String order_id = '';
  String order_items_id = '';
  bool acceptedOrders = false;

  bool onTheWayToCollectFood = false;
  bool arrivedAtKitchen = false;
  bool orderGettingReady = false;
  bool collectedAndDeliveyInProgress = false;
  // Dealy
  bool other = false;
  bool stuckInTraffic = false;
  bool roadClosedDivertNewRoute = false;
  bool newDeliveryAddressDivertedByCustomer = false;
  bool acceptedOrder = false;
  bool orderStatus = false;
// Issue Note

  AcceptedData? orderData1;
  AcceptedData? orderData2;
  AcceptedData? orderData3;
  AcceptedData? orderData4;
  AcceptedData? orderData5;
  AcceptedData? orderData6;
  AcceptedData? orderData7;
  AcceptedData? orderData8;
  AcceptedData? orderData9;
  AcceptedData? orderData10;
  int? currentOrderCount = 0;
  bool isPageLoading = true;

//heavyTrafficDeliveryTimeIssue
  bool heavyTrafficDeliveryTimeIssue = false;
  bool addressNotFound = false;
  bool customerBlamesHeDidntPlaceAnOrder = false;
  bool customerNotAcceptingTheOrder = false;
  // bool other = false;
  bool customerDoorClosed = false;
  Future<BeanGetOrder?>? _future;
  TabController? _tabController;

  ProgressDialog? progressDialog;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future? future;
  bool? riderStatus = true;
  userSi.BeanSignUp? user;
  bool? isBackground = false;
  Timer? timer;
  Location location = new Location();
  var deliveryLat = "";
  var deliveryLong = "";

  @override
  void initState() {
    getUserData();
    Future.delayed(Duration.zero, () async {
      _future = getOrders(context);
    });
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
    getCurrentOrders(context);
    _tabController = TabController(length: 10, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _tabController!.index = widget.tabIndex ?? 0;

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

  void _handleTabSelection() {
    setState(() {});
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

  Future<BeanGetOrder?>? getOrders(BuildContext context) async {
    try {
      // var user = await Utils.getUser();
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
          });

          return bean;
        } else {
          setState(() {
            if (bean.data!.length == 0) {
              saveOrdersCount(0);
            }
          });
          return bean;
        }
      }
    } on HttpException catch (exception) {
      print(exception);
    } catch (exception) {
      print(exception);
    }
  }

  // Future<void> _pullRefresh() async {

  //   await Future.delayed(Duration.zero, () {
  //     setState(() {
  //       getCurrentOrders(context);
  //     });
  //   });
  // }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: kitchenContact,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);

    return Scaffold(
        drawer: MyDrawers(),
        key: _scaffoldKey,
        backgroundColor: AppConstant.lightGreen,
        body: Stack(
          children: [
            Container(
                margin: EdgeInsets.only(top: 200),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(38),
                        topLeft: Radius.circular(38))),
                height: double.infinity,
                child: method()),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 52, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _scaffoldKey.currentState!.openDrawer();
                          });
                        },
                        child: Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Image.asset(
                              Res.ic_menu,
                              width: 40,
                              height: 40,
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        "New Orders",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppConstant.fontBold,
                            fontSize: 22),
                      ),
                    ],
                  ),
                  Image.asset(
                    Res.ic_noti,
                    width: 25,
                    height: 25,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, top: 100, right: 16),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(35))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                      color: Color.fromARGB(254, 208, 255, 0),
                    ),
                    isScrollable: true,
                    labelStyle:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    indicatorSize: TabBarIndicatorSize.label,
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black,
                    tabs: [
                      currentOrderCount! >= 0
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 0)
                                      ? Colors.transparent
                                      : orderData1 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Tab(
                                  text:
                                      'Order1  ${(orderData1 != null && _tabController!.index != 0) ? '\u00B0' : ''}', //Icons.sync_problem_sharp,
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 1
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 1)
                                      ? Colors.transparent
                                      : orderData2 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order2 ${(orderData2 != null && _tabController!.index != 1) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 2
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 2)
                                      ? Colors.transparent
                                      : orderData3 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order3  ${(orderData3 != null && _tabController!.index != 2) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 3
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 3)
                                      ? Colors.transparent
                                      : orderData4 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order4  ${(orderData4 != null && _tabController!.index != 3) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 4
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 4)
                                      ? Colors.transparent
                                      : orderData5 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order5  ${(orderData5 != null && _tabController!.index != 4) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 5
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 5)
                                      ? Colors.transparent
                                      : orderData6 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order6  ${(orderData6 != null && _tabController!.index != 5) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 6
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 6)
                                      ? Colors.transparent
                                      : orderData7 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order7  ${(orderData7 != null && _tabController!.index != 6) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 7
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 7)
                                      ? Colors.transparent
                                      : orderData8 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order8  ${(orderData8 != null && _tabController!.index != 7) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 8
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 8)
                                      ? Colors.transparent
                                      : orderData9 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order9  ${(orderData9 != null && _tabController!.index != 8) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                      currentOrderCount! >= 9
                          ? Container(
                              decoration: BoxDecoration(
                                  color: (_tabController!.index == 9)
                                      ? Colors.transparent
                                      : orderData10 != null
                                          ? Colors.yellow.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Tab(
                                  text:
                                      'Order10  ${(orderData10 != null && _tabController!.index != 9) ? '\u00B0' : ''}',
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  method() {
    return isPageLoading == false
        ? TabBarView(
            controller: _tabController,
            children: [
              // acceptedOrder
              //     ? (orderStatus
              //         ? method1()
              //         : StartDeliveryScreen(
              //             deliveryAddress, widget.orderID, widget.orderItemsId))
              //     : OrdersScreen(),
              // RefreshIndicator(
              //   key: _refreshIndicatorKey,
              //   onRefresh: _pullRefresh,
              //   child:
              currentOrderCount! >= 0
                  ? orderData1 != null
                      ? (orderData1!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData1!.deliveryaddress,
                              orderData1!.orderNumber ?? '0',
                              orderData1!.orderId ?? '0',
                              orderData1!.orderitemsId ?? '0',
                              orderData1!.customerNumber,
                              orderData1!.kitchenNumber,
                              orderData1!.deliveryTime,
                              0,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData1!, 0, currentOrderCount))
                      : OrdersScreen(0)
                  : Container(),
              // ),
              currentOrderCount! >= 1
                  ? orderData2 != null
                      ? (orderData2!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData2!.deliveryaddress,
                              orderData2!.orderNumber ?? '0',
                              orderData2!.orderId ?? '0',
                              orderData2!.orderitemsId ?? '0',
                              orderData2!.customerNumber,
                              orderData2!.kitchenNumber,
                              orderData2!.deliveryTime,
                              1,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData2!, 1, currentOrderCount))
                      : OrdersScreen(1)
                  : Container(),
              currentOrderCount! >= 2
                  ? orderData3 != null
                      ? (orderData3!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData3!.deliveryaddress,
                              orderData3!.orderNumber ?? '0',
                              orderData3!.orderId ?? '0',
                              orderData3!.orderitemsId ?? '0',
                              orderData3!.customerNumber,
                              orderData3!.kitchenNumber,
                              orderData3!.deliveryTime,
                              2,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData3!, 2, currentOrderCount))
                      : OrdersScreen(2)
                  : Container(),
              currentOrderCount! >= 3
                  ? orderData4 != null
                      ? (orderData4!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData4!.deliveryaddress,
                              orderData4!.orderNumber ?? '0',
                              orderData4!.orderId ?? '0',
                              orderData4!.orderitemsId ?? '0',
                              orderData4!.customerNumber,
                              orderData4!.kitchenNumber,
                              orderData4!.deliveryTime,
                              3,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData4!, 3, currentOrderCount))
                      : OrdersScreen(3)
                  : Container(),
              currentOrderCount! >= 0
                  ? orderData5 != null
                      ? (orderData5!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData5!.deliveryaddress,
                              orderData5!.orderNumber ?? '0',
                              orderData5!.orderId ?? '0',
                              orderData5!.orderitemsId ?? '0',
                              orderData5!.customerNumber,
                              orderData5!.kitchenNumber,
                              orderData5!.deliveryTime,
                              4,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData5!, 4, currentOrderCount))
                      : OrdersScreen(4)
                  : Container(),
              currentOrderCount! >= 5
                  ? orderData6 != null
                      ? (orderData6!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData6!.deliveryaddress,
                              orderData6!.orderNumber ?? '0',
                              orderData6!.orderId ?? '0',
                              orderData6!.orderitemsId ?? '0',
                              orderData6!.customerNumber,
                              orderData6!.kitchenNumber,
                              orderData6!.deliveryTime,
                              0,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData6!, 5, currentOrderCount))
                      : OrdersScreen(5)
                  : Container(),
              currentOrderCount! >= 6
                  ? orderData7 != null
                      ? (orderData7!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData7!.deliveryaddress,
                              orderData7!.orderNumber ?? '0',
                              orderData7!.orderId ?? '0',
                              orderData7!.orderitemsId ?? '0',
                              orderData7!.customerNumber,
                              orderData7!.kitchenNumber,
                              orderData7!.deliveryTime,
                              0,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData7!, 6, currentOrderCount))
                      : OrdersScreen(6)
                  : Container(),
              currentOrderCount! >= 7
                  ? orderData8 != null
                      ? (orderData8!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData8!.deliveryaddress,
                              orderData8!.orderNumber ?? '0',
                              orderData8!.orderId ?? '0',
                              orderData8!.orderitemsId ?? '0',
                              orderData8!.customerNumber,
                              orderData8!.kitchenNumber,
                              orderData8!.deliveryTime,
                              0,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData8!, 7, currentOrderCount))
                      : OrdersScreen(7)
                  : Container(),
              currentOrderCount! >= 8
                  ? orderData9 != null
                      ? (orderData9!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData9!.deliveryaddress,
                              orderData9!.orderNumber ?? '0',
                              orderData9!.orderId ?? '0',
                              orderData9!.orderitemsId ?? '0',
                              orderData9!.customerNumber,
                              orderData9!.kitchenNumber,
                              orderData9!.deliveryTime,
                              0,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData9!, 8, currentOrderCount))
                      : OrdersScreen(8)
                  : Container(),
              currentOrderCount! >= 9
                  ? orderData10 != null
                      ? (orderData10!.status == 'Start Delivery'
                          ? StartDeliveryScreen(
                              orderData10!.deliveryaddress,
                              orderData10!.orderNumber ?? '0',
                              orderData10!.orderId ?? '0',
                              orderData10!.orderitemsId ?? '0',
                              orderData10!.customerNumber,
                              orderData10!.kitchenNumber,
                              orderData10!.deliveryTime,
                              0,
                              currentOrderCount)
                          : AcceptedOrderScreen(
                              orderData10!, 9, currentOrderCount))
                      : OrdersScreen(9)
                  : Container(),

              // orderScreen1(),
              // orderScreen1(),
              // orderScreen1(),
              // orderScreen1(),

              // // first tab bar view widget
              // RequestScreen(),
              // ActiveScreen(),
              // UpcomingScreen(),
              // OrdersHistory(),
              // // TrialRequestScreen(),
              // LiveOrdersScreen(),
              // // second tab bar view widget
            ],
          )
        : Container(
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          );
  }

  Future getCurrentOrders(BuildContext context) async {
    try {
      var user = await Utils.getUser();
      FormData from =
          FormData.fromMap({"userid": user.data!.userId, "token": "123456789"});
      GetCurrentOrdersModel bean = await ApiProvider().getCurrentOrders(from);
      if (bean.status == true) {
        setState(() {
          currentOrderCount = bean.data!.length;
          if ((bean.data!.length) >= 1) {
            orderData1 = bean.data![0];
          }
          if ((bean.data!.length) >= 2) {
            orderData2 = bean.data![1];
          }
          if ((bean.data!.length) >= 3) {
            orderData3 = bean.data![2];
          }
          if ((bean.data!.length) >= 4) {
            orderData4 = bean.data![3];
          }
          if ((bean.data!.length) >= 5) {
            orderData5 = bean.data![4];
          }
          if ((bean.data!.length) >= 6) {
            orderData6 = bean.data![5];
          }
          if ((bean.data!.length) >= 7) {
            orderData7 = bean.data![6];
          }
          if ((bean.data!.length) >= 8) {
            orderData8 = bean.data![7];
          }
          if ((bean.data!.length) >= 9) {
            orderData9 = bean.data![8];
          }
          if ((bean.data!.length) >= 10) {
            orderData10 = bean.data![9];
          }
          isPageLoading = false;
        });
        return bean;
      } else {
        setState(() {
          Navigator.pushReplacementNamed(context, '/home');
        });
      }

      return null;
    } on HttpException catch (exception) {
      print(exception);
    } on FormatException catch (e) {
    } catch (exception) {
      print(exception);
    }
  }

  // Future<GetOrderDetails?> getOrderDetails(BuildContext context) async {
  //   progressDialog!.show();
  //   try {
  //     var user = await Utils.getUser();
  //     FormData from = FormData.fromMap({
  //       "userid": user.data!.userId,
  //       "token": "123456789",
  //       "orderid": widget.orderID.toString()
  //     });
  //     GetOrderDetails bean = await ApiProvider().getOrderDetails(from);
  //     progressDialog!.dismiss();
  //     if (bean.status == true) {
  //       setState(() {
  //         if (bean.data != null) {
  //           pickupBy = bean.data![0].pickby ?? '';
  //           kitchenName = bean.data![0].kitchenname ?? "";
  //           location = bean.data![0].kitchenAddress ?? '';
  //           name = bean.data![0].customername ?? '';
  //           deliveryAddress = bean.data![0].deliveryaddress ?? '';
  //           orderNumber = bean.data![0].orderNumber ?? '';
  //           kitchenContact = bean.data![0].kitchencontactnumber ?? '';
  //           if (bean.data![0].itemDetails != null) {
  //             itemDetails = bean.data![0].itemDetails ?? '';
  //           }

  //           status = bean.data![0].status ?? '';
  //         }
  //       });
  //       return bean;
  //     } else {
  //       Utils.showToast(bean.message ?? "");
  //     }

  //     return null;
  //   } on HttpException catch (exception) {
  //     progressDialog!.dismiss();
  //     print(exception);
  //   } catch (exception) {
  //     progressDialog!.dismiss();
  //     print(exception);
  //   }
  // }
}
