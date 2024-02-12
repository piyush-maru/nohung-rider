/*
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:trip_road/model/BaseResponse.dart';
import 'package:trip_road/model/DirectionRouteBean.dart';
import 'package:trip_road/model/GetBookingNewBean.dart';
import 'package:trip_road/model/UserInfoBean.dart';
import 'package:trip_road/network/APIProvider.dart';
import 'package:trip_road/res.dart';
import 'package:trip_road/screen/home/HomeRideHistory.dart';
import 'package:trip_road/screen/modifyAddress/ModifyConfirmPathScreen.dart';
import 'package:trip_road/util/CommonMapFunction.dart';
import 'package:trip_road/util/Constants.dart';
import 'package:trip_road/util/HttpException.dart';
import 'package:trip_road/util/LottieWidget.dart';
import 'package:trip_road/util/PrefManager.dart';
import 'package:trip_road/util/Utils.dart';
import 'package:trip_road/util/poly_util.dart';
import 'package:trip_road/util/progress_dialog.dart';

import 'HomeScreen.dart';
import 'ReceiptScreen.dart';

class StartRideScreen extends StatefulWidget {

  CurrentBean bookingTripData;
  StartRideScreen(this.bookingTripData,);

  @override
  State<StatefulWidget> createState() => StartRideScreenState();
}

class StartRideScreenState extends State<StartRideScreen> {

  CameraPosition _cameraPosition;
  double cameraZOOM = 14;
  double cameraTILT = 0;
  double cameraBEARING = 30;


  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

  LatLng sourceLatLng;
  LatLng destLatLng;

  GoogleMapController _mapController;

  Location _locationTracker;
  StreamSubscription _locationSubscription;

  List<RoutesBean> routeBean = [];



  String userId;
  UserInfoBean userInfoBean;

  final Set<Marker> _markers1 = {};

  Map<PolylineId, Polyline> _polylinesList1 = <PolylineId, Polyline>{};
  bool loadingMap = false;

  String _error;

  String roadLinkIds;

  @override
  void initState() {
    _locationTracker = new Location();
    Future.delayed(Duration.zero, () {
      getPrefData();
      CommonThings.height = MediaQuery.of(context).size.height / 2.0;
      _listenLocation();
      setSourceAndDestinationIcons();

    });

    Future.delayed(Duration(seconds: 10),(){
      completeTrip();
    });
    super.initState();
  }


  getPrefData() {
    PrefManager.getUserInfo().then((value) => {
      setState(() {
        if (value != null) {
          userInfoBean = value;
          userId = userInfoBean.results.user_id.toString();
        }
      })
    });
  }


  void updatePinOnMap(sourceLatLng1) async {

    _cameraPosition = CameraPosition(
      zoom: cameraZOOM,
      tilt: cameraTILT,
      bearing: cameraBEARING,
      target: LatLng(sourceLatLng1.latitude,sourceLatLng1.longitude),
    );
    _mapController.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    setState(() {
      _markers1.removeWhere((m) => m.markerId.value == "sourcePin");
      _markers1.add(
        Marker(
            markerId: MarkerId("sourcePin"),
            position: LatLng(sourceLatLng1.latitude,sourceLatLng1.longitude),
            flat: true,
            anchor: Offset(0.5,0.5),
            infoWindow: InfoWindow(title: "first"),
            icon: sourceIcon),
      );
    });
  }

  Future _listenLocation() async {
    _locationSubscription =
        _locationTracker.onLocationChanged.handleError((dynamic err) {

          setState(() {
            _error = err.code;
          });
          _locationSubscription.cancel();
        }).listen((LocationData currentLocation) {
          _error = null;
          updatePinOnMap(currentLocation);
        });
  }

  Future<void> _stopListen() async {
    _locationSubscription.cancel();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Utils.setStatusBarWhiteForeground(true);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Stack(
                alignment: Alignment(0.0, 0.0),
                children: [
                  _cameraPosition == null
                      ? Container(
                    height: double.infinity,
                    child: Center(child: LottieWidget()),
                  )
                      : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _cameraPosition,
                    markers: _markers1,
                    myLocationButtonEnabled: true,
                    onMapCreated: _onMapCreated,
                    polylines: Set<Polyline>.of(_polylinesList1.values),
                    trafficEnabled: false,
                    compassEnabled: false,
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                  Positioned(
                    top: 15,
                    left: 10,
                    right: 10,
                    child: SafeArea(
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[400],
                                  blurRadius: 6.0,
                                ),
                              ]),
                          child: Column(children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: Color(0xff30D5C8),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                // color: Colors.blue,
                                padding: EdgeInsets.only(top: 15, bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Container(
                                          child: Image.asset(
                                            Res.trip_straight,
                                            width: 15,
                                            height: 18,
                                          )),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          "123, abc street",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: Constants.fontFamily,
                                              fontWeight: FontWeight.bold,
                                              color: Constants.colorSplash),
                                        ),
                                      ),
                                      flex: 4,
                                    )
                                  ],
                                )),
                            Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[400],
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                padding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Text(
                                              "Entry link time",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                  Constants.fontFamily,
                                                  fontWeight: FontWeight.normal,
                                                  color: Constants.colorSplash),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${Constants.format2.format(Constants.format1.parse(widget.bookingTripData.trip_entry_time))}".toLowerCase(),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Constants.colorSplash,
                                                  fontFamily: Constants.fontFamily,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      margin:
                                      EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xffD8D8D8),
                                              width: 1)),
                                    ),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            child: Text(
                                              "End link time",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: Constants.fontFamily,
                                                  fontWeight: FontWeight.normal,
                                                  color: Constants.colorSplash),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${Constants.format2.format(Constants.format1.parse(widget.bookingTripData.trip_exit_time))}".toLowerCase(),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Constants.colorSplash,
                                                  fontFamily: Constants.fontFamily,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      margin:
                                      EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xffD8D8D8),
                                              width: 1)),
                                    ),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            child: Text(
                                              "Link Length",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                  Constants.fontFamily,
                                                  fontWeight: FontWeight.normal,
                                                  color: Constants.colorSplash),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${widget.bookingTripData.trip_distance} m",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Constants.colorSplash,
                                                  fontFamily:
                                                  Constants.fontFamily,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ])),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 10,
                    right: 10,
                    child: SafeArea(
                      child: Container(
                          alignment: Alignment.bottomLeft,
                          padding:
                          EdgeInsets.only(bottom: 25, left: 15, top: 450),
                          child: InkWell(
                            child: CircleAvatar(
                                backgroundColor: Color(0xffFF7901),
                                radius: 30,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Text(
                                        "60",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontFamily: Constants.fontFamily,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        "km/h",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: Constants.fontFamily,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                      ),
                                    )
                                  ],
                                ) //Text
                            ),
                          )

                        //CirlceAvatar
                      ), //Center
                    ), //Scaf
                  ),
                ],
              ),
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Color(0xff30D5C8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[400],
                      blurRadius: 6.0,
                    ),
                  ]),
              child: SingleChildScrollView(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Container(
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  child: Text(
                                    " ",//"1 min",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontFamily: Constants.fontFamily,
                                        fontWeight: FontWeight.bold,
                                        color: Constants.colorSplash),
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 15),
                                          child: Text(
                                            widget.bookingTripData.trip_time+" mt",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: Constants.fontFamily,
                                                fontWeight: FontWeight.normal,
                                                color: Constants.colorSplash),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black
                                          ),
                                          height: 6,
                                          width: 6,
                                          margin: EdgeInsets.only(right: 5),
                                        ),
                                        Container(
                                          child: Text(
                                            "${Constants.format2.format(Constants.format1.parse(widget.bookingTripData.trip_exit_time))}".toLowerCase(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: Constants.fontFamily,
                                                fontWeight: FontWeight.normal,
                                                color: Constants.colorSplash),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            )),
                        Container(
                          margin: EdgeInsets.all(20),
                          child: Row(
                            children: [

                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                HomeRideHistory(widget.bookingTripData)));
                                  },
                                  child: Image.asset(
                                    Res.arrow_leftright,
                                    width: 44,
                                    height: 44,
                                  )),
                              InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Image.asset(
                                      Res.redcancel,
                                      width: 44,
                                      height: 44,
                                    )),
                              ),
                            ],
                          ),
                        )
                      ])))
        ],
      ),
    );
  }


  void setSourceAndDestinationIcons() async {
    final Uint8List markerIcon = await CommonMapFunction.getBytesFromAsset(Res.dest_map, 50);
    final Uint8List markerIcon1 = await CommonMapFunction.getBytesFromAsset(Res.source_map, 50);

    sourceIcon = BitmapDescriptor.fromBytes(markerIcon);
    destinationIcon = BitmapDescriptor.fromBytes(markerIcon1);

    _setSourceAndDestinationByNodeApi();
  }

  _setSourceAndDestinationMarker(sourceLatLng1,destLatLng1) {

    _cameraPosition = CameraPosition(
        target: sourceLatLng1,
        zoom: cameraZOOM,
        tilt: cameraTILT,
        bearing: cameraBEARING);
    _markers1.add(
      Marker(
          markerId: MarkerId("last $destLatLng"),
          position: destLatLng1,
          flat: true,
          anchor: Offset(0.5,0.5),
          infoWindow: InfoWindow(title: "last"),
          icon: destinationIcon),
    );
    _markers1.add(
      Marker(
          markerId: MarkerId("sourcePin"),
          position: sourceLatLng,
          flat: true,
          anchor: Offset(0.5,0.5),
          infoWindow: InfoWindow(title: "first"),
          icon: sourceIcon),
    );
    setState((){

    });
    //setBiggestRouteSinglePolyLIne();
  }


  _onMapCreated(GoogleMapController _cntlr) {
    _mapController = _cntlr;
    if (sourceLatLng != null && destLatLng != null) {
      var list = [sourceLatLng, destLatLng];
      CameraUpdate u2 =
      CameraUpdate.newLatLngBounds(boundsFromLatLngList(list), 50);
      _mapController.animateCamera(u2).then((void v) {
        check(u2, _mapController);
      });
    }
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    // _mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  _setSourceAndDestinationByNodeApi() {
    if (widget.bookingTripData.roadlink_id != null){
      List<dynamic> list = json.decode(widget.bookingTripData.roadlink_id);
      roadLinkIds = json.encode(list[0]);

      sourceLatLng = LatLng(
          list[0][0], list[0][1]); //cp[0];
      destLatLng = LatLng(list[list.length-1][2],
          list[list.length-1][3]); //cp[cp.length-1];
      _setSourceAndDestinationMarker(sourceLatLng,destLatLng);
      explorePolyLine1(list);
    }
  }

  explorePolyLine1(list) async {
    if(_polylinesList1 !=null){
      if(_polylinesList1.isNotEmpty){
        _polylinesList1.clear();
      }
    }

    List<LatLng> setPoints = [];
    Polyline polyline;
    for(int j=0;j<list.length-1;j++) {
      setPoints.add(LatLng(list[j][0], list[j][1]));
    }
    int c = 0;
    final String polylineIdVal = 'polyline_id_$c';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    setState(() {
      polyline = Polyline(
        polylineId: polylineId,
        color: Colors.black,
        points: setPoints,
        width: 2,
        visible: true,
        geodesic: true,
        consumeTapEvents: true,
        startCap: Cap.squareCap,
        endCap: Cap.roundCap,
        jointType: JointType.bevel,
      );
      _polylinesList1[polylineId] = polyline;
    });

  }

  void completeTrip() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (context, setModelState) {
          return Container(
              color: Colors.transparent,
              height: 255,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 21),
                    width: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xffABABAB),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      "Complete Your Trip",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: Constants.fontFamily,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 20, left: 30, right: 30,bottom: 15),
                      alignment: Alignment.center,
                      child: Text(
                          " You have received your destination.\n Did you want to complete your trip? " ,maxLines: 3,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              height: 2,
                              fontFamily: Constants.fontFamily,
                              fontWeight: FontWeight.normal))),
                  InkWell(
                    onTap:(){
                      Navigator.pop(context);
                      completeBooking();
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,

                      margin: EdgeInsets.only(
                        right: 30, left: 30, top: 20,),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xff050505)),
                      child: Text(
                        "Complete Your Trip",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: Constants.fontFamily,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),







                ],
              ));
        });
      },
    );
  }

  void completeBooking() async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog!.show();
    try {
      Map<String,dynamic> params = Map();
      params["booking_id"] = widget.bookingTripData.booking_id;
      BaseResponse response = await APIProvider.base().funCompleteBooking(params);
      progressDialog!.dismiss();
      if(response.success == 1){
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>ReceiptScreen()));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
            ModalRoute.withName('/')
        );
      }
      else{
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
            ModalRoute.withName('/')
        );
      }
    } on HttpException catch (exception) {
      progressDialog!.dismiss();
      Utils.showToast(exception.response);
    }
    catch(exception){
      progressDialog!.dismiss();
      Utils.showToast(exception);
    }

  }


}

*/
