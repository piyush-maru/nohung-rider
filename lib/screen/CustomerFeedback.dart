import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/model/BeanSendFeedback.dart';
import 'package:rider_app/model/BeanSignUp.dart';
import 'package:rider_app/model/GetCustomerFeedback.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/res.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';

class CustomerFeedback extends StatefulWidget {
  @override
  CustomerFeedbackState createState() => CustomerFeedbackState();
}

class CustomerFeedbackState extends State<CustomerFeedback> {
  var isSelect = -1;
  var isSelectEmoji = -1;
  var isLike = -1;
  Future<GetCustomerFeedback?>? _future;
  var improveId = "";
  ProgressDialog? progressDialog;
  BeanSignUp? userBean;
  var name = "";

  void getUser() async {
    userBean = await Utils.getUser();

    name = userBean!.data!.kitchenname??"";
    setState(() {});
  }

  @override
  void initState() {
    getUser();
    Future.delayed(Duration.zero, () {
      _future = getCustomerFeedBack(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    "Customer Feedback",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: AppConstant.fontBold),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    "You Just Delivered an order!",
                    style: TextStyle(
                        color: AppConstant.lightGreen,
                        fontSize: 16,
                        fontFamily: AppConstant.fontBold),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    "Order ID 123456",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: AppConstant.fontBold),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: AppConstant.fontBold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text("Please rat your experience with customer"),
                ),
                Container(
                  height: 100,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return getItem(choices[index], index);
                    },
                    itemCount: choices.length,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    "Tell us more so we can improve",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: AppConstant.fontBold),
                  ),
                ),
                FutureBuilder<GetCustomerFeedback?>(
                    future: _future,
                    builder: (context, projectSnap) {
                      print(projectSnap);
                      if (projectSnap.connectionState == ConnectionState.done) {
                        var result;
                        if (projectSnap.data != null) {
                          result = projectSnap.data!.data;
                          if (result != null) {
                            print(result.length);
                            return Container(
                              height: 150,
                              child: GridView.count(
                                childAspectRatio: (2 / 1.20),
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 0,
                                crossAxisCount: 3,
                                children: List.generate(result.length, (index) {
                                  return getFeedback(result[index], index);
                                }),
                              ),
                            );
                          }
                        }
                      }
                      return Container(
                          child: Center(
                        child: Text(
                          "No Feedback Available",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: AppConstant.fontBold),
                        ),
                      ));
                    }),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 10),
                  child: Text(
                    "Tip received from customer? ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: AppConstant.fontBold),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          isLike = 0;
                        });
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Image.asset(
                              Res.ic_like,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                  color:
                                      isLike == 0 ? Colors.black : Colors.grey,
                                  fontSize: 15,
                                  fontFamily: AppConstant.fontBold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isLike = 1;
                        });
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Image.asset(
                              Res.ic_unlike,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              "NO",
                              style: TextStyle(
                                  color:
                                      isLike == 1 ? Colors.black : Colors.grey,
                                  fontSize: 15,
                                  fontFamily: AppConstant.fontBold),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      validatin();
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
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
                          borderRadius: BorderRadius.circular(13)),
                      margin: EdgeInsets.only(
                          top: 25, left: 16, right: 16, bottom: 16),
                      child: Center(
                          child: Text(
                        "SUBMIT",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: AppConstant.fontBold,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget getItem(Choice choic, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelectEmoji = index;
        });
      },
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: isSelectEmoji == index
            ? Image.asset(
                choic.selectImage??'',
                width: 50,
                height: 50,
              )
            : Image.asset(
                choic.image??"",
                width: 50,
                height: 50,
              ),
      ),
    );
  }

  Future<GetCustomerFeedback?> getCustomerFeedBack(BuildContext context) async {
    progressDialog!.show();
    try {
      FormData from = FormData.fromMap({
        "token": "123456789",
      });
      GetCustomerFeedback bean = await ApiProvider().getCustomerFeedback(from);
      print(bean.data);
      progressDialog!.dismiss();
      if (bean.status == true) {
        setState(() {});
        return bean;
      } else {
        Utils.showToast(bean.message??"");
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

  Widget getFeedback(result, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelect = index;
          improveId = result.improveId;
        });
      },
      child: Container(
        height: 40,
        margin: EdgeInsets.only(left: 10, top: 16, right: 10),
        decoration: BoxDecoration(
            color:
                isSelect == index ? AppConstant.lightGreen : Color(0xffF3F6FA),
            borderRadius: BorderRadius.circular(100)),
        child: Center(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                result.option,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: isSelect == index ? Colors.white : Colors.black,
                    fontFamily: AppConstant.fontRegular),
              )),
        ),
      ),
    );
  }

  Future<BeanSendFeedback?> sendFeedback() async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData data = FormData.fromMap({
        "token": "123456789",
        "riderid": user.data!.userId.toString(),
        "customerid": "15",
        "orderid": "1",
        "rate": isSelectEmoji == 0
            ? "Average"
            : isSelectEmoji == 1
                ? "Poor"
                : isSelectEmoji == 2
                    ? "Good"
                    : isSelectEmoji == 3
                        ? "Excellent"
                        : "",
        "improveid": improveId,
        "tip_received": isSelect == 0
            ? "Yes"
            : isLike == 1
                ? "No"
                : "",
      });
      BeanSendFeedback bean = await ApiProvider().sendFeedback(data);
      progressDialog!.dismiss();
      if (bean.status == true) {
        Utils.showToast(bean.message??"");
        Navigator.pushNamed(context, '/feedback');
      } else {
        Utils.showToast(bean.message??"");
      }
    } on HttpException catch (exception) {
      progressDialog!.dismiss();
    } catch (exception) {
      progressDialog!.dismiss();
    }
  }

  void validatin() {
    if (isSelectEmoji == -1) {
      Utils.showToast("Please select rating");
    } else if (isSelect == -1) {
      Utils.showToast("Please select Improvement");
    } else {
      sendFeedback();
    }
  }
}

class Choice {
  Choice({this.image, this.selectImage});

  String? image;
  String? selectImage;
}

List<Choice> choices = <Choice>[
  Choice(image: Res.ic_emoji_one, selectImage: Res.ic_emoji_one_color),
  Choice(image: Res.ic_emoji_two, selectImage: Res.ic_emoji_two_color),
  Choice(image: Res.ic_emoi_four, selectImage: Res.ic_emoji_colo_four),
  Choice(image: Res.ic_emoji_grey_five, selectImage: Res.ic_emoji_five),
];
