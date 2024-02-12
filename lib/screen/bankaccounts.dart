import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/model/bankAccountModel.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/progress_dialog.dart';
import 'package:rider_app/utils/Utils.dart';

class BankAccounts extends StatefulWidget {
  const BankAccounts({
    Key? key,
  }) : super(key: key);

  @override
  _BankAccountsState createState() => _BankAccountsState();
}

class _BankAccountsState extends State<BankAccounts> {
  BankAccountsModel? banks;
  ProgressDialog? progressDialog;
  var id = '';
  var bankName = TextEditingController();
  var accountNumber = TextEditingController();
  var ifscCode = TextEditingController();
  var accountName = TextEditingController();

  void clearControllers() {
    bankName.clear();
    ifscCode.clear();
    accountName.clear();
    accountNumber.clear();
  }

  bool loading = true;
  Future<BankAccountsModel?> getBankAccounts(BuildContext context) async {
    try {
      var user = await Utils.getUser();
      FormData from =
          FormData.fromMap({"user_id": user.data!.userId, "token": "123456789"});
      BankAccountsModel bean = await ApiProvider().getBankAccounts(from);

      if (bean.status!) {
        if (bean.data != null) {
          setState(() {
            banks = bean;
          });
        }

        return bean;
      } else {
        Utils.showToast(bean.message??"");
      }

      return null;
    } on HttpException catch (exception) {
      print(exception);
    } catch (exception) {
      print(exception);
    }
  }

  Future editBank(BuildContext context) async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "token": "123456789",
        "user_id": user.data!.userId,
        "account_id": id,
        "account_name": accountName.text,
        "bank_name": bankName.text,
        "ifsc_code": ifscCode.text,
        "account_number": accountNumber.text
      });
      var bean = await ApiProvider().editBankAccounts(from);
      progressDialog!.dismiss();

      if (bean['status']) {
        if (bean["data"] != null) {
          setState(() {
            Navigator.pop(context);
            getBankAccounts(context);
          });
        }

        return bean;
      } else {
        Utils.showToast(bean["message"]);
      }

      return null;
    } on HttpException catch (exception) {
      print(exception);
      progressDialog!.dismiss();
    } catch (exception) {
      print(exception);
      progressDialog!.dismiss();
    }
  }

  Future DeleteBank(BuildContext context, String id) async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        "token": "123456789",
        "account_id": id,
        "user_id": user.data!.userId,
      });
      var bean = await ApiProvider().deleteBankAccounts(from);
      progressDialog!.dismiss();
      if (bean['status']) {
        if (bean["data"] != null) {
          setState(() {
            getBankAccounts(context);
          });
        }

        return bean;
      } else {
        Utils.showToast(bean["message"]);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBankAccounts(context).then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('My Bank Accounts'),
        centerTitle: true,
        backgroundColor: AppConstant.lightGreen,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addAcountDetail(false);
        },
        child: Icon(Icons.add),
      ),
      body: (loading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : (banks!.status==null)
              ? Center(
                  child: Text('No Bank Details Added'),
                )
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          id = banks!.data![index].accountId??'';
                                          bankName.text =
                                              banks!.data![index].bankName??'';
                                          accountNumber.text =
                                              banks!.data![index].accountNumber??'';
                                          accountName.text =
                                              banks!.data![index].accountName??'';
                                          ifscCode.text =
                                              banks!.data![index].ifscCode??'';
                                          addAcountDetail(true);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          DeleteBank(context,
                                              banks!.data![index].accountId??'');
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text('ACCOUNT NAME')),
                                      Expanded(
                                          child: Text(
                                              banks!.data![index].accountName??''))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text('ACCOUNT NUMBER')),
                                      Expanded(
                                          child: Text(
                                              banks!.data![index].accountNumber??''))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text('BANK NAME')),
                                      Expanded(
                                          child:
                                              Text(banks!.data![index].bankName??''))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text('IFSC CODE')),
                                      Expanded(
                                          child:
                                              Text(banks!.data![index].ifscCode??""))
                                    ],
                                  ),
                                ],
                              ),
                              // Align(
                              //   alignment: Alignment.topRight,
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.end,
                              //     children: [
                              //       IconButton(
                              //         icon: Icon(Icons.edit),
                              //         onPressed: () {},
                              //       ),
                              //       IconButton(
                              //         icon: Icon(Icons.delete),
                              //         onPressed: () {},
                              //       )
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: banks!.data!.length,
                ),
    );
  }

  void addAcountDetail(bool edit) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 6,
            backgroundColor: Colors.transparent,
            child: _dialogWithTextField(context, edit),
          );
        });
  }

  Widget _dialogWithTextField(BuildContext context, bool edit) => Container(
        height: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 16),
              Text(
                (edit)
                    ? "Edit Account Detail".toUpperCase()
                    : "Add Account Detail".toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                  child: TextFormField(
                    maxLines: 1,
                    autofocus: false,
                    controller: accountName,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Account Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 10, right: 15, left: 15),
                  child: TextFormField(
                    maxLines: 1,
                    autofocus: false,
                    controller: bankName,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Bank',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 10, right: 15, left: 15),
                  child: TextFormField(
                    maxLines: 1,
                    controller: ifscCode,
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText: 'IFSC CODE',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 10, right: 15, left: 15),
                  child: TextFormField(
                    maxLines: 1,
                    autofocus: false,
                    controller: accountNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  )),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      clearControllers();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ButtonStyle(
                    shape:MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(108.0),
                    )),
                    backgroundColor: MaterialStateProperty.all(AppConstant.lightGreen)),
                    child: Text(
                      "Save Details".toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      validation(edit);

                      // return Navigator.of(context).pop(true);
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      );

  void validation(bool edit) {
    if (accountName.text.isEmpty) {
      Utils.showToast("Please Enter Account Name");
    } else if (bankName.text.isEmpty) {
      Utils.showToast("Please Enter Bank Name");
    } else if (ifscCode.text.isEmpty) {
      Utils.showToast("Please Enter IFSC Code");
    } else if (accountNumber.text.isEmpty) {
      Utils.showToast("Please Enter Account Number");
    } else {
      (edit) ? editBank(context) : addAccount();
    }
  }

  Future addAccount() async {
    progressDialog!.show();
    try {
      var user = await Utils.getUser();
      FormData from = FormData.fromMap({
        'token': '123456789',
        'user_id': user.data!.userId,
        'account_name': accountName.text.toString(),
        'account_number': accountNumber.text.toString(),
        'bank_name': bankName.text.toString(),
        'ifsc_code': ifscCode.text.toString(),
      });
      var bean = await ApiProvider().addBankAccount(from);

      progressDialog!.dismiss();
      if (bean['status'] == true) {
        Utils.showToast(bean['message']);
        Navigator.pop(context);

        setState(() {});

        return bean;
      } else {
        Utils.showToast(bean['message']);
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
