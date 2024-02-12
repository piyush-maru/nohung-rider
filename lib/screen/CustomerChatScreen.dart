import 'package:flutter/material.dart';
import 'package:rider_app/helper/global_object.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';

import '../res.dart';

class CustomerChatScreen extends StatefulWidget {
  @override
  _CustomerChatScreenState createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  var type = "";
  Future? future;
  ScrollController messageController = ScrollController();

  var _msg = TextEditingController();

  ProgressDialog? progressDialog;

  ValueNotifier<bool> isApiCalling = ValueNotifier(false);

  void getData() {
    setState(() {});
    chatRepo.getChatMessage();
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: AppConstant.lightGreen,
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        InkWell(
                            onTap: () {},
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Image.asset(
                                  Res.ic_back,
                                  width: 30,
                                  height: 30,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 16,
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Image.asset(
                              Res.ic_user,
                              width: 50,
                              height: 50,
                            )),
                        Padding(
                          child: Text(
                            "Admin",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: AppConstant.fontBold,
                                fontSize: 20),
                          ),
                          padding: EdgeInsets.only(top: 20, left: 16),
                        ),
                      ],
                    ),
                    height: 100,
                  ),
                  Expanded(
                      child: ValueListenableBuilder(
                          valueListenable: chatRepo.getChatModel,
                          builder: (context, k, d) {
                            return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                reverse: false,
                                shrinkWrap: true,
                                controller: messageController,
                                itemCount: chatRepo.getChatModel.value.length,
                                itemBuilder: (context, i) {
                                  return Container(
                                      margin: EdgeInsets.only(top: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          chatRepo.getChatModel.value[i]
                                                      .msgType ==
                                                  "sent"
                                              ? Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                      width: 100,
                                                      margin: EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          top: 16,
                                                          bottom: 16),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xffBEE8FF),
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10))),
                                                      child: Column(
                                                        children: [
                                                          Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 16,
                                                                      top: 16,
                                                                      right: 16,
                                                                      bottom:
                                                                          16),
                                                              child: Text(
                                                                "${chatRepo.getChatModel.value[i].message}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                )
                                              : Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Container(
                                                      width: 100,
                                                      margin: EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          top: 16,
                                                          bottom: 16),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xffF3F6FA),
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10))),
                                                      child: Column(
                                                        children: [
                                                          Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 16,
                                                                      top: 16,
                                                                      right: 16,
                                                                      bottom:
                                                                          16),
                                                              child: Text(
                                                                "${chatRepo.getChatModel.value[i].message}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                        ],
                                      ));
                                });
                          }))
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    alignment: Alignment.bottomCenter,
                    height: 50,
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    decoration: BoxDecoration(
                        color: Color(0xffF3F6FA),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 10),
                            child: TextField(
                              controller: _msg,
                              decoration: InputDecoration.collapsed(
                                  hintText: "Write message"),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: isApiCalling,
                            builder: (context, v, c) {
                              return isApiCalling.value == true
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          right: 16, bottom: 16, top: 8),
                                      child: Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.purple,
                                          )),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        validation();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 16, bottom: 16, top: 8),
                                        child: Image.asset(
                                          Res.ic_send,
                                          width: 50,
                                          height: 50,
                                        ),
                                      ),
                                    );
                            })
                      ],
                    )),
              ),
            ),
          ],
        ));
  }

  void validation() async {
    var messageInput = _msg.text.toString();
    if (messageInput.isEmpty) {
      Utils.showToast("Please Enter Message");
    } else {
      isApiCalling.value = true;
      bool result = await chatRepo.sendMessage(messageInput);

      if (result) {
        messageInput = _msg.text = "";
        Utils.showToast("Message Sent.");
        bool res = await chatRepo.getChatMessage();
        if (res) {
          isApiCalling.value = false;
        } else {
          isApiCalling.value = false;
        }
      } else {
        isApiCalling.value = false;
        Utils.showToast("Some thing Went Wrong.");
      }
    }
  }
}
