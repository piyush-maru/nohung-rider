import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/model/BeanWithdrawpayment.dart';
import 'package:rider_app/model/GetOrdeHistory.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/res.dart';
import 'package:rider_app/screen/FilterScreen.dart';
import 'package:rider_app/screen/MyDrawer.dart';
import 'package:rider_app/screen/ViewAcceptedOrderScreen.dart';
import 'package:rider_app/utils/HttpException.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';

import '../utils/Constents.dart';

class OrderHistoryscreen extends StatefulWidget {
  var startDate;
  var endDate;
  var status;
  var filter;
  OrderHistoryscreen(this.startDate, this.endDate, this.status, this.filter);

  @override
  _OrderHistoryscreenState createState() => _OrderHistoryscreenState();
}

class _OrderHistoryscreenState extends State<OrderHistoryscreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ProgressDialog? progressDialog;
  Future<GetOrderHistory?>? future;
  var expectedEarning = "";
  var currentOrder = "";
  var Cancelled = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      future = getOrderHistory(context);
    });

    super.initState();
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration.zero, () {
      setState(() {
        future = getOrderHistory(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawers(),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _pullRefresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _scaffoldKey.currentState!.openDrawer();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 16, top: 50),
                      child: Image.asset(
                        Res.ic_menu,
                        width: 30,
                        height: 30,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 50),
                      child: Text(
                        "Order History",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: AppConstant.fontBold),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      addFilter();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 50, right: 16),
                      child: Image.asset(
                        Res.ic_filter,
                        width: 30,
                        height: 30,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                  height: 180,
                  child: Center(
                    child: Image.asset(
                      Res.ic_default_oder,
                    ),
                  )),
              Row(
                children: [
                  // Expanded(
                  //   child: Padding(
                  //     padding: EdgeInsets.only(left: 16, top: 16),
                  //     child: Text(
                  //       "Expected Earning",
                  //       style: TextStyle(
                  //           color: Colors.black,
                  //           fontSize: 14,
                  //           fontFamily: AppConstant.fontRegular),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text(
                      "Current Orders",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: AppConstant.fontRegular),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: Text(
                      currentOrder,
                      style: TextStyle(
                          color: AppConstant.appColor,
                          fontSize: 14,
                          fontFamily: AppConstant.fontRegular),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text(
                      "Cancelled",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: AppConstant.fontRegular),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: Text(
                      Cancelled,
                      style: TextStyle(
                          color: AppConstant.appColor,
                          fontSize: 14,
                          fontFamily: AppConstant.fontRegular),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Divider(
                color: Colors.grey,
              ),
              FutureBuilder<GetOrderHistory?>(
                  future: future,
                  builder: (context, projectSnap) {
                    if (projectSnap.connectionState == ConnectionState.done) {
                      var result;
                      if (projectSnap.data != null) {
                        result = projectSnap.data!.data;
                        if (result != null) {
                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return getItem(result[index]);
                            },
                            itemCount: result.length,
                          );
                        }
                      }
                    }
                    return Container(
                        child: Center(
                      child: Text(
                        "No Order History",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: AppConstant.fontBold),
                      ),
                    ));
                  }),
            ],
          ),
          physics: AlwaysScrollableScrollPhysics(),
        ),
      ),
    );
  }

  Widget getItem(Data result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewAcceptedOrderScreen(result.id,
                      result.orderItemId, int.parse(result.isLiveOrder!))),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: int.parse(result.isLiveOrder!) == 1
                  ? Color.fromARGB(255, 158, 158, 158)
                  : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  width: 70,
                  margin: EdgeInsets.only(left: 20, top: 16, right: 20),
                  decoration: BoxDecoration(
                      color: Utils.getOrderStatusColor(result.status ?? ""),
                      borderRadius: BorderRadius.circular(3)),
                  child: Center(
                    child: Text(
                      '${result.status}',
                      style: TextStyle(
                          color: '${result.status}' == "Reject" ||
                                  '${result.status}' == "Rejected" ||
                                  '${result.status}' == "Cancelled" ||
                                  result.status == null
                              ? Colors.white
                              : Colors.black,
                          fontSize: 10),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    int.parse(result.isLiveOrder!) == 1
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 5, right: 16, top: 10, bottom: 10),
                                child: Text(
                                  "Current Active Order",
                                  style: TextStyle(
                                    color: int.parse(result.isLiveOrder!) == 1
                                        ? Colors.red
                                        : Colors.grey,
                                    fontFamily: AppConstant.fontBold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Order By :",
                          style: TextStyle(
                              color: int.parse(result.isLiveOrder!) == 1
                                  ? Colors.white
                                  : Colors.grey,
                              fontFamily: AppConstant.fontRegular),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 16),
                          child: Text(
                            result.orderBy.toString(),
                            style: TextStyle(
                              color: int.parse(result.isLiveOrder!) == 1
                                  ? Colors.white
                                  : Colors.grey,
                              fontFamily: AppConstant.fontBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                        "Ordered Date: ",
                        style: TextStyle(
                            color: int.parse(result.isLiveOrder!) == 1
                                ? Colors.white
                                : Colors.grey,
                            fontFamily: AppConstant.fontRegular),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5, top: 5, right: 16),
                        child: Text(
                          "${result.date.toString()}",
                          style: TextStyle(
                              color: int.parse(result.isLiveOrder!) == 1
                                  ? Colors.white
                                  : Colors.grey,
                              fontFamily: AppConstant.fontBold),
                        ),
                      ),
                    ]),
                    result.status == "Cancelled"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                                Text(
                                  "Cancelled Time: ",
                                  style: TextStyle(
                                      color: int.parse(result.isLiveOrder!) == 1
                                          ? Colors.white
                                          : Colors.grey,
                                      fontFamily: AppConstant.fontRegular),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 5, top: 5, right: 16),
                                  child: Text(
                                    "${result.cancelledTime.toString()}",
                                    style: TextStyle(
                                        color:
                                            int.parse(result.isLiveOrder!) == 1
                                                ? Colors.white
                                                : Colors.grey,
                                        fontFamily: AppConstant.fontBold),
                                  ),
                                ),
                              ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                                Text(
                                  "${result.status} Time: ",
                                  style: TextStyle(
                                      color: int.parse(result.isLiveOrder!) == 1
                                          ? Colors.white
                                          : Colors.grey,
                                      fontFamily: AppConstant.fontRegular),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 5, top: 5, right: 16),
                                  child: Text(
                                    "${result.deliveredTime.toString()}",
                                    style: TextStyle(
                                        color:
                                            int.parse(result.isLiveOrder!) == 1
                                                ? Colors.white
                                                : Colors.grey,
                                        fontFamily: AppConstant.fontBold),
                                  ),
                                ),
                              ]),
                  ],
                )
              ],
            ),
          ),
        ),
        Divider(
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  Future<BeanWithdrawPayment?> withdrawPayment() async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user.data!.userId.toString(),
        "token": "123456789",
        "amount": "70"
      });
      BeanWithdrawPayment bean = await ApiProvider().acceptOrder(from);
      progressDialog!.dismiss();
      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        setState(() {});

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

  Future<GetOrderHistory?>? getOrderHistory(BuildContext context) async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "userid": user.data!.userId,
        "token": "123456789",
        "date_from": widget.startDate,
        "date_to": widget.endDate,
        "status": widget.status,
      });

      GetOrderHistory bean = await ApiProvider().getOrderHistory(from);
      progressDialog!.dismiss();
      if (bean.status == true) {
        Utils.showToast(bean.message ?? "");
        setState(() {
          Cancelled = bean.global!.cancelled ?? '';
          expectedEarning = bean.global!.expectedEarnings.toString();
          currentOrder = bean.global!.currentOrders.toString();
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

  addFilter() async {
    var resultCardData = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => FilterScreen()));

    if (widget.filter == "filter") {
      future = getOrderHistory(context);
    }
  }
}
