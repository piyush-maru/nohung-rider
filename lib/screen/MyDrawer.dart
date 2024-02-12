import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanRiderStatus.dart';
import 'package:rider_app/model/BeanSignUp.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/screen/HomeScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/PrefManager.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';

import '../res.dart';

class MyDrawers extends StatefulWidget {
  @override
  MyDrawersState createState() => MyDrawersState();
}

class MyDrawersState extends State<MyDrawers> {
  BeanSignUp? userBean;
  var name = "";
  var address = "";
  ProgressDialog? progressDialog;

  var isRiderActive;

  bool? riderStatus = true;
  void getUser() async {
    riderStatus = await getRiderStatus();
    userBean = await Utils.getUser();
    name = userBean!.data!.kitchenname ?? '';
    address = userBean!.data!.cityid ?? '';
    setState(() {
      riderStatus = riderStatus;
      _switchValue = riderStatus;
    });
  }

  bool? _switchValue = true;

  int _radioValue = -1;

  void _handleRadioValueChange(int value) {
    _radioValue = value;
    switch (_radioValue) {
      case 0:
        break;

      case 1:
        break;
    }
  }

  @override
  void initState() {
    getUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
        child: Container(
          color: Colors.white,
          width: 300,
          child: Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30, left: 20),
                  child: Image.asset(
                    Res.ic_user,
                    width: 90,
                    height: 90,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      name.toString().toUpperCase(),
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: AppConstant.fontBold,
                          fontSize: 18),
                    )),
                // Padding(
                //     padding: EdgeInsets.only(left: 20, top: 6),
                //     child: Text(
                //       address,
                //       style: TextStyle(
                //         color: Colors.grey,
                //           fontFamily: AppConstant.fontBold, fontSize: 14),
                //     )),
                SizedBox(
                  height: 16,
                ),

                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/home");
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        elevation: MaterialStateProperty.all(0)),
                    child: Row(
                      children: [
                        Image.asset(
                          Res.ic_user,
                          width: 24,
                          height: 25,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 14,
                          ),
                          child: Text(
                            "Home",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/order");
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        elevation: MaterialStateProperty.all(0)),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Image.asset(
                            Res.ic_rider,
                            width: 24,
                            height: 25,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 6,
                          ),
                          child: Text(
                            "Active Orders",
                            style: TextStyle(
                                fontFamily: AppConstant.fontRegular,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                      elevation: MaterialStateProperty.all(0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        Res.ic_my_profile,
                        width: 25,
                        height: 25,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        'My Profile',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: AppConstant.fontBold,
                            fontSize: 16),
                      ),
                      Spacer()
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 12,
                    ),
                    Image.asset(
                      Res.ic_order,
                      width: 25,
                      height: 25,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Orders',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: AppConstant.fontBold,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    CupertinoSwitch(
                      value: _switchValue!,
                      activeColor: AppConstant.lightGreen,
                      onChanged: (value) {
                        updateRiderStatus(value);
                        // _switchValue = value;
                      },
                    ),
                    Spacer(),
                  ],
                ),

                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/orderhistory');
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 14, top: 16),
                        child: Image.asset(
                          Res.ic_order_history,
                          width: 25,
                          height: 25,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 10, top: 16),
                          child: Text(
                            'Order history',
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: AppConstant.fontBold,
                                fontSize: 16),
                          )),
                    ],
                  ),
                ),

                // InkWell(
                //   onTap: () {
                //     Navigator.pushNamed(context, '/customerfeedback');
                //   },
                //   child: Row(
                //     children: [
                //       Padding(
                //         padding: EdgeInsets.only(left: 16, top: 16),
                //         child: Image.asset(
                //           Res.ic_feedback,
                //           width: 25,
                //           height: 25,
                //         ),
                //       ),
                //       Padding(
                //           padding: EdgeInsets.only(left: 20, top: 16),
                //           child: Text(
                //             'Feedback',
                //             style: TextStyle(
                //                 color: Colors.black,
                //                 fontFamily: AppConstant.fontBold,
                //                 fontSize: 16),
                //           )),
                //     ],
                //   ),
                // ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        _ackAlert(context);
                      },
                      child: Container(
                        height: 40,
                        width: 130,
                        decoration: BoxDecoration(
                            color: AppConstant.lightGreen,
                            borderRadius: BorderRadius.circular(60)),
                        margin: EdgeInsets.only(top: 30, bottom: 16),
                        child: Row(
                          children: [
                            Padding(
                              child: Image.asset(
                                Res.ic_logout,
                                color: Colors.white,
                                width: 25,
                                height: 25,
                              ),
                              padding: EdgeInsets.only(left: 10),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  'LOGOUT',
                                  style: TextStyle(
                                      fontFamily: AppConstant.fontBold,
                                      fontSize: 12,
                                      color: Colors.white),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> updateRiderStatus(value) async {
    progressDialog!.show();
    String? sessionId = await getSessionId();
    bool? riderStatus = await getRiderStatus();
    try {
      var user = await Utils.getUser();
      FormData form = FormData.fromMap({
        "token": "123456789",
        "status": value ? "1" : "0",
        "user_id": user.data!.userId,
        "session_id": sessionId
      });
      RiderStatus? bean = await ApiProvider().updateRiderAvailability(form);
      if (bean!.status == true) {
        progressDialog!.dismiss();
        Utils.showToast(bean.message ?? "");
        setState(() {
          saveRiderStatus(value);
          saveSessionId(bean.data!);
          _switchValue = value;
          isRiderActive = value;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
      } else {
        progressDialog!.dismiss();
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

  Future<void> _ackAlert(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Logout!'),
        content: const Text('Are you sure want to logout'),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () {
              saveLogin(false);
              PrefManager.clear();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/loginSignUp', (Route<dynamic> route) => false);
            },
          )
        ],
      ),
    );
  }
}
