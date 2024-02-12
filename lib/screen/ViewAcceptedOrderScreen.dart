import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanSignUp.dart' as userSi;
import 'package:rider_app/model/GetOrderDetails.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/res.dart';
import 'package:rider_app/screen/LocationScreen.dart';
import 'package:rider_app/screen/MyDrawer.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewAcceptedOrderScreen extends StatefulWidget {
  // final AcceptedData? orderData;

  String? orderId;
  int? isLiveOrder;
  String? orderItemId;
  ViewAcceptedOrderScreen(this.orderId, this.orderItemId, this.isLiveOrder
      // this.orderData,
      // this.tabIndex, this.currentOrdersCount
      );

  @override
  _ViewAcceptedOrderScreenState createState() =>
      _ViewAcceptedOrderScreenState();
}

enum riderMoreReasons {
  on_the_way_to_collect_food,
  arrived_at_kitchen,
  order_getting_ready,
  collected_and_delivery_in_progress
}

enum riderCancelReasons {
  location_so_far,
  vehicle_ssue,
  previous_order_pending,
  other
}

class _ViewAcceptedOrderScreenState extends State<ViewAcceptedOrderScreen>
    with WidgetsBindingObserver {
  ProgressDialog? progressDialog;

  GetOrderDetails? orderDetails;
  Location _locationTracker = new Location();
  riderMoreReasons? _character;
  riderCancelReasons? _cancelOp;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool locationSoFar = false;
  bool vehicleIssue = false;
  bool previousOrderPending = false;
  Timer? timer;
  bool other = false;
  var description_controller = TextEditingController();
  String checkStatus = 'Unknown';
  bool? riderStatus = true;
  Location location = new Location();
  String? _error;
  StreamSubscription? _locationSubscription;
  userSi.BeanSignUp? user;
  bool? isBackground = false;
  var deliveryLat = "";
  var deliveryLong = "";
  int? currentOrdersCount;

  @override
  void initState() {
    _getCurrentLocation();
    getUserData();
    Future.delayed(Duration.zero, () async {
      // if (int.parse(widget.orderData!.reAssigned!) == 1) {
      //   List<String>? reassignedOrders = await getReassignedOrders();
      //   if (reassignedOrders == null ||
      //       !reassignedOrders.contains(widget.orderData!.orderitemsId)) {
      //     saveReassignedOrders(widget.orderData!.orderitemsId!);
      //     await getOrderDetails(context);
      //   } else {
      //     await getOrderDetails(context);
      //   }
      // } else {
      await getOrderDetails(context);
      // }
    });
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState != null) {
      // _stateHistoryList.add(WidgetsBinding.instance.lifecycleState!);
    }
    const twentyMillis = Duration(seconds: 20);
    timer = Timer.periodic(twentyMillis, (timer) {
      if (riderStatus == true) {
        getOrderDetails(context);
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
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
      setState(() {
        getOrderDetails(context);
      });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    progressDialog = ProgressDialog(context);
    return Scaffold(
      drawer: MyDrawers(),
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _pullRefresh,
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 20),
              child: orderDetails != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.keyboard_backspace_rounded,
                                size: 34, color: Colors.black)),
                        SizedBox(
                          height: 15,
                        ),
                        orderDetails!.data![0].status ==
                                "Waiting for Kitchen Approval"
                            ? Container(
                                margin: EdgeInsets.only(
                                    left: 5, right: 5, bottom: 5, top: 5),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 211, 129, 126),
                                      Color.fromARGB(255, 211, 129, 126),
                                      Color.fromARGB(255, 211, 126, 126),
                                      Color.fromARGB(255, 158, 8, 8)
                                    ],
                                    begin: Alignment.bottomLeft,
                                    stops: [0, 0, 0, 1],
                                  ),
                                ),
                                child: Center(
                                  child: Center(
                                    child: Text(
                                      "Order Not Accepted By Kitchen",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: AppConstant.fontBold,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 16),
                              width: 140,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(212, 208, 255, 0),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Center(
                                child: Text(
                                  "Order No : ${orderDetails!.data![0].ordernumber}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: AppConstant.fontRegular,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 15, right: 16, top: 10),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        widget.isLiveOrder == 1
                            ? Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16),
                                    child: Text(
                                      "Pick By",
                                      style: TextStyle(
                                          color: AppConstant.appColor,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16),
                                    child: Text(
                                      "${orderDetails!.data![0].pickby}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16),
                                    child: Text(
                                      "Order Status",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5, top: 5),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
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
                                          "${orderDetails!.data![0].status} ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: AppConstant.fontBold,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 15, right: 16, top: 10),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        widget.isLiveOrder == 1
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 5, right: 5, bottom: 5, top: 5),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
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
                                          " ${(checkStatus == 'on_the_way_to_collect_food' ? 'On the Way to Collect Food' : (checkStatus == 'arrived_at_kitchen' ? 'Arrived At Kitchen' : (checkStatus == 'order_getting_ready' ? "Order Getting Ready" : (checkStatus == 'collected_and_delivery_in_progress' ? 'Collected and Delivery in Progress' : 'Unknown'))))}  ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: AppConstant.fontBold,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "Order date/time",
                                          style: TextStyle(
                                              color: AppConstant.appColor,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "${orderDetails!.data![0].orderdate}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: AppConstant.fontBold),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "Order Type",
                                          style: TextStyle(
                                              color: AppConstant.appColor,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "${orderDetails!.data![0].ordertype}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: AppConstant.fontBold),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 15, right: 16, top: 10),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        widget.isLiveOrder == 1
                            ? Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, top: 16),
                                    child: Text(
                                      "Order Status",
                                      style: TextStyle(
                                          color: AppConstant.appColor,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 16),
                                    width: 140,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Center(
                                      child: Text(
                                        "${orderDetails!.data![0].status}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: AppConstant.fontRegular,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      child: Image.asset(
                                        Res.ic_chef,
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 5, top: 16),
                              child: Image.asset(
                                Res.ic_circle_avatar,
                                width: 40,
                                height: 40,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 2.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16),
                                    child: Text(
                                      "${orderDetails!.data![0].kitchenname!.toUpperCase()}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 16),
                                        child: Image.asset(
                                          Res.ic_location,
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.8,
                                        child: Text(
                                          "${orderDetails!.data![0].kitchenAddress!.toUpperCase()}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 5,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontFamily: AppConstant.fontBold),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 12,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            widget.isLiveOrder == 1
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          Map<String, dynamic> changedData =
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => LocationScreen(
                                                          "${orderDetails!.data![0].kitchenAddress}",
                                                          widget.orderId,
                                                          widget.orderItemId,
                                                          "Kitchen",
                                                          true,
                                                          orderDetails!.data![0]
                                                              .customermobilenumber,
                                                          orderDetails!.data![0]
                                                              .kitchencontactnumber,
                                                          checkStatus,
                                                          orderDetails!.data![0]
                                                              .ordernumber)));
                                          setState(() {
                                            checkStatus =
                                                changedData['checkstatus'];
                                          });
                                          // LocationScreen
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 5,
                                            bottom: 5,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          height: 35,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
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
                                            child: Row(
                                              children: [
                                                Text(
                                                  " View Kitchen ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          AppConstant.fontBold,
                                                      fontSize: 11),
                                                ),
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => {
                                          _makePhoneCall(orderDetails!.data![0]
                                                  .kitchencontactnumber ??
                                              "")
                                        },
                                        child: Image.asset(
                                          Res.ic_call,
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container()
                          ],
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 15, right: 16, top: 10),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        widget.isLiveOrder == 1
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 5, top: 16),
                                            child: Text(
                                              "Delivery Time",
                                              style: TextStyle(
                                                  color: AppConstant.appColor,
                                                  fontFamily:
                                                      AppConstant.fontBold,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 5, top: 5),
                                            child: Text(
                                              "${orderDetails!.data![0].deliveryDate}",
                                              style: TextStyle(
                                                  fontFamily:
                                                      AppConstant.fontBold,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Text(
                                                  "${orderDetails!.data![0].deliverytime}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppConstant.fontBold),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          Map<String, dynamic> changedData =
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => LocationScreen(
                                                          "${orderDetails!.data![0].deliveryaddress}",
                                                          widget.orderId,
                                                          widget.orderItemId,
                                                          "Delivery",
                                                          true,
                                                          orderDetails!.data![0]
                                                              .customermobilenumber,
                                                          orderDetails!.data![0]
                                                              .kitchencontactnumber,
                                                          checkStatus,
                                                          orderDetails!.data![0]
                                                              .ordernumber)));
                                          setState(() {
                                            checkStatus =
                                                changedData['checkstatus'];
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 5,
                                            bottom: 5,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          height: 35,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
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
                                            child: Row(
                                              children: [
                                                Text(
                                                  " View Delivery ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          AppConstant.fontBold,
                                                      fontSize: 11),
                                                ),
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, top: 16),
                                    child: Text(
                                      "Delivery Address",
                                      style: TextStyle(
                                          color: AppConstant.appColor,
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, top: 5),
                                    child: Text(
                                      orderDetails!.data![0].customername
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 5, top: 16),
                                        child: Image.asset(
                                          Res.ic_location,
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.3,
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(left: 5, top: 16),
                                          child: Text(
                                            "${orderDetails!.data![0].deliveryaddress}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily:
                                                    AppConstant.fontRegular),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "Pick up Time",
                                          style: TextStyle(
                                              color: AppConstant.appColor,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "${orderDetails!.data![0].pickby}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: AppConstant.fontBold),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "Order Picked up at",
                                          style: TextStyle(
                                              color: AppConstant.appColor,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "${orderDetails!.data![0].orderPickedTime}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: AppConstant.fontBold),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 15, right: 16, top: 10),
                                    child: Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, top: 5),
                                    child: Text(
                                      orderDetails!.data![0].customername
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 5, top: 16),
                                        child: Image.asset(
                                          Res.ic_location,
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.3,
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(left: 5, top: 16),
                                          child: Text(
                                            "${orderDetails!.data![0].deliveryaddress}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily:
                                                    AppConstant.fontRegular),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "Delivery date",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "${orderDetails!.data![0].deliveryDate}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: AppConstant.fontBold),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "Delivery by",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "${orderDetails!.data![0].deliverytime}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: AppConstant.fontBold),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 15, right: 16, top: 10),
                                    child: Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "Order Delivered at",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 16),
                                        child: Text(
                                          "${orderDetails!.data![0].deliveredDate}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: AppConstant.fontBold),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                        widget.isLiveOrder == 1
                            ? Padding(
                                padding: EdgeInsets.only(left: 5, top: 16),
                                child: Text(
                                  "Item Details",
                                  style: TextStyle(
                                      color: Color(0xffA7A8BC),
                                      fontSize: 14,
                                      fontFamily: AppConstant.fontBold),
                                ),
                              )
                            : Container(),
                        widget.isLiveOrder == 1
                            ? Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, top: 16),
                                    child: Image.asset(
                                      Res.ic_dinner,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, top: 16),
                                      child:
                                          // Text(
                                          //   "${orderDetails!.data![0].itemDetails}",
                                          //   style: TextStyle(
                                          //       color: Colors.black,
                                          //       fontSize: 14,
                                          //       fontFamily: AppConstant.fontBold),
                                          // ),
                                          Column(
                                        children: [
                                          ListView.builder(
                                            itemCount: orderDetails!
                                                .data![0].itemDetails!.length,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            physics: BouncingScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                      "${orderDetails!.data![0].itemDetails![index].quantity} x ${orderDetails!.data![0].itemDetails![index].itemName}"),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          // Text("Special Instructions : ${data.orderItems}"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          width: 10,
                          height: 20,
                        )
                      ],
                    )
                  : Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    )),
          physics: AlwaysScrollableScrollPhysics(),
        ),
      ),
    );
  }

  Future<GetOrderDetails?> getOrderDetails(BuildContext context) async {
    try {
      FormData from;
      // var user = await Utils.getUser();
      // print("check1");
      if (isBackground == false) {
        // var user = await Utils.getUser();
        LocationData _currentPosition = await location.getLocation();
        setState(() {
          deliveryLong = _currentPosition.longitude.toString();
          deliveryLat = _currentPosition.latitude.toString();
        });
        from = FormData.fromMap({
          "userid": user!.data!.userId,
          "token": "123456789",
          "orderid": widget.orderId.toString(),
          'orderitems_id': widget.orderItemId.toString(),
          "rider_longitude": _currentPosition.longitude.toString(),
          "rider_latitude": _currentPosition.latitude.toString(),
        });
      } else {
        from = FormData.fromMap({
          "userid": user!.data!.userId,
          "token": "123456789",
          "orderid": widget.orderId.toString(),
          'orderitems_id': widget.orderItemId.toString(),
          "rider_longitude": deliveryLong,
          "rider_latitude": deliveryLat,
        });
      }
      // print("check12");
      GetOrderDetails bean = await ApiProvider().getOrderDetails(from);
      if (bean.status == true) {
        // print("check13");
        setState(() {
          if (bean.data!.isNotEmpty) {
            orderDetails = bean;
            if (checkStatus != bean.data![0].riderStatus) {
              checkStatus = bean.data![0].riderStatus ?? 'Unknown';
            }
            // print("check4");
            if (bean.data![0].riderStatus != null) {
              if (bean.data![0].riderStatus != _character) {
                _character = (bean.data![0].riderStatus ==
                        'on_the_way_to_collect_food'
                    ? riderMoreReasons.on_the_way_to_collect_food
                    : (bean.data![0].riderStatus == 'arrived_at_kitchen'
                        ? riderMoreReasons.arrived_at_kitchen
                        : (bean.data![0].riderStatus == 'order_getting_ready'
                            ? riderMoreReasons.order_getting_ready
                            : riderMoreReasons
                                .collected_and_delivery_in_progress)));
              }
            }
          }
        });
        // progressDialog!.dismiss();
        return bean;
      } else {
        Utils.showToast(bean.message ?? "");
      }

      return null;
    } on HttpException catch (exception) {
      // progressDialog!.dismiss();
      print(exception);
    } catch (exception) {
      // progressDialog!.dismiss();
      print(exception);
    }
  }
}
