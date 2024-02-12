import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanCheckApiModel.dart';
import 'package:rider_app/model/BeanSignUp.dart' as userSi;
import 'package:rider_app/model/BeanStartDelivery.dart' as beanStartDelivery;
import 'package:rider_app/model/GetOrderDetails.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/screen/OrderScreen.dart';
import 'package:rider_app/screen/TripSummaryScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';

import '../res.dart';

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class LocationScreen extends StatefulWidget {
  var deliveryAddress;
  final String? orderid;
  final String? orderitemsId;
  final String? locationOf;
  final bool orderAccepted;
  final String? customerNumber;
  final String? kitchenNumber;
  final String? riderStatus;
  final String? orderNumber;
  LocationScreen(
      this.deliveryAddress,
      this.orderid,
      this.orderitemsId,
      this.locationOf,
      this.orderAccepted,
      this.customerNumber,
      this.kitchenNumber,
      this.riderStatus,
      this.orderNumber);

  @override
  LocationScreenState createState() => LocationScreenState();
}

enum riderMoreReasons {
  on_the_way_to_collect_food,
  arrived_at_kitchen,
  order_getting_ready,
  collected_and_delivery_in_progress
}

class LocationScreenState extends State<LocationScreen> {
  CameraPosition? _cameraPosition;
  double cameraZOOM = 14;
  double cameraTILT = 0;
  double cameraBEARING = 30;
  String? _error;
  LatLng SOURCE_LOCATION = LatLng(0.0, 0.0);
  LatLng DEST_LOCATION = LatLng(0.0, 0.0);
  String? name;

  Data? data;

/*  LatLng DEST_LOCATION = LatLng(42.6871386, -71.2143403);*/

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  Set<Polyline> _polylines = {};
  Set<Polyline> _polylines2 = {};
  List<LatLng> polylineCoordinates = [];
  List<LatLng> polylineCoordinates2 = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyCBZ1E4AGu6xP_VV4GWr_qjnOte9sFmh0A";
  Location location = new Location();

  // bool onTheWayToCollectFood = false;
  // bool arrivedAtKitchen = false;
  // bool orderGettingReady = false;
  // bool collectedAndDeliveyInProgress = false;

  bool acceptedOrder = false;
  bool orderStatus = false;

  var kitchenlat = 0.0;
  var kitchenlong = 0.0;
  var deliverylatitude = 0.0;
  var deliverylongitude = 0.0;
  // for my custom icons
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

  LatLng? sourceLatLng;
  LatLng? destLatLng;
  GoogleMapController? _mapController;
  riderMoreReasons? _character;

  String checkStatus = 'Unknown';

  ProgressDialog? progressDialog;
  Location _locationTracker = new Location();
  StreamSubscription? _locationSubscription;
  Future? future;
  String? userId;
  LocationData? currentLocation;
  final Set<Marker> _markers1 = {};
  Map<PolylineId, Polyline> _polylinesList1 = <PolylineId, Polyline>{};
  bool loadingMap = false;
  userSi.BeanSignUp? user;
  bool? riderStatus = true;

  // bool locationSoFar = false;
  // bool vehicleIssue = false;
  // bool previousOrderPending = false;
  // bool other = false;
  // var description_controller = TextEditingController();

  @override
  void initState() {
    getUserData();
    _locationTracker = new Location();
    super.initState();
    if (widget.riderStatus ==
        riderMoreReasons.on_the_way_to_collect_food.name) {
      checkStatus = riderMoreReasons.on_the_way_to_collect_food.name;
      _character = riderMoreReasons.on_the_way_to_collect_food;
    } else if (widget.riderStatus == riderMoreReasons.arrived_at_kitchen.name) {
      checkStatus = riderMoreReasons.arrived_at_kitchen.name;
      _character = riderMoreReasons.arrived_at_kitchen;
    } else if (widget.riderStatus ==
        riderMoreReasons.order_getting_ready.name) {
      checkStatus = riderMoreReasons.order_getting_ready.name;
      _character = riderMoreReasons.order_getting_ready;
    } else if (widget.riderStatus ==
        riderMoreReasons.collected_and_delivery_in_progress.name) {
      checkStatus = riderMoreReasons.collected_and_delivery_in_progress.name;
      _character = riderMoreReasons.collected_and_delivery_in_progress;
    } else {
      checkStatus = 'Unknown';
    }
    Future.delayed(Duration.zero, () {
      _listenLocation();
      setSourceAndDestinationIcons();
    });
    //Future.delayed(Duration.zero, () {});
  }

  onMapCreated(GoogleMapController _cntlr) {
    _mapController = _cntlr;
    if (sourceLatLng != null && destLatLng != null) {
      var list = [sourceLatLng, destLatLng];
      CameraUpdate u2 =
          CameraUpdate.newLatLngBounds(boundsFromLatLngList(list), 50);
      _mapController?.animateCamera(u2).then((void v) {
        check(u2, _mapController!);
      });
    }

    setMapPins();
    setPolylines();
  }

/*  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);

  }*/
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), Res.ic_rider);
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), Res.ic_placeholder);
  }

  Future<void> getUserData() async {
    riderStatus = await getRiderStatus();
    var userdata = await Utils.getUser();
    setState(() {
      user = userdata;
      riderStatus = riderStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);
    // FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    // FlutterStatusbarcolor.setStatusBarWhiteForeground(false);

    // updatePinOnMap();

    // onMapCreated(_mapController);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {'checkstatus': checkStatus});
        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    googleMap(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(
                                      context, {'checkstatus': checkStatus});
                                },
                                child: Padding(
                                    padding: EdgeInsets.only(top: 50, left: 16),
                                    child: Image.asset(
                                      Res.ic_back,
                                      width: 16,
                                      height: 16,
                                    )),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 16, top: 50),
                                child: Text(
                                  "Location",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ),
                            ]),
                        Container(
                          margin: EdgeInsets.only(
                              left: 5, right: 5, bottom: 5, top: 35),
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
                                "${widget.locationOf}  View",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: AppConstant.fontBold,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(13)),
                          margin:
                              EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          width: double.infinity,
                          height: widget.orderAccepted ? 220 : 180,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (widget.orderAccepted &&
                                      (widget.locationOf == "Kitchen" ||
                                          widget.locationOf == "Delivery"))
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 5,
                                              right: 5,
                                              bottom: 10,
                                              top: 10),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          height: 45,
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
                                            child: Center(
                                              child: Text(
                                                " ${(checkStatus == 'on_the_way_to_collect_food' ? 'On the Way to Collect Food' : (checkStatus == 'arrived_at_kitchen' ? 'Arrived At Kitchen' : (checkStatus == 'order_getting_ready' ? "Order Getting Ready" : (checkStatus == 'collected_and_delivery_in_progress' ? 'Collected and Delivery in Progress' : 'Unknown'))))}   ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily:
                                                        AppConstant.fontBold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 18.0),
                                          child: InkWell(
                                            onTap: () {
                                              showMoreDialog(context);
                                            },
                                            child: Icon(Icons.more_horiz,
                                                color: Colors.white, size: 40),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, top: 5),
                                    child: Text(
                                      "${widget.locationOf} Address :",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                  ),
                                  Padding(
                                    child: Text(
                                      "Order No: ${widget.orderNumber}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontFamily: AppConstant.fontBold),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 16, top: 5, right: 16),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 16, top: 5),
                                  child: Text(
                                    widget.deliveryAddress,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ),
                              ),
                              (widget.orderAccepted &&
                                      widget.locationOf == "Delivery")
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Opacity(
                                          opacity: checkStatus ==
                                                  "collected_and_delivery_in_progress"
                                              ? 1.0
                                              : 0.5,
                                          child: GestureDetector(
                                            onTap: () {
                                              checkStatus ==
                                                      "collected_and_delivery_in_progress"
                                                  ? getStartDelivery(
                                                      context,
                                                      widget.orderid ?? '0',
                                                      widget.orderitemsId ??
                                                          '0')
                                                  : Fluttertoast.showToast(
                                                      msg:
                                                          "Please Collect the Order and Update the Status! ");
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: 5,
                                                  right: 5,
                                                  bottom: 5,
                                                  top: 5),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              height: 45,
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
                                                child: Center(
                                                  child: Text(
                                                    " START DELIVERY  ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: AppConstant
                                                            .fontBold,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              (widget.orderAccepted &&
                                      widget.locationOf == "Kitchen")
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              MapsLauncher.launchCoordinates(
                                                  kitchenlat, kitchenlong, ''),
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 5,
                                                right: 5,
                                                bottom: 5,
                                                top: 5),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            height: 45,
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
                                              child: Center(
                                                child: Text(
                                                  " START PICK UP  ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          AppConstant.fontBold,
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  Future<beanStartDelivery.BeanStartDelivery?> getStartDelivery(
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
        beanStartDelivery.BeanStartDelivery bean =
            await ApiProvider().starDelivery(from);

        if (bean.status == true) {
          progressDialog!.dismiss();
          setState(() {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => OrderScreen(0)));
          });
          return bean;
        } else {
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

  Future<void> showMoreDialog(BuildContext context) {
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
                // margin: EdgeInsets.fromLTRB(_w / 60, _w / 60, _w / 60, 0),
                padding: EdgeInsets.all(_w / 60),
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
                              )),
                        ),
                        Container(
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
                              child: const Text(
                                "Arrived Kitchen",
                              )),
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
                              child: const Text(
                                "Order Getting Ready",
                              )),
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
                                "Collected And Delivery In Progress",
                              )),
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
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                    GestureDetector(
                      onTap: () => {riderStatusUpdate()},
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
                  ],
                ),
              ],
            );
          });
        });
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: SOURCE_LOCATION,
        icon: sourceIcon!,
      ));
      // destination pin
      _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: DEST_LOCATION,
        icon: destinationIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          //popup info
          title: name,
        ),
      ));
    });
  }

  setPolylines() async {
/*    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(googleAPIKey, PointLatLng( SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
        PointLatLng( DEST_LOCATION.latitude, DEST_LOCATION.longitude),

        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
    );
    if (result.points.isNotEmpty) {
         result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }*/
    polylineCoordinates2.clear();
    _polylines2.clear();
    List<PointLatLng> result = (await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
      PointLatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude),
    ))
        .points;
    // List<PointLatLng> result = (await polylinePoints.getRouteBetweenCoordinates(
    //     googleAPIKey,
    //     SOURCE_LOCATION.latitude,
    //     SOURCE_LOCATION.longitude,
    //     DEST_LOCATION.latitude,
    //     DEST_LOCATION.longitude));
/*    List<PointLatLng> result = (await polylinePoints.getRouteBetweenCoordinates(googleAPIKey, double.parse(kitchenlat),double.parse(kitchenlong), double.parse(deliverylatitude),double.parse(deliverylongitude),));*/
    if (result.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point) {
        polylineCoordinates2.add(LatLng(point.latitude, point.longitude));
        polylineCoordinates = polylineCoordinates2;
      });
    }

    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
          width: 4,
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines2.add(polyline);
      _polylines = _polylines2;
    });
  }

  Future<GetOrderDetails?> getOrderDetails(
      BuildContext context,
      String? orderId,
      String? orderItemsId,
      String latitude,
      String longitude) async {
    LocationData _currentPosition = await location.getLocation();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": orderId.toString(),
        'orderitems_id': orderItemsId,
        "rider_longitude": _currentPosition.longitude.toString(),
        "rider_latitude": _currentPosition.latitude.toString(),
      });
      GetOrderDetails bean = await ApiProvider().getOrderDetails(from);
      if (bean.status == true) {
        data = bean.data![0];
        if (bean.data![0].status == "Delivered") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => OrderScreen(0)));
        }
        setState(() {
          SOURCE_LOCATION =
              LatLng(double.parse(latitude), double.parse(longitude));
          kitchenlat = double.parse(bean.data![0].kitchenLatitude ?? '');
          kitchenlong = double.parse(bean.data![0].kitchenLongitude ?? '');
          deliverylatitude = double.parse(bean.data![0].deliverylatitude ?? '');
          deliverylongitude =
              double.parse(bean.data![0].deliverylongitude ?? '');

          DEST_LOCATION = widget.locationOf == "Delivery"
              ? LatLng(double.parse(bean.data![0].deliverylatitude ?? ''),
                  double.parse(bean.data![0].deliverylongitude ?? ''))
              : LatLng(double.parse(bean.data![0].kitchenLatitude ?? ''),
                  double.parse(bean.data![0].kitchenLongitude ?? ''));
          name = widget.locationOf == "Delivery"
              ? bean.data![0].customername
              : bean.data![0].kitchenname;
        });
        return bean;
      } else {
        Utils.showToast(bean.message ?? "");
      }

      return null;
    } on HttpException catch (exception) {
      print(exception);
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  Future delivered(String? orderId, String? orderItemsId) async {
    progressDialog!.show();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "orderid": orderId,
        "token": "123456789",
        'orderitems_id': orderItemsId
      });
      await _locationSubscription!.cancel();
      var bean = await ApiProvider().delivered(from);
      if (bean['status'] == true) {
        progressDialog!.dismiss();
        setState(() {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => TripSummaryScreen(
                        orderid: orderId,
                        orderitems_id: orderItemsId,
                      )),
              (route) => false);
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

  googleMap() {
    if (data != null) {
      setState(() {});
      return GoogleMap(
          myLocationEnabled: false,
          compassEnabled: false,
          tiltGesturesEnabled: false,
          markers: _markers,
          polylines: _polylines,
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: onMapCreated,
          initialCameraPosition: _cameraPosition!
          /*CameraPosition(
             zoom: CAMERA_ZOOM,
             bearing: CAMERA_BEARING,
             tilt: CAMERA_TILT,
             target: SOURCE_LOCATION

         ),*/
          );
    } else {
      return Container();
    }
  }

  updatePinOnMap() async {
    // // create a new CameraPosition instance
    // // every time the location changes, so the camera
    // // follows the pin as it moves with an animation
    // CameraPosition cPosition = CameraPosition(
    //   zoom: CAMERA_ZOOM,
    //   tilt: CAMERA_TILT,
    //   bearing: CAMERA_BEARING,
    //   target: LatLng(currentLocation.latitude, currentLocation.longitude),
    // );
    // final GoogleMapController controller = await _controller.future;
    // controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // // do this inside the setState() so Flutter gets notified
    // // that a widget update is due
    // setState(() {
    //   // updated position
    //   var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
    //
    //   sourcePinInfo.location = pinPosition;
    //
    //   // the trick is to remove the marker (by id)
    //   // and add it again at the updated location
    //   _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
    //   _markers.add(Marker(
    //       markerId: MarkerId('sourcePin'),
    //       onTap: () {
    //         setState(() {
    //           currentlySelectedPin = sourcePinInfo;
    //           pinPillPosition = 0;
    //         });
    //       },
    //       position: pinPosition, // updated position
    //       icon: sourceIcon));
    // });

    _cameraPosition = CameraPosition(
      zoom: cameraZOOM,
      tilt: cameraTILT,
      bearing: cameraBEARING,
      target: LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
    );

    _mapController
        ?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "sourcePin");
      _markers.add(
        Marker(
            markerId: MarkerId("sourcePin"),
            position:
                LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
            flat: true,
            anchor: Offset(0.5, 0.5),
            infoWindow: InfoWindow(title: "first"),
            icon: sourceIcon!),
      );
    });
  }

  Future _listenLocation() async {
    _locationSubscription =
        _locationTracker.onLocationChanged.handleError((dynamic err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription!.cancel();
    }).listen((LocationData currentLocation) {
      _error = null;
      future = getOrderDetails(
          context,
          widget.orderid,
          widget.orderitemsId,
          currentLocation.latitude.toString(),
          currentLocation.longitude.toString());
      updatePinOnMap();
      setMapPins();
      setPolylines();
    });
  }

  LatLngBounds boundsFromLatLngList(List<LatLng?>? list) {
    assert(list!.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng? latLng in list!) {
      if (x0 == null) {
        x0 = x1 = latLng!.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng!.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    // _mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    super.dispose();
  }

  Future riderStatusUpdate() async {
    progressDialog!.show();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": widget.orderid,
        "orderitems_id": widget.orderitemsId,
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
                        : 'Unknown'))));
        Utils.showToast("Status Updated to $msg");
        Navigator.pop(context, 'Cancel');
        progressDialog!.dismiss();

        setState(() {
          checkStatus = _character!.name;
        });
        return bean;
      } else {
        Utils.showToast("");
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

  // void riderOrderDelayValidation() {
  //   if (stuckInTraffic == false &&
  //       roadClosedDivertNewRoute == false &&
  //       newDeliveryAddressDivertedByCustomer == false &&
  //       delayother == false) {
  //     Utils.showToast("Please select Delay Reason!");
  //   } else {
  //     riderOrderDelay(widget.orderid ?? '0', widget.orderitemsId ?? '0');
  //   }
  // }

  // void riderOrderIssueValidation() {
  //   if (heavyTrafficDeliveryTimeIssue == false &&
  //       addressNotFound == false &&
  //       customerBlamesHeDidntPlaceAnOrder == false &&
  //       customerNotAcceptingTheOrder == false &&
  //       customerDoorClosed == false &&
  //       other == false) {
  //     Utils.showToast("Please select Issue!");
  //   } else {
  //     riderOrderIssue(widget.orderid ?? '0', widget.orderitemsId ?? '0');
  //   }
  // }

  // Future riderOrderDelay(String orderid, String orderitems_id) async {
  //   progressDialog!.show();
  //   try {
  //     var user = await Utils.getUser();
  //     FormData from = FormData.fromMap({
  //       "userid": user.data!.userId,
  //       "token": "123456789",
  //       "orderid": orderid,
  //       "orderitems_id": orderitems_id,
  //       'delivery_delay': ((stuckInTraffic == true ? "Stuck In Traffic," : "") +
  //           (roadClosedDivertNewRoute == true
  //               ? "Road Closed Divert New Route,"
  //               : '') +
  //           (newDeliveryAddressDivertedByCustomer == true
  //               ? "New Delivery Address Diverted By Customer,"
  //               : "") +
  //           (delayother == true ? "Other" : "")),
  //       'description': description_controller.text
  //     });
  //     BeanCheckApiModel bean = await ApiProvider().riderOrderDelay(from);
  //     progressDialog!.dismiss();
  //     if (bean.status == true) {
  //       Utils.showToast(bean.message ?? "");
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

  // Future riderOrderIssue(String orderid, String orderitems_id) async {
  //   progressDialog!.show();
  //   try {
  //     var user = await Utils.getUser();
  //     FormData from = FormData.fromMap({
  //       "userid": user.data!.userId,
  //       "token": "123456789",
  //       "orderid": orderid,
  //       "orderitems_id": orderitems_id,
  //       'delivery_issue': ((heavyTrafficDeliveryTimeIssue == true
  //               ? "Heavy Traffic Delivery Time Issue,"
  //               : "") +
  //           (addressNotFound == true ? "Address Not Found," : '') +
  //           (customerBlamesHeDidntPlaceAnOrder == true
  //               ? "Customer Blames He Didnt Place An Order,"
  //               : "") +
  //           (customerNotAcceptingTheOrder == true
  //               ? "Customer Not Accepting The Order"
  //               : "") +
  //           (customerDoorClosed == true ? "Customer Door Closed" : "") +
  //           (other == true ? "Other" : "")),
  //       'description': description_controller.text
  //     });

  //     BeanCheckApiModel bean = await ApiProvider().riderOrderDelay(from);
  //     progressDialog!.dismiss();
  //     if (bean.status == true) {
  //       Utils.showToast(bean.message ?? "");
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
