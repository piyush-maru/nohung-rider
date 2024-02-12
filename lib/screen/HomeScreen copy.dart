import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rider_app/model/BeanAcceptOrder.dart';
import 'package:rider_app/model/BeanGetOrder.dart';
import 'package:rider_app/model/BeanrejectOrder.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/screen/LocationScreen.dart';
import 'package:rider_app/screen/MyDrawer.dart';
import 'package:rider_app/screen/OrderScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';

import '../res.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum orderCancelReasons {
  location_so_far,
  vehicle_issue,
  previous_order_pending
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = new Set(); //markers for google map
  static const LatLng showLocation =
      const LatLng(26.9124, 75.7873); //location to show in map

  Future<BeanGetOrder?>? _future;
  String numberOfOrders = '';

  LocationData? currentLocation;

  var expectedEarning = "";
  var tripDistance = "";
  var deliveryLat = "";
  var deliveryLong = "";
  orderCancelReasons _site = orderCancelReasons.location_so_far;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  ProgressDialog? progressDialog;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _future = getOrders(context);
    });
    super.initState();
  }

  Future<void> _pullRefresh() async {
    setState(() async {
      await Future.delayed(Duration.zero, () {
        _future = getOrders(context);
      });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);

    return Scaffold(
        drawer: MyDrawers(),
        key: _scaffoldKey,
        backgroundColor: Color(0xff7ED39C),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: new RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _pullRefresh,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff7ED39C), Color(0xff089E90)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 1],
                        ),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              "Hello!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppConstant.fontRegular,
                                  fontSize: 16),
                            ),
                          ),
                          Center(
                            child: Padding(
                              child: Text(
                                "You have $numberOfOrders new order",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: AppConstant.fontBold),
                              ),
                              padding: EdgeInsets.only(left: 16, top: 20),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          /*CircularPercentIndicator(
                          radius: 200.0,
                          animation: true,
                          animationDuration: 1200,
                          lineWidth: 2.0,
                          percent: 0.8,
                          center:*/
                          Container(
                              width: MediaQuery.of(context).size.height * 0.3,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6)),
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: GoogleMap(
                                    markers: getMarkers(),
                                    zoomControlsEnabled: false,
                                    onMapCreated: _onMapCreated,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(26.9124, 75.7873),
                                      zoom: 11.0,
                                    ),
                                    mapType: MapType.normal,
                                  ))),
                          //   circularStrokeCap: CircularStrokeCap.butt,
                          //   backgroundColor: Color(0xff21AB66),
                          //   progressColor: Color(0xffD0F753),
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    child: Text(
                                      AppConstant.rupee + expectedEarning,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                    padding: EdgeInsets.only(top: 5, left: 6),
                                  ),
                                  Padding(
                                    child: Text(
                                      "Expected Earning",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: AppConstant.fontRegular),
                                    ),
                                    padding: EdgeInsets.only(top: 6),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  color: Colors.white,
                                  width: 1,
                                  height: 30,
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    child: Text(
                                      tripDistance + "km",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                    padding: EdgeInsets.only(left: 20, top: 5),
                                  ),
                                  Padding(
                                    child: Text(
                                      "Trip Distance",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: AppConstant.fontRegular),
                                    ),
                                    padding: EdgeInsets.only(left: 20, top: 1),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    OrdersScreen(),
                  ]),
            ),
          ),
        ));
  }

  Set<Marker> getMarkers() {
    //markers to place on map
    setState(() {
      markers.add(Marker(
        //add first marker
        markerId: MarkerId(showLocation.toString()),
        position: LatLng(26.9124, 75.7873), //position of marker
        // position: LatLng(currentLocation!.longitude??26.9124, currentLocation!.latitude?? 75.7873), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title First ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker(
        //add second marker
        markerId: MarkerId(showLocation.toString()),
        position: LatLng(26.9124, 75.7873), //position of marker
        // position: LatLng(currentLocation!.longitude??26.9124, currentLocation!.latitude?? 75.7873), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title Second ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker(
        //add third marker
        markerId: MarkerId(showLocation.toString()),
        position: LatLng(26.9124, 75.7873), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title Third ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      //add more markers here
    });

    return markers;
  }

  Future<BeanGetOrder?> getOrders(BuildContext context) async {
    try {
      var user = await Utils.getUser();
      FormData from =
          FormData.fromMap({"userid": user.data!.userId, "token": "123456789"});
      BeanGetOrder bean = await ApiProvider().getOrder(from);

      if (bean.status == true) {
        setState(() {
          // Utils.showToast(bean.message ?? "");
          expectedEarning = bean.global!.expectedEarnings.toString();
          tripDistance = bean.global!.tripDistance.toString();
          numberOfOrders = bean.data!.length.toString();
          deliveryLat = bean.data![0].deliveryLat ?? "";
          deliveryLong = bean.data![0].deliveryLong ?? "";
        });

        return bean;
      }

      return null;
    } on HttpException catch (exception) {
      print(exception);
    } catch (exception) {
      print(exception);
    }
  }
}

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Data? result;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog? progressDialog;

  bool locationSoFar = false;
  bool vehicleIssue = false;
  bool previousOrderPending = false;
  String numberOfOrders = '';

  var expectedEarning = "";
  var tripDistance = "";
  var deliveryLat = "";
  var deliveryLong = "";

  Future<BeanGetOrder?>? _future;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      _future = getOrders(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BeanGetOrder?>(
      future: _future,
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.done) {
          var result;
          if (projectSnap.data != null) {
            result = projectSnap.data!.data;
            if (result != null) {
              numberOfOrders = result.length.toString();

              return (result.length == 0)
                  ? Container(
                      child: Center(
                      child: Text(
                        "No Order Available",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: AppConstant.fontBold),
                      ),
                    ))
                  : ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: AppConstant.lightGreen)),
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
                                      acceptOrder(result!.orderId ?? "",
                                          result!.orderItemsId ?? "");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => OrderScreen(0)),
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, top: 10, right: 16),
                                      child: Image.asset(
                                        Res.ic_check,
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => {
                                      showCancelDialog(context),
                                      // rejectOrder(result.orderId ?? '', result.orderItemsId ?? '');
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 1, top: 10, right: 16),
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
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 75, bottom: 6),
                                      child: Image.asset(
                                        Res.ic_time,
                                        width: 15,
                                        height: 15,
                                      )),
                                  Padding(
                                    child: Text(
                                      result!.pickTime.toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                    padding:
                                        EdgeInsets.only(left: 5, bottom: 6),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey,
                              ),
                              SizedBox(
                                height: 5,
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
                                    padding: EdgeInsets.only(left: 16),
                                  ),
                                  Padding(
                                    child: Text(
                                      "${result!.orderNumber}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                    padding: EdgeInsets.only(left: 16),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => LocationScreen(
                                                  result!.deliveryAddress,
                                                  result!.orderId,
                                                  result!.orderItemsId,
                                                  "Kitchen",
                                                  false,
                                                  null,
                                                  null,
                                                  null,
                                                  result.orderNumber)));
                                      // LocationScreen
                                    },
                                    child: Container(
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
                                            " View Kitchen",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    AppConstant.fontBold,
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // withdrawPayment();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => LocationScreen(
                                                  result!.deliveryAddress,
                                                  result!.orderId,
                                                  result!.orderItemsId,
                                                  "Delivery",
                                                  false,
                                                  null,
                                                  null,
                                                  null,
                                                  result.orderNumber)));
                                    },
                                    child: Container(
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
                                            " View Delivery",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    AppConstant.fontBold,
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 16, bottom: 10),
                                    child: Image.asset(
                                      Res.ic_location,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.3,
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Padding(
                                      child: Text(
                                        result!.deliveryAddress.toString(),
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
                        );
                      },
                      itemCount: result.length,
                    );
            }
          }
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.brown,
            ),
          ),
        );
      },
    );
  }

  Future<BeanGetOrder?>? getOrders(BuildContext context) async {
    try {
      var user = await Utils.getUser();
      FormData from =
          FormData.fromMap({"userid": user.data!.userId, "token": "123456789"});
      BeanGetOrder bean = await ApiProvider().getOrder(from);

      if (bean.status == true) {
        setState(() {
          // Utils.showToast(bean.message ?? "");
          expectedEarning = bean.global!.expectedEarnings.toString();
          tripDistance = bean.global!.tripDistance.toString();
          numberOfOrders = bean.data!.length.toString();
          deliveryLat = bean.data![0].deliveryLat ?? "";
          deliveryLong = bean.data![0].deliveryLong ?? "";
        });

        return bean;
      }

      return null;
    } on HttpException catch (exception) {
      print(exception);
    } catch (exception) {
      print(exception);
    }
  }

  Future<BeanRejectOrder?> rejectOrder(
      String orderid, String orderitems_id) async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user.data!.userId,
        "token": "123456789",
        "orderid": orderid,
        'orderitems_id': orderitems_id
      });
      BeanRejectOrder bean = await ApiProvider().rejectOrder(from);

      progressDialog!.dismiss();
      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        setState(() {
          _future = getOrders(context);
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

  Future<BeanAcceptOrder?> acceptOrder(
      String orderid, String orderitems_id) async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user.data!.userId,
        "token": "123456789",
        "orderid": orderid,
        "orderitems_id": orderitems_id
      });
      BeanAcceptOrder bean = await ApiProvider().acceptOrder(from);
      progressDialog!.dismiss();
      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderScreen(0)),
        ).then((value) {
          setState(() {
            _future = getOrders(context);
          });
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

  Future<void> showCancelDialog(BuildContext context) {
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
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text("Location So Far",
                            style: TextStyle(
                              fontFamily: AppConstant.fontRegular,
                            )),
                        value: locationSoFar,
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        onChanged: (bool? value) {
                          setState(() {
                            locationSoFar = !locationSoFar;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text("Vehicle Issue",
                            style: TextStyle(
                              fontFamily: AppConstant.fontRegular,
                            )),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: vehicleIssue,
                        onChanged: (bool? value) {
                          setState(() {
                            vehicleIssue = !vehicleIssue;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: CheckboxListTile(
                        title: Text(
                          "Previous Order Pending",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: previousOrderPending,
                        onChanged: (bool? value) {
                          setState(() {
                            previousOrderPending = !previousOrderPending;
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
