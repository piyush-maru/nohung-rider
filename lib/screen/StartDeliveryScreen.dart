import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanCheckApiModel.dart';
import 'package:rider_app/model/BeanStartDelivery.dart';
import 'package:rider_app/model/BeanrejectOrder.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/screen/OrderScreen.dart';
import 'package:rider_app/screen/TripSummaryScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rider_app/model/BeanSignUp.dart' as userSi;

import '../res.dart';

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class StartDeliveryScreen extends StatefulWidget {
  var deliveryAddress;
  final String orderid;
  final String orderitemsId;
  final String orderNumber;
  final String? customerNumber;
  final String? kitchenNumber;
  final String? deliveryTime;
  // final String? kitchenName;
  int? tabIndex;
  int? currentOrdersCount;

  StartDeliveryScreen(
      this.deliveryAddress,
      this.orderNumber,
      this.orderid,
      this.orderitemsId,
      this.customerNumber,
      this.kitchenNumber,
      this.deliveryTime,
      this.tabIndex,
      this.currentOrdersCount
      // this.kitchenName
      );

  @override
  StartDeliveryScreenState createState() => StartDeliveryScreenState();
}

class StartDeliveryScreenState extends State<StartDeliveryScreen> {
  CameraPosition? _cameraPosition;
  double cameraZOOM = 14;
  double cameraTILT = 0;
  double cameraBEARING = 30;
  String? _error;
  LatLng SOURCE_LOCATION = LatLng(0.0, 0.0);
  LatLng DEST_LOCATION = LatLng(0.0, 0.0);

  Data? data;

/*  LatLng DEST_LOCATION = LatLng(42.6871386, -71.2143403);*/

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  ProgressDialog? progressDialog;
  Set<Polyline> _polylines = {};
  Set<Polyline> _polylines2 = {};
  List<LatLng> polylineCoordinates = [];
  List<LatLng> polylineCoordinates2 = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyCBZ1E4AGu6xP_VV4GWr_qjnOte9sFmh0A";

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

  Location? _locationTracker;
  StreamSubscription? _locationSubscription;
  Future? future;
  String? userId;
  LocationData? currentLocation;
  final Set<Marker> _markers1 = {};
  Map<PolylineId, Polyline> _polylinesList1 = <PolylineId, Polyline>{};
  bool loadingMap = false;

  var description_controller = TextEditingController();
  var issue_description_controller = TextEditingController();
  String? latCheck;
  String? logCheck;
  // Dealy
  bool stuckInTraffic = false;
  bool roadClosedDivertNewRoute = false;
  bool newDeliveryAddressDivertedByCustomer = false;
  bool delayother = false;

//heavyTrafficDeliveryTimeIssue
  bool heavyTrafficDeliveryTimeIssue = false;
  bool addressNotFound = false;
  bool customerBlamesHeDidntPlaceAnOrder = false;
  bool customerNotAcceptingTheOrder = false;
  bool other = false;
  bool customerDoorClosed = false;
  bool? riderStatus = true;

  bool locationSoFar = false;
  bool vehicleIssue = false;
  bool previousOrderPending = false;
  bool other_cancel = false;
  var cancel_description_controller = TextEditingController();
  userSi.BeanSignUp? user;
  String? kitchenName = '';
  String? customerName = '';

  @override
  void initState() {
    getUserData();
    // getOrderDetails(context);
    _locationTracker = new Location();
    super.initState();
    Future.delayed(Duration.zero, () {
      _listenLocation();
      setSourceAndDestinationIcons();
    });
    Future.delayed(Duration.zero, () {});
  }

  onMapCreated(GoogleMapController _cntlr) {
    _mapController = _cntlr;
    if (sourceLatLng != null && destLatLng != null) {
      var list = [sourceLatLng, destLatLng];
      CameraUpdate u2 =
          CameraUpdate.newLatLngBounds(boundsFromLatLngList(list), 50);
      _mapController!.animateCamera(u2).then((void v) {
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

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);
    // FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    // FlutterStatusbarcolor.setStatusBarWhiteForeground(false);

    // updatePinOnMap();

    // onMapCreated(_mapController);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  googleMap(),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 5, right: 5, bottom: 5, top: 5),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 157, 211, 126),
                              Color.fromARGB(255, 126, 211, 126),
                              Color.fromARGB(255, 126, 211, 133),
                              Color.fromARGB(255, 8, 158, 21)
                            ],
                            begin: Alignment.bottomLeft,
                            stops: [0, 0, 0, 1],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            // "${widget.kitchenName}",
                            "${kitchenName!.toUpperCase()}",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: AppConstant.fontBold,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ),
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
                        height: 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  child: Text(
                                    "Order No: ${widget.orderNumber}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: AppConstant.fontBold),
                                  ),
                                  padding: EdgeInsets.only(left: 16, top: 5),
                                ),
                                GestureDetector(
                                  onTap: () => {
                                    // _makePhoneCall(
                                    //     orderDetails!.data![0].kitchencontactnumber ?? "")
                                    showContactDialog(context)
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 16, top: 5),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Image.asset(
                                      Res.ic_call,
                                      width: 50,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              child: Text(
                                "Customer Name: ${customerName}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: AppConstant.fontBold),
                              ),
                              padding: EdgeInsets.only(left: 16, bottom: 10),
                            ),
                            Padding(
                              child: Text(
                                "Delivery Time: ${widget.deliveryTime}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: AppConstant.fontBold),
                              ),
                              padding: EdgeInsets.only(
                                left: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 16, top: 5, bottom: 8),
                                child: Text(
                                  "Delivery Address :",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 16, top: 0),
                                child: Text(
                                  widget.deliveryAddress,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Wrap(
                                  spacing: 0, // gap between adjacent chips
                                  runSpacing: 0, // gap between lines
                                  direction: Axis.horizontal,
                                  runAlignment: WrapAlignment.start,
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: () => showAlertDialog(context),
                                      child: Container(
                                        width: 80,
                                        // margin: EdgeInsets.only(bottom: 5),
                                        // padding:
                                        //     EdgeInsets.symmetric(horizontal: 5),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xff7ED39C),
                                                Color(0xff089E90)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomCenter,
                                              stops: [0, 1],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Center(
                                                child: Text(
                                                  "DELIVERED",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        height: 35,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => showIssueDialog(context),
                                      child: Container(
                                        // margin: EdgeInsets.only(right: 5),
                                        // padding:
                                        //     EdgeInsets.symmetric(horizontal: 5),
                                        height: 35,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                              "ISSUE",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => showDelayDialog(context),
                                      child: Container(
                                        // margin: EdgeInsets.only(bottom: 5),
                                        // padding:
                                        //     EdgeInsets.symmetric(horizontal: 5),
                                        height: 35,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                              "DELAY",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          MapsLauncher.launchCoordinates(
                                              deliverylatitude,
                                              deliverylongitude,
                                              ''),
                                      child: Container(
                                        width: 40,
                                        // margin: EdgeInsets.only(bottom: 5),
                                        // padding: EdgeInsets.symmetric(
                                        // horizontal: 10),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xff7ED39C),
                                                Color(0xff089E90)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomCenter,
                                              stops: [0, 1],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                          child: Icon(
                                            Icons.directions,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                        ),
                                        height: 35,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            //  Row(
                            //         mainAxisAlignment: MainAxisAlignment.end,
                            //         children: [
                            //           GestureDetector(
                            //             onTap: () => {
                            //               // _makePhoneCall(
                            //               //     orderDetails!.data![0].kitchencontactnumber ?? "")
                            //               showContactDialog(context)
                            //             },
                            //             child: Image.asset(
                            //               Res.ic_call,
                            //               width: 40,
                            //               height: 40,
                            //             ),
                            //           ),
                            //           GestureDetector(
                            //             onTap: () {
                            //               showIssueDialog(context);
                            //             },
                            //             child: Container(
                            //               margin: EdgeInsets.only(
                            //                   left: 5,
                            //                   right: 5,
                            //                   bottom: 5,
                            //                   top: 5),
                            //               padding: EdgeInsets.symmetric(
                            //                   horizontal: 10),
                            //               height: 45,
                            //               decoration: BoxDecoration(
                            //                 borderRadius:
                            //                     BorderRadius.circular(14),
                            //                 gradient: LinearGradient(
                            //                   colors: [
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff089E90)
                            //                   ],
                            //                   begin: Alignment.bottomLeft,
                            //                   stops: [0, 0, 0, 1],
                            //                 ),
                            //               ),
                            //               child: Center(
                            //                 child: Center(
                            //                   child: Text(
                            //                     " ISSUE  ",
                            //                     style: TextStyle(
                            //                         color: Colors.white,
                            //                         fontFamily:
                            //                             AppConstant.fontBold,
                            //                         fontSize: 14),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //           GestureDetector(
                            //             onTap: () {
                            //               showDelayDialog(context);
                            //             },
                            //             child: Container(
                            //               margin: EdgeInsets.only(
                            //                   left: 5,
                            //                   right: 5,
                            //                   bottom: 5,
                            //                   top: 5),
                            //               padding: EdgeInsets.symmetric(
                            //                   horizontal: 10),
                            //               height: 45,
                            //               decoration: BoxDecoration(
                            //                 borderRadius:
                            //                     BorderRadius.circular(14),
                            //                 gradient: LinearGradient(
                            //                   colors: [
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff089E90)
                            //                   ],
                            //                   begin: Alignment.bottomLeft,
                            //                   stops: [0, 0, 0, 1],
                            //                 ),
                            //               ),
                            //               child: Center(
                            //                 child: Center(
                            //                   child: Text(
                            //                     " DELAY  ",
                            //                     style: TextStyle(
                            //                         color: Colors.white,
                            //                         fontFamily:
                            //                             AppConstant.fontBold,
                            //                         fontSize: 14),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //           GestureDetector(
                            //             onTap: () {},
                            //             child: Container(
                            //               margin: EdgeInsets.only(
                            //                   left: 5,
                            //                   right: 5,
                            //                   bottom: 5,
                            //                   top: 5),
                            //               padding: EdgeInsets.symmetric(
                            //                   horizontal: 10),
                            //               height: 45,
                            //               decoration: BoxDecoration(
                            //                 borderRadius:
                            //                     BorderRadius.circular(14),
                            //                 gradient: LinearGradient(
                            //                   colors: [
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff7ED39C),
                            //                     Color(0xff089E90)
                            //                   ],
                            //                   begin: Alignment.bottomLeft,
                            //                   stops: [0, 0, 0, 1],
                            //                 ),
                            //               ),
                            //               child: Center(
                            //                 child: Center(
                            //                   child: Text(
                            //                     " DELIVERED  ",
                            //                     style: TextStyle(
                            //                         color: Colors.white,
                            //                         fontFamily:
                            //                             AppConstant.fontBold,
                            //                         fontSize: 14),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: SOURCE_LOCATION,
          icon: sourceIcon!));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION,
          icon: destinationIcon!));
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

  Future<BeanStartDelivery?> getStartDelivery(
      BuildContext context,
      String orderId,
      String orderItemsId,
      String? latitude,
      String? longitude) async {
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "token": "123456789",
        "userid": user!.data!.userId,
        "orderid": orderId,
        'orderitems_id': orderItemsId,
        'rider_latitude': latitude,
        'rider_longitude': longitude,
      });
      if (latCheck != (double.parse(latitude!)).toStringAsFixed(5) &&
          logCheck != (double.parse(longitude!)).toStringAsFixed(5)) {

        setState(() {
          latCheck = (double.parse(latitude)).toStringAsFixed(5);
          logCheck = (double.parse(longitude)).toStringAsFixed(5);
        });
        BeanStartDelivery bean = await ApiProvider().updateOrderTrack(from);
        if (bean.status == true) {
          data = bean.data;
          setState(() {
            kitchenName = data!.kitcheNname;
            customerName = data!.customerName;
          });
          if (bean.data!.status == "Delivered") {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderScreen(widget.tabIndex)));
          }
          setState(() {
            latCheck = latitude;
            logCheck = longitude;
            // kitchenlat=double.parse(bean.data!.kitchenlatitude);
            // kitchenlong=double.parse(bean.data!.kitchenlongitude);
            deliverylatitude = double.parse(bean.data!.deliveryLatitude ?? '');
            deliverylongitude =
                double.parse(bean.data!.deliveryLongitude ?? '');

            SOURCE_LOCATION = LatLng(
                double.parse(bean.data!.riderLatitude ?? ''),
                double.parse(bean.data!.riderLongitude ?? ''));
            DEST_LOCATION = LatLng(
                double.parse(bean.data!.deliveryLatitude ?? ''),
                double.parse(bean.data!.deliveryLongitude ?? ''));
          });
          return bean;
        } else {
          Utils.showToast(bean.message ?? "");
        }
      }

      return null;
    } on HttpException catch (exception) {
      print(exception);
    } catch (exception) {
      print(exception);
    }
  }

  Future delivered(String orderId, String orderItemsId) async {
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
      Navigator.of(context).pop();
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
             zoom:  CAMERA_ZOOM,
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
    // // every time Sthe location changes, so the camera
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

    _mapController!
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
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
        _locationTracker!.onLocationChanged.handleError((dynamic err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription!.cancel();
    }).listen((LocationData currentLocation) {
      _error = null;
      future = getStartDelivery(
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

  Future<void> showDelayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Delay',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              content: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height / 1.8,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: CheckboxListTile(
                          title: Text(
                            "Stuck In Traffic",
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
                          ),
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
                          title: Text(
                            "Road Closed Divert New Route",
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
                          ),
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
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
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
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
                          ),
                          activeColor: Color.fromARGB(255, 65, 129, 67),
                          checkColor: Colors.white,
                          value: delayother,
                          onChanged: (bool? value) {
                            setState(() {
                              delayother = !delayother;
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
                              maxLines: 6, //or null
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
                              "Close",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: AppConstant.fontBold,
                                  fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () => {riderOrderDelayValidation()},
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
                                  fontSize: 13),
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
              title: Center(
                child: Text(
                  'Issue',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              content: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: CheckboxListTile(
                          title: Text(
                            "Heavy Traffic Delivery Time Issue",
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
                          ),
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
                          title: Text(
                            "Address Not Found",
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
                          ),
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
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
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
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
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
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
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
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: CheckboxListTile(
                          title: Text(
                            "Other",
                            // style: TextStyle(
                            //   fontFamily: AppConstant.fontRegular,
                            // ),
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
                              maxLines: 6, //or null
                              decoration: InputDecoration.collapsed(
                                  hintText: "Description"),
                              controller: issue_description_controller,
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          elevation: 8, // Change this
                          shadowColor: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => {
                        // Navigator.pop(context, 'Cancel'),
                        // showCancelDialog(context)
                        orderCancelValidation()
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
                              "Cancel Order",
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
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {riderOrderIssueValidation()},
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
                      child: CheckboxListTile(
                        title: Text(
                          "Other",
                          style: TextStyle(
                            fontFamily: AppConstant.fontRegular,
                          ),
                        ),
                        activeColor: Color.fromARGB(255, 65, 129, 67),
                        checkColor: Colors.white,
                        value: other_cancel,
                        onChanged: (bool? value) {
                          setState(() {
                            other_cancel = !other_cancel;
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
                            controller: cancel_description_controller,
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
                            widget.orderid, widget.orderitemsId)
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          // width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Customer",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                color: Color.fromARGB(255, 87, 145, 117),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              {_makePhoneCall('${widget.customerNumber}')},
                          child: Container(
                            // width: MediaQuery.of(context).size.width / 1.5,
                            child: Text(
                              "${widget.customerNumber}",
                              style: TextStyle(
                                  fontFamily: AppConstant.fontRegular,
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Kitchen",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                color: Color.fromARGB(255, 87, 145, 117),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              {_makePhoneCall('${widget.kitchenNumber}')},
                          child: Container(
                            // width: MediaQuery.of(context).size.width / 1.5,
                            child: Text(
                              "${widget.kitchenNumber}",
                              style: TextStyle(
                                  fontFamily: AppConstant.fontRegular,
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            "Call Nohung",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                color: Color.fromARGB(255, 87, 145, 117),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => {_makePhoneCall('+91 7672057570')},
                              child: Container(
                                // width: MediaQuery.of(context).size.width / 1.5,
                                child: Text(
                                  "+91 7672057570",
                                  style: TextStyle(
                                      fontFamily: AppConstant.fontRegular,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
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
                          "Are you sure you want to mark this order as Delivered."),
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
                    delivered(widget.orderid, widget.orderitemsId);
                  },
                ),
              ],
            ));
  }

  void riderOrderDelayValidation() {
    if (stuckInTraffic == false &&
        roadClosedDivertNewRoute == false &&
        newDeliveryAddressDivertedByCustomer == false &&
        delayother == false) {
      Utils.showToast("Please select Delay Reason!");
    } else if (delayother == true && description_controller.text == '') {
      Utils.showToast("Please Enter the Description!");
    } else {
      riderOrderDelay(widget.orderid, widget.orderitemsId);
    }
  }

  void riderOrderIssueValidation() {
    if (heavyTrafficDeliveryTimeIssue == false &&
        addressNotFound == false &&
        customerBlamesHeDidntPlaceAnOrder == false &&
        customerNotAcceptingTheOrder == false &&
        customerDoorClosed == false &&
        other == false) {
      Utils.showToast("Please select Issue!");
    } else if (other == true && issue_description_controller.text == '') {
      Utils.showToast("Please Enter the Description!");
    } else {
      riderOrderIssue(widget.orderid, widget.orderitemsId);
    }
  }

  void orderCancelValidation() {
    if (heavyTrafficDeliveryTimeIssue == false &&
        addressNotFound == false &&
        customerBlamesHeDidntPlaceAnOrder == false &&
        customerNotAcceptingTheOrder == false &&
        customerDoorClosed == false &&
        other == false) {
      Utils.showToast("Please select Delay Reason!");
    } else if (other == true && issue_description_controller.text == '') {
      Utils.showToast("Please Enter the Description!");
    } else {
      orderCancelIssue(widget.orderid, widget.orderitemsId);
    }
  }

  Future orderCancelIssue(String orderid, String orderitems_id) async {
    progressDialog!.show();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": orderid,
        "orderitems_id": orderitems_id,
        'reason': ((heavyTrafficDeliveryTimeIssue == true
                ? "Heavy Traffic Delivery Time Issue, "
                : "") +
            (addressNotFound == true ? "Address Not Found, " : '') +
            (customerBlamesHeDidntPlaceAnOrder == true
                ? "Customer Blames He Didnt Place An Order, "
                : "") +
            (customerNotAcceptingTheOrder == true
                ? "Customer Not Accepting The Order, "
                : "") +
            (customerDoorClosed == true ? "Customer Door Closed, " : "") +
            (other == true ? "Other" : "")),
        'description': issue_description_controller.text
      });

      BeanCheckApiModel bean = await ApiProvider().orderCancelRequest(from);
      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        Navigator.pop(context, 'Cancel');
        progressDialog!.dismiss();
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

  Future riderOrderDelay(String orderid, String orderitems_id) async {
    progressDialog!.show();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": orderid,
        "orderitems_id": orderitems_id,
        'delivery_delay':
            ((stuckInTraffic == true ? "Stuck In Traffic, " : "") +
                (roadClosedDivertNewRoute == true
                    ? "Road Closed Divert New Route, "
                    : '') +
                (newDeliveryAddressDivertedByCustomer == true
                    ? "New Delivery Address Diverted By Customer, "
                    : "") +
                (delayother == true ? "Other" : "")),
        'description': description_controller.text
      });
      BeanCheckApiModel bean = await ApiProvider().riderOrderDelay(from);
      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        Navigator.pop(context, 'Cancel');
        progressDialog!.dismiss();
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

  Future riderOrderIssue(String orderid, String orderitems_id) async {
    progressDialog!.show();
    try {
      // var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user!.data!.userId,
        "token": "123456789",
        "orderid": orderid,
        "orderitems_id": orderitems_id,
        'delivery_issue': ((heavyTrafficDeliveryTimeIssue == true
                ? "Heavy Traffic Delivery Time Issue, "
                : "") +
            (addressNotFound == true ? "Address Not Found, " : '') +
            (customerBlamesHeDidntPlaceAnOrder == true
                ? "Customer Blames He Didnt Place An Order, "
                : "") +
            (customerNotAcceptingTheOrder == true
                ? "Customer Not Accepting The Order, "
                : "") +
            (customerDoorClosed == true ? "Customer Door Closed, " : "") +
            (other == true ? "Other" : "")),
        'description': issue_description_controller.text
      });

      BeanCheckApiModel bean = await ApiProvider().riderOrderIssue(from);
      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        Navigator.pop(context, 'Cancel');
        progressDialog!.dismiss();
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
    if (locationSoFar == false &&
        vehicleIssue == false &&
        previousOrderPending == false &&
        other_cancel == false) {
      Utils.showToast("Please select Rejecting Reason!");
    } else if (other_cancel == true &&
        cancel_description_controller.text == '') {
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
        'reset_rider': true,
        'reason': ((locationSoFar == true ? "Location So Far, " : "") +
            (vehicleIssue == true ? "Vehicle Issue, " : '') +
            (previousOrderPending == true ? "Previous Order Pending, " : "") +
            (other_cancel == true ? "Other" : "")),
        'description': cancel_description_controller.text
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
