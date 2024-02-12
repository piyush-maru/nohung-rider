import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:rider_app/model/BeanStartDelivery.dart';
import 'package:rider_app/model/GetOrderDetails.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/res.dart';
import 'package:rider_app/screen/MyDrawer.dart';
import 'package:rider_app/screen/StartDeliveryScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderScreen extends StatefulWidget {
  var orderID;
  var orderItemsId;

  OrderScreen(this.orderID, this.orderItemsId);

  @override
  OrderScreenState createState() => OrderScreenState();
}

enum riderMoreReasons {
  on_the_way_to_collect_food,
  arrived_at_kitchen,
  order_getting_ready,
  collected_and_delivey_in_progress
}

class OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  var isSelected = 1;
  var pickupBy = "";
  var kitchenName = "";
  var location = "";
  var name = "";
  var deliveryAddress = "";
  var itemDetails = "";
  var kitchenContact = "";
  var orderNumber = '';
  Location _locationTracker = new Location();
  var status = "";
  bool _hasCallSupport = false;

  bool onTheWayToCollectFood = false;
  bool arrivedAtKitchen = false;
  bool orderGettingReady = false;
  bool collectedAndDeliveyInProgress = false;
  // Dealy
  bool other = false;
  bool stuckInTraffic = false;
  bool roadClosedDivertNewRoute = false;
  bool newDeliveryAddressDivertedByCustomer = false;

// Issue Note
//heavyTrafficDeliveryTimeIssue
  bool heavyTrafficDeliveryTimeIssue = false;
  bool addressNotFound = false;
  bool customerBlamesHeDidntPlaceAnOrder = false;
  bool customerNotAcceptingTheOrder = false;
  // bool other = false;
  bool customerDoorClosed = false;

  TabController? _tabController;

  ProgressDialog? progressDialog;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late Future future;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      future = getOrderDetails(context);
    });

    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
    _tabController = TabController(length: 5, vsync: this);
    _tabController!.addListener(_handleTabSelection);

    super.initState();
  }

  void _handleTabSelection() {
    setState(() {});
  }

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
              margin: EdgeInsets.only(top: 150),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(38),
                      topLeft: Radius.circular(38))),
              height: double.infinity,
              child: method()),
          Padding(
            padding: EdgeInsets.only(left: 16, top: 72, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Orders",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: AppConstant.fontBold,
                      fontSize: 16),
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
        ],
      ),
    );
  }

  method() {
    return SingleChildScrollView(
      child: Row(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20))),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                  color: AppConstant.appColor,
                ),
                isScrollable: true,
                labelStyle:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                indicatorSize: TabBarIndicatorSize.label,
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Container(
                    decoration: BoxDecoration(
                        color: (_tabController!.index == 0)
                            ? Colors.transparent
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Tab(
                        text: 'Request',
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: (_tabController!.index == 1)
                            ? Colors.transparent
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Tab(
                        text: 'Active',
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: (_tabController!.index == 2)
                            ? Colors.transparent
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Tab(
                        text: 'Upcoming',
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: (_tabController!.index == 3)
                            ? Colors.transparent
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Tab(
                        text: 'Order History',
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: (_tabController!.index == 4)
                            ? Colors.transparent
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Tab(
                        text: 'Live Orders',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                orderScreen1(),
                orderScreen1(),
                orderScreen1(),
                orderScreen1(),
                orderScreen1(),

                // // first tab bar view widget
                // RequestScreen(),
                // ActiveScreen(),
                // UpcomingScreen(),
                // OrdersHistory(),
                // // TrialRequestScreen(),
                // LiveOrdersScreen(),
                // // second tab bar view widget
              ],
            ),
          ),
        ],
      ),
      physics: BouncingScrollPhysics(),
    );
  }

  Row orderScreen1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(left: 16),
          width: 140,
          height: 35,
          decoration: BoxDecoration(
              color: Color.fromARGB(153, 208, 255, 0),
              borderRadius: BorderRadius.circular(50)),
          child: Center(
            child: Text(
              "Order No :$orderNumber",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: AppConstant.fontRegular,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
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
                      margin:
                          EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
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
                            " On The Way To Collect Food  ",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: AppConstant.fontBold,
                                fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showMoreDialog(context);
                      },
                      child: Icon(Icons.more_horiz),
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
                        "Pickup By",
                        style: TextStyle(
                            color: AppConstant.appColor, fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        pickupBy,
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
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 16),
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
                          status,
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
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 16),
                      child: Image.asset(
                        Res.ic_circle_avatar,
                        width: 60,
                        height: 60,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 16),
                          child: Text(
                            kitchenName.toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: AppConstant.fontBold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Image.asset(
                                Res.ic_location,
                                width: 20,
                                height: 20,
                              ),
                            ),
                            Text(
                              location.toUpperCase(),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontFamily: AppConstant.fontBold),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _makePhoneCall(kitchenContact);
                  },
                  child: Row(children: [
                    Text(
                      "Call Kitchen",
                      style: TextStyle(fontFamily: AppConstant.fontRegular),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Image.asset(
                      Res.ic_call,
                      width: 30,
                      height: 30,
                    ),
                  ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 16, top: 10),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text(
                      "Delivery Address",
                      style: TextStyle(
                          color: AppConstant.appColor,
                          fontSize: 14,
                          fontFamily: AppConstant.fontBold),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text(
                    name.toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: AppConstant.fontBold),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 16),
                      child: Image.asset(
                        Res.ic_location,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Container(
                      width: 180,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          deliveryAddress,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: AppConstant.fontRegular),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
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
                      padding: EdgeInsets.only(left: 16, top: 16),
                      child: Image.asset(
                        Res.ic_dinner,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          itemDetails,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: AppConstant.fontBold),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: InkWell(
                    onTap: () async {
                      _locationTracker.getLocation().then((value) {
                        getStartDelivery(
                                context,
                                widget.orderID,
                                widget.orderItemsId,
                                value.latitude.toString(),
                                value.longitude.toString())
                            .then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StartDeliveryScreen(
                                    deliveryAddress,
                                    widget.orderID,
                                    widget.orderID,
                                    widget.orderItemsId,
                                    null,
                                    null,
                                    null,
                                    0,
                                    0)),
                          );
                        });
                      });
                    },
                    child: Container(
                        margin: EdgeInsets.only(
                            left: 16, top: 36, bottom: 16, right: 16),
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(13)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 50),
                                child: Text(
                                  "Start Delivery",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: AppConstant.fontRegular,
                                      fontSize: 14),
                                )),
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 36),
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
              ],
            )),
      ],
    );
  }

  Future<void> showMoreDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Cancel Ride',
                style: TextStyle(fontSize: 18),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text("On The Way To Collect Food",
                            style: TextStyle(
                              fontFamily: AppConstant.fontRegular,
                            )),
                        value: onTheWayToCollectFood,
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        onChanged: (bool? value) {
                          setState(() {
                            onTheWayToCollectFood = !onTheWayToCollectFood;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text("Arrived Kitchen",
                            style: TextStyle(
                              fontFamily: AppConstant.fontRegular,
                            )),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: arrivedAtKitchen,
                        onChanged: (bool? value) {
                          setState(() {
                            arrivedAtKitchen = !arrivedAtKitchen;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "Order Getting Ready",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: orderGettingReady,
                        onChanged: (bool? value) {
                          setState(() {
                            orderGettingReady = !orderGettingReady;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "Collected And Delivey In Progress",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: collectedAndDeliveyInProgress,
                        onChanged: (bool? value) {
                          setState(() {
                            collectedAndDeliveyInProgress =
                                !collectedAndDeliveyInProgress;
                          });
                        },
                      ),
                    ),
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

  Future<BeanStartDelivery?> getStartDelivery(
      BuildContext context,
      String orderid,
      String orderitemsId,
      String latitute,
      String longitude) async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "token": "123456789",
        "userid": user.data!.userId,
        "orderid": orderid,
        'orderitems_id': orderitemsId,
        'rider_latitude': latitute,
        'rider_longitude': longitude,
      });
      BeanStartDelivery bean = await ApiProvider().starDelivery(from);

      progressDialog!.dismiss();
      if (bean.status == true) {
        setState(() {
/*          kitchenlat=double.parse(bean.data[0].kitchenlatitude);
          kitchenlong=double.parse(bean.data[0].kitchenlongitude);
          deliverylatitude=double.parse(bean.data[0].deliverylatitude);
          deliverylongitude=double.parse(bean.data[0].deliverylongitude);*/
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

  Future<GetOrderDetails?> getOrderDetails(BuildContext context) async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user.data!.userId,
        "token": "123456789",
        "orderid": widget.orderID.toString(),
      });
      GetOrderDetails bean = await ApiProvider().getOrderDetails(from);
      progressDialog!.dismiss();
      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        setState(() {
          if (bean.data != null) {
            pickupBy = bean.data![0].pickby ?? '';
            kitchenName = bean.data![0].kitchenname ?? "";
            location = bean.data![0].kitchenAddress ?? '';
            name = bean.data![0].customername ?? '';
            deliveryAddress = bean.data![0].deliveryaddress ?? '';
            orderNumber = bean.data![0].ordernumber ?? '';
            kitchenContact = bean.data![0].kitchencontactnumber ?? '';
            // if (bean.data![0].itemDetails != null) {
            //   itemDetails = bean.data![0].itemDetails ?? '';
            // }

            status = bean.data![0].status ?? '';
          }
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

  Future<void> showDelayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Delay',
                style: TextStyle(fontSize: 18),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text("Stuck In Traffic",
                            style: TextStyle(
                              fontFamily: AppConstant.fontRegular,
                            )),
                        value: stuckInTraffic,
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        onChanged: (bool? value) {
                          setState(() {
                            stuckInTraffic = !stuckInTraffic;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text("Road Closed Divert New Route",
                            style: TextStyle(
                              fontFamily: AppConstant.fontRegular,
                            )),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: roadClosedDivertNewRoute,
                        onChanged: (bool? value) {
                          setState(() {
                            roadClosedDivertNewRoute =
                                !roadClosedDivertNewRoute;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "New Delivery Address Diverted By Customer",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: newDeliveryAddressDivertedByCustomer,
                        onChanged: (bool? value) {
                          setState(() {
                            newDeliveryAddressDivertedByCustomer =
                                !newDeliveryAddressDivertedByCustomer;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "Other",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: other,
                        onChanged: (bool? value) {
                          setState(() {
                            other = !other;
                          });
                        },
                      ),
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
                              "Continue",
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

  Future<void> showIssueDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Delay',
                style: TextStyle(fontSize: 18),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text("Heavy Traffic Delivery Time Issue",
                            style: TextStyle(
                              fontFamily: AppConstant.fontRegular,
                            )),
                        value: heavyTrafficDeliveryTimeIssue,
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        onChanged: (bool? value) {
                          setState(() {
                            heavyTrafficDeliveryTimeIssue =
                                !heavyTrafficDeliveryTimeIssue;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text("Address Not Found",
                            style: TextStyle(
                              fontFamily: AppConstant.fontRegular,
                            )),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: addressNotFound,
                        onChanged: (bool? value) {
                          setState(() {
                            addressNotFound = !addressNotFound;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "Customer Door Closed",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: customerDoorClosed,
                        onChanged: (bool? value) {
                          setState(() {
                            customerDoorClosed = !customerDoorClosed;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "Customer Not Accepting The Order",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: customerNotAcceptingTheOrder,
                        onChanged: (bool? value) {
                          setState(() {
                            customerNotAcceptingTheOrder =
                                !customerNotAcceptingTheOrder;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "Customer Blames He Didn't Place An Order",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: customerBlamesHeDidntPlaceAnOrder,
                        onChanged: (bool? value) {
                          setState(() {
                            customerBlamesHeDidntPlaceAnOrder =
                                !customerBlamesHeDidntPlaceAnOrder;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "Other",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: collectedAndDeliveyInProgress,
                        onChanged: (bool? value) {
                          setState(() {
                            collectedAndDeliveyInProgress =
                                !collectedAndDeliveyInProgress;
                          });
                        },
                      ),
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
                              "Continue",
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

  Future<void> showContactDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Kitchen",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                color: Color.fromARGB(255, 6, 168, 11),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Kitchen",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                fontWeight: FontWeight.bold),
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
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Foodie",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                color: Color.fromARGB(255, 6, 168, 11),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Kitchen",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                fontWeight: FontWeight.bold),
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
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Nohung",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                color: Color.fromARGB(255, 6, 168, 11),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Kitchen",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}
