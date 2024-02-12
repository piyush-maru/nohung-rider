import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanCheckApiModel.dart';
import 'package:rider_app/model/BeanSignUp.dart' as userSi;
import 'package:rider_app/model/BeanStartDelivery.dart';
import 'package:rider_app/model/BeanrejectOrder.dart';
import 'package:rider_app/model/GetOrderDetails.dart';
import 'package:rider_app/model/getCureentOrders.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/res.dart';
import 'package:rider_app/screen/LocationScreen.dart';
import 'package:rider_app/screen/OrderScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedOrderScreen extends StatefulWidget {
  final AcceptedData? orderData;
  int? tabIndex;
  int? currentOrdersCount;
  AcceptedOrderScreen(this.orderData, this.tabIndex, this.currentOrdersCount);

  @override
  _AcceptedOrderScreenState createState() => _AcceptedOrderScreenState();
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

class _AcceptedOrderScreenState extends State<AcceptedOrderScreen>
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
    currentOrdersCount = widget.currentOrdersCount;
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

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    progressDialog = ProgressDialog(context);
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _pullRefresh,
      child: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: orderDetails != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        padding: EdgeInsets.only(left: 15, right: 16, top: 10),
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, top: 16),
                            child: Text(
                              "Pick By",
                              style: TextStyle(
                                  color: AppConstant.appColor, fontSize: 14),
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
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 16, top: 10),
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
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
                                  " ${(checkStatus == 'on_the_way_to_collect_food' ? 'On the Way to Collect Food' : (checkStatus == 'arrived_at_kitchen' ? 'Arrived At Kitchen' : (checkStatus == 'order_getting_ready' ? "Order Getting Ready" : (checkStatus == 'collected_and_delivery_in_progress' ? 'Collected and Delivery in Progress' : 'Unknown'))))}  ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: AppConstant.fontBold,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showMoreDialog(context, widget.orderData);
                            },
                            child: Icon(
                              Icons.more_horiz,
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 16, top: 10),
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5, top: 16),
                            child: Text(
                              "Order Status",
                              style: TextStyle(
                                  color: AppConstant.appColor, fontSize: 14),
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
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: Image.asset(
                                Res.ic_chef,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          )
                        ],
                      ),
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
                                      width: MediaQuery.of(context).size.width /
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
                          Column(
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
                                                  widget.orderData!.orderId,
                                                  widget
                                                      .orderData!.orderitemsId,
                                                  "Kitchen",
                                                  true,
                                                  orderDetails!.data![0]
                                                      .customermobilenumber,
                                                  orderDetails!.data![0]
                                                      .kitchencontactnumber,
                                                  checkStatus,
                                                  orderDetails!
                                                      .data![0].ordernumber)));
                                  setState(() {
                                    checkStatus = changedData['checkstatus'];
                                  });
                                  // LocationScreen
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 5,
                                    bottom: 5,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 35,
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
                                    child: Row(
                                      children: [
                                        Text(
                                          " View Kitchen ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: AppConstant.fontBold,
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
                                  _makePhoneCall(orderDetails!
                                          .data![0].kitchencontactnumber ??
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
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 16, top: 10),
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, top: 16),
                                    child: Text(
                                      "Delivery Time",
                                      style: TextStyle(
                                          color: AppConstant.appColor,
                                          fontFamily: AppConstant.fontBold,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, top: 5),
                                    child: Text(
                                      "${orderDetails!.data![0].deliveryDate}",
                                      style: TextStyle(
                                          fontFamily: AppConstant.fontBold,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 5, top: 5),
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
                                                  widget.orderData!.orderId,
                                                  widget
                                                      .orderData!.orderitemsId,
                                                  "Delivery",
                                                  true,
                                                  orderDetails!.data![0]
                                                      .customermobilenumber,
                                                  orderDetails!.data![0]
                                                      .kitchencontactnumber,
                                                  checkStatus,
                                                  orderDetails!
                                                      .data![0].ordernumber)));
                                  setState(() {
                                    checkStatus = changedData['checkstatus'];
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 5,
                                    bottom: 5,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 35,
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
                                    child: Row(
                                      children: [
                                        Text(
                                          " View Delivery ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: AppConstant.fontBold,
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
                              orderDetails!.data![0].customername.toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: AppConstant.fontBold),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5, top: 16),
                                child: Image.asset(
                                  Res.ic_location,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.3,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5, top: 16),
                                  child: Text(
                                    "${orderDetails!.data![0].deliveryaddress}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: AppConstant.fontRegular),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5, top: 16),
                        child: Text(
                          "Item Details",
                          style: TextStyle(
                              color: Color(0xffA7A8BC),
                              fontSize: 14,
                              fontFamily: AppConstant.fontBold),
                        ),
                      ),
                      Row(
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
                              padding: EdgeInsets.only(left: 10, top: 16),
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
                      ),
                      Center(
                        child: InkWell(
                          onTap: () async {
                            (checkStatus ==
                                        "collected_and_delivery_in_progress" &&
                                    orderDetails!.data![0].status ==
                                        "Assign to Rider")
                                ? showAlertDialog(context)
                                : Fluttertoast.showToast(
                                    msg:
                                        "Please Collect the Order and Update the Status! ");
                          },
                          child: Opacity(
                            opacity: (checkStatus ==
                                        "collected_and_delivery_in_progress" &&
                                    orderDetails!.data![0].status ==
                                        "Assign to Rider")
                                ? 1.0
                                : 0.5,
                            child: Container(
                                margin: EdgeInsets.only(
                                    left: 16, top: 36, bottom: 16, right: 16),
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(13)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 50),
                                        child: Text(
                                          "Start Delivery",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  AppConstant.fontRegular,
                                              fontSize: 14),
                                        )),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 36),
                                      child: Image.asset(
                                        Res.ic_right_arrow,
                                        width: 20,
                                        height: 20,
                                        color: Color(0xffD0F753),
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                        height: 20,
                      )
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )),
        physics: AlwaysScrollableScrollPhysics(),
      ),
    );
  }

  Future<void> showMoreDialog(BuildContext context, AcceptedData? orderData) {
    double _w = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.15), blurRadius: 30),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                // margin: EdgeInsets.fromLTRB(_w / 80, _w / 80, _w / 80, 0),
                padding: EdgeInsets.all(_w / 50),
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _character =
                                  riderMoreReasons.on_the_way_to_collect_food;
                            });
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: const Text(
                                "On The Way To Collect Food",
                                style: TextStyle(fontSize: 14),
                              )),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 5,
                          child: Radio<riderMoreReasons>(
                            activeColor: Colors.green[400],
                            value: riderMoreReasons.on_the_way_to_collect_food,
                            groupValue: _character,
                            onChanged: (riderMoreReasons? value) {
                              setState(() {
                                _character = value!;
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
                              _character = riderMoreReasons.arrived_at_kitchen;
                            });
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: const Text("Arrived Kitchen")),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 5,
                          child: Radio<riderMoreReasons>(
                            activeColor: Colors.green[400],
                            value: riderMoreReasons.arrived_at_kitchen,
                            groupValue: _character,
                            onChanged: (riderMoreReasons? value) {
                              setState(() {
                                _character = value!;
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
                              _character = riderMoreReasons.order_getting_ready;
                            });
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: const Text("Order Getting Ready")),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 5,
                          child: Radio<riderMoreReasons>(
                            activeColor: Colors.green[400],
                            value: riderMoreReasons.order_getting_ready,
                            groupValue: _character,
                            onChanged: (riderMoreReasons? value) {
                              setState(() {
                                _character = value!;
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
                              _character = riderMoreReasons
                                  .collected_and_delivery_in_progress;
                            });
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: const Text(
                                  "Collected And Delivery In Progress")),
                        ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 5,
                          child: Radio<riderMoreReasons>(
                            activeColor: Colors.green[400],
                            value: riderMoreReasons
                                .collected_and_delivery_in_progress,
                            groupValue: _character,
                            onChanged: (riderMoreReasons? value) {
                              setState(() {
                                _character = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => {
                        Navigator.pop(context, 'Cancel'),
                        showCancelDialog(context, orderData)
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
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   width: 2,
                    // ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, 'Cancel'),
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 5, right: 5, bottom: 5, top: 5),
                        padding: EdgeInsets.symmetric(horizontal: 20),
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
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   width: 2,
                    // ),
                    GestureDetector(
                      onTap: () => {checkRiderStatusUpdate()},
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
                              "Continue",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: AppConstant.fontBold,
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }

  Future<void> showCancelDialog(BuildContext context, AcceptedData? result) {
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
                            result!.orderId ?? '', result.orderitemsId ?? '')
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

  Future<void> showAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Order Alert'),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      child: Text(
                          "Are you sure you want to Start the Delivering."),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Confirm'),
                  onPressed: () {
                    getStartDelivery(context, widget.orderData!.orderId ?? '0',
                        widget.orderData!.orderitemsId ?? '0');
                  },
                ),
              ],
            ));
  }

  Future<GetOrderDetails?> getOrderDetails(BuildContext context) async {
    try {
      FormData from2 = FormData.fromMap(
          {"userid": user!.data!.userId, "token": "123456789"});
      GetCurrentOrdersModel bean1 = await ApiProvider().getCurrentOrders(from2);
      if (bean1.status == true && bean1.data!.length > (widget.tabIndex! + 1)) {
        List<String>? reassignedOrders = await getReassignedOrders();
        if (reassignedOrders != null &&
            bean1.data!
                    .where((element) => int.parse(element.reAssigned!) == 1)
                    .length >
                0) {
          if (!(reassignedOrders.contains(bean1.data!
              .where((element) => int.parse(element.reAssigned!) == 1)
              .last
              .orderitemsId))) {
            if (bean1.data!.length > currentOrdersCount!) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderScreen(widget.tabIndex)));

              saveReassignedOrders(bean1.data!
                  .where((element) => int.parse(element.reAssigned!) == 1)
                  .last
                  .orderitemsId!);
              PerfectVolumeControl.setVolume(1);
              AudioPlayer().play(AssetSource('notification_sound_old.mp3'));
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => OrderScreen((0))));
              Fluttertoast.showToast(msg: "New Order Re-Assigned by Admin");
            }
          }
        }
        if (reassignedOrders == null) {
          saveReassignedOrders('0');
        }
        FormData from;
        // var user = await Utils.getUser();
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
            "orderid": widget.orderData!.orderId.toString(),
            'orderitems_id': widget.orderData!.orderitemsId,
            "rider_longitude": _currentPosition.longitude.toString(),
            "rider_latitude": _currentPosition.latitude.toString(),
          });
        } else {
          from = FormData.fromMap({
            "userid": user!.data!.userId,
            "token": "123456789",
            "orderid": widget.orderData!.orderId.toString(),
            'orderitems_id': widget.orderData!.orderitemsId,
            "rider_longitude": deliveryLong,
            "rider_latitude": deliveryLat,
          });
        }

        GetOrderDetails bean = await ApiProvider().getOrderDetails(from);
        if (bean.status == true) {
          setState(() {
            if (bean.data != null) {
              orderDetails = bean;
              if (bean.data![0].status == "Start Delivery") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderScreen(widget.tabIndex)));
              }

              if (checkStatus != bean.data![0].riderStatus) {
                checkStatus = bean.data![0].riderStatus ?? 'Unknown';
              }
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
      } else {
        FormData from;
        // var user = await Utils.getUser();
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
            "orderid": widget.orderData!.orderId.toString(),
            'orderitems_id': widget.orderData!.orderitemsId,
            "rider_longitude": _currentPosition.longitude.toString(),
            "rider_latitude": _currentPosition.latitude.toString(),
          });
        } else {
          from = FormData.fromMap({
            "userid": user!.data!.userId,
            "token": "123456789",
            "orderid": widget.orderData!.orderId.toString(),
            'orderitems_id': widget.orderData!.orderitemsId,
            "rider_longitude": deliveryLong,
            "rider_latitude": deliveryLat,
          });
        }
        GetOrderDetails bean = await ApiProvider().getOrderDetails(from);
        if (bean.status == true) {
          setState(() {
            if (bean.data != null) {
              orderDetails = bean;
              if (bean.data![0].status == "Start Delivery") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderScreen(widget.tabIndex)));
              }

              if (checkStatus != bean.data![0].riderStatus) {
                checkStatus = bean.data![0].riderStatus ?? 'Unknown';
              }
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
      }
    } on HttpException catch (exception) {
      // progressDialog!.dismiss();
      print(exception);
    } catch (exception) {
      // progressDialog!.dismiss();
      print(exception);
    }
  }

  Future<BeanStartDelivery?> getStartDelivery(
      BuildContext context, String orderid, String orderitemsId) async {
    progressDialog!.show();
    try {
      await _locationTracker.getLocation().then((value) async {
        // var user = await Utils.getUser();
        FormData from = FormData.fromMap({
          "token": "123456789",
          "userid": user!.data!.userId,
          "orderid": orderid,
          'orderitems_id': orderitemsId,
          'rider_latitude': value.latitude.toString(),
          'rider_longitude': value.longitude.toString(),
        });
        BeanStartDelivery bean = await ApiProvider().starDelivery(from);

        if (bean.status == true) {
          progressDialog!.dismiss();
          setState(() {
            timer!.cancel();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderScreen(widget.tabIndex)));
          });
          return bean;
        } else {
          progressDialog!.dismiss();
          Utils.showToast(bean.message ?? "");
        }
      });
      return null;
    } on HttpException catch (exception) {
      progressDialog!.dismiss();
      print(exception);
    } catch (exception) {
      progressDialog!.dismiss();
      print(exception);
    }
  }

  void checkRiderStatusUpdate() {
    if ((orderDetails!.data![0].status != "Ready to Pick" &&
        _character!.name == "collected_and_delivery_in_progress")) {
      if (orderDetails!.data![0].status == "Assign to Rider" &&
          _character!.name == "collected_and_delivery_in_progress") {
        riderStatusUpdate();
      } else {
        Fluttertoast.showToast(msg: "Kitchen Preparing the Order");
      }
    } else {
      riderStatusUpdate();
    }
  }

  Future riderStatusUpdate() async {
    progressDialog!.show();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": widget.orderData!.orderId,
        "orderitems_id": widget.orderData!.orderitemsId,
        'rider_status': _character!.name,
      });
      BeanCheckApiModel bean = await ApiProvider().riderStatusUpdate(from);
      if (bean.status == true) {
        var msg = (_character!.name == 'on_the_way_to_collect_food'
            ? 'On the Way to Collect Food'
            : (_character!.name == 'arrived_at_kitchen'
                ? 'Arrived At Kitchen'
                : (_character!.name == 'order_getting_ready'
                    ? "Order Getting Ready"
                    : (_character!.name == 'collected_and_delivery_in_progress'
                        ? 'Collected and Delivery in Progress'
                        : ''))));
        Utils.showToast("Status Updated to $msg");
        if (_character!.name == "collected_and_delivery_in_progress") {
          getOrderDetails(context);
        }
        Navigator.pop(context, 'Cancel');
        progressDialog!.dismiss();

        setState(() {
          checkStatus = _character!.name;
        });

        return bean;
      } else {
        Utils.showToast(bean.message ?? "");
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
      //_cancelOp
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": orderid,
        'reset_rider': true,
        'orderitems_id': orderitems_id,
        'reason': (_cancelOp!.name == "location_so_far"
            ? "Location So Far,"
            : (_cancelOp!.name == "vehicle_ssue"
                ? "Vehicle Issue"
                : (_cancelOp!.name == "previous_order_pending"
                    ? "Previous Order Pending"
                    : "Other"))),
        // (vehicleIssue == true ? "Vehicle Issue," : '')
        // (previousOrderPending == true ? "Previous Order Pending," : "") +
        // (other == true ? "Other" : "")),
        'description': description_controller.text
      });
      BeanRejectOrder bean = await ApiProvider().rejectOrder(from);

      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        Navigator.pop(context, 'Cancel');
        progressDialog!.dismiss();
        setState(() {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderScreen(widget.tabIndex)));
        });
        return bean;
      } else {
        Utils.showToast(bean.message ?? "");
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
}
