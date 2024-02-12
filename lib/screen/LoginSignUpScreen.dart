import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/model/BeanLogin.dart';
import 'package:rider_app/model/BeanSignUp.dart';
import 'package:rider_app/model/getCureentOrders.dart';
import 'package:rider_app/network/ApiProvider.dart';
import 'package:rider_app/screen/OrderScreen.dart';
import 'package:rider_app/screen/StartDeliveryScreen.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/PrefManager.dart';
import 'package:rider_app/utils/Utils.dart';
import 'package:rider_app/utils/progress_dialog.dart';
import '../res.dart';

class LoginSignUpScreen extends StatefulWidget {
  @override
  _LoginSignUpScreenState createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen>
    with SingleTickerProviderStateMixin {
  String order_id = '';
  String order_items_id = '';
  String deliveryAddress = '';
  String kitchenNumber = '';
  String customerNumber = '';
  bool acceptedOrders = false;
  TabController? _controller;
  List state = [];
  List city = [];
  String? state_id;
  String? city_id;
  String? deliveryTime;

  var focusNode = FocusNode();
  var _Name = TextEditingController();
  var Contact_Number = TextEditingController();
  String City = "";
  var LicenseNo = TextEditingController();
  var ExpiryDate = TextEditingController();
  var Email = TextEditingController();
  var PanCard = TextEditingController();
  var GstRegister = TextEditingController();
  final RiderId = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool selected = false;
  File? _image;
  File? _idProof;
  File? _passport;
  File? _bikeRc;
  File? license;
  File? _uploadimage;
  int _radioValue = -1;
  int _license = -1;
  var type = "";
  var menuFile = "";
  var document = "";
  ProgressDialog? _progressDialog;
  bool? _passwordVisible;
  bool isTermAccepted = false;

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value!;
      switch (_radioValue) {
        case 0:
          setState(() {});
          break;

        case 1:
          setState(() {});
          break;
      }
    });
  }

  void _handleLicenseValueChange(int? value) {
    setState(() {
      _license = value!;
      switch (_license) {
        case 0:
          setState(() {});
          break;

        case 1:
          setState(() {});
          break;
      }
    });
  }

  final ImagePicker _picker = ImagePicker();

  _imgFromCamera(documenttype) async {
    XFile? file =
        await (_picker.pickImage(source: ImageSource.camera, imageQuality: 50));

    setState(() {
      if (documenttype == 'rc') {
        _bikeRc = File(file!.path);
      } else if (documenttype == 'license') {
        license = File(file!.path);
      } else if (documenttype == 'passport') {
        _passport = File(file!.path);
      } else if (documenttype == 'proof') {
        _idProof = File(file!.path);
      }
    });

    // XFile image = await ImagePicker.pickImage(
    //     source: ImageSource.camera, imageQuality: 50);
    // setState(() {
    //   _image = image;
    // });
  }

  _imgFromGallery(documenttype) async {
    XFile? file = await (_picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50));

    setState(() {
      if (documenttype == 'rc') {
        _bikeRc = File(file!.path);
      } else if (documenttype == 'license') {
        license = File(file!.path);
      } else if (documenttype == 'passport') {
        _passport = File(file!.path);
      } else if (documenttype == 'proof') {
        _idProof = File(file!.path);
      }
    });
    // XFile image = await ImagePicker.pickImage(
    //     source: ImageSource.gallery, imageQuality: 50);
    // setState(() {
    //   _image = image;
    // });
  }

  _uploadImgFromCamera() async {
    XFile? uploadimage =
        await (_picker.pickImage(source: ImageSource.camera, imageQuality: 50));

    setState(() {
      _uploadimage = File(uploadimage!.path);
    });

    // File uploadimage = await ImagePicker.pickImage(
    //     source: ImageSource.camera, imageQuality: 50);
    // setState(() {
    //   _uploadimage = uploadimage;
    // });
  }

  _uploadimgFromGallery() async {
    XFile? uploadimage = await (_picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50));

    setState(() {
      _uploadimage = File(uploadimage!.path);
    });

    // File uploadimage = await ImagePicker.pickImage(
    //     source: ImageSource.gallery, imageQuality: 50);
    // setState(() {
    //   _uploadimage = uploadimage;
    // });
  }

  FormData from = FormData.fromMap({'token': '123456789'});

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();

    ApiProvider().getState(from).then((value) {
      setState(() {
        state = value['data'];
      });
    });
    setState(() {
      selected = !selected;
    });
    _controller = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = ProgressDialog(context);
    return Scaffold(
      body: Column(
        children: [
          new Container(
            height: 180,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/ic_bg_login.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 125,
            child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          child: Container(
                            child: TabBar(
                              unselectedLabelColor: Colors.grey,
                              labelColor: Colors.black,
                              indicatorColor: Colors.black,
                              indicatorSize: TabBarIndicatorSize.label,
                              isScrollable: true,
                              indicatorPadding: EdgeInsets.all(0),
                              controller: _controller,
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              tabs: [
                                Tab(child: Text("Login")),
                                Tab(child: Text("SignUp")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          ),
          Expanded(
            child: Container(
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  Stack(
                    children: [
                      SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                child: Text(
                                  "Welcome Back,",
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.black,
                                      fontFamily: AppConstant.fontRegular),
                                ),
                                padding: EdgeInsets.only(left: 16, top: 20),
                              ),
                              Padding(
                                child: Text(
                                  "Rider",
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.black,
                                      fontFamily: AppConstant.fontBold),
                                ),
                                padding: EdgeInsets.only(left: 16),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 16, top: 20, right: 16),
                                  child: TextFormField(
                                    controller: RiderId,
                                    cursorColor: Colors.black,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "Enter rider id",
                                      labelStyle: TextStyle(
                                          fontFamily: AppConstant.fontRegular,
                                          color: Colors.black),
                                      fillColor: Colors.black,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black, width: 2.0),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  )),
                              SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 16, bottom: 16),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: !_passwordVisible!,
                                  keyboardType: TextInputType.text,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontFamily: AppConstant.fontRegular),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible!;
                                        });
                                      },
                                      // onLongPressUp: () {
                                      //   setState(() {
                                      //     _passwordVisible = false;
                                      //   });
                                      // },
                                      child: Icon(
                                        _passwordVisible!
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    fillColor: Colors.grey,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2.0),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.bottomLeft,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/forgot');
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 16, left: 16),
                                                child: Text(
                                                  "Forgot password?",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: AppConstant
                                                          .fontRegular),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: GestureDetector(
                                        onTap: () => {validationLogin()},
                                        child: Container(
                                          height: 55,
                                          width: 90,
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
                                              borderRadius:
                                                  BorderRadius.circular(13)),
                                          margin: EdgeInsets.only(
                                              bottom: 16, right: 16),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Center(
                                                child: Image.asset(
                                                    Res.ic_right_arrow,
                                                    width: 20,
                                                    height: 20),
                                              )),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "Enter you basic details here",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: AppConstant.fontBold),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                TextFormField(
                                  focusNode: focusNode,
                                  autofocus: true,
                                  controller: _Name,
                                  validator: (value) {
                                    validateName(value);
                                  },
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    labelText: "Name",
                                    labelStyle: TextStyle(
                                        fontFamily: AppConstant.fontRegular,
                                        color: Colors.black),
                                    fillColor: Colors.black,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2.0),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                TextFormField(
                                  controller: Contact_Number,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    validateMobile(value!);
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Contact Number",
                                    labelStyle: TextStyle(
                                        fontFamily: AppConstant.fontRegular,
                                        color: Colors.black),
                                    fillColor: Colors.grey,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2.0),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                TextFormField(
                                  validator: (value) {
                                    validateEmail(value);
                                  },
                                  onChanged: (val) {
                                    // if(val==""){
                                    //
                                    // }else{
                                    //   ApiProvider().getState(from).then((value) {
                                    //
                                    //     setState(() {
                                    //       state = value['data'];
                                    //     });
                                    //   });
                                    // }
                                  },
                                  controller: Email,
                                  decoration: InputDecoration(
                                    labelText: "Email ID",
                                    labelStyle: TextStyle(
                                        fontFamily: AppConstant.fontRegular,
                                        color: Colors.black),
                                    fillColor: Colors.black,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2.0),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  height: 50,
                                  child: DropdownButton(
                                    isExpanded: true,
                                    items: state.map((item) {
                                      return DropdownMenuItem(
                                        child: Text(item['name']),
                                        value: item['state_id'].toString(),
                                      );
                                    }).toList(),
                                    onChanged: (String? newVal) {
                                      setState(() {
                                        city = [];
                                        state_id = newVal!;
                                        ApiProvider()
                                            .getCity(FormData.fromMap({
                                          'token': '123456789',
                                          'state_id': state_id
                                        }))
                                            .then((value) {
                                          setState(() {
                                            city = value['data'];
                                            city_id = null;
                                          });
                                        });
                                      });
                                    },
                                    value: state_id,
                                    hint: Text('Select State'),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  height: 50,
                                  child: DropdownButton(
                                    isExpanded: true,
                                    items: city.map((item) {
                                      return DropdownMenuItem(
                                        onTap: () {
                                          City = item['name'];
                                        },
                                        child: Text(item['name']),
                                        value: item['city_id'].toString(),
                                      );
                                    }).toList(),
                                    onChanged: (String? newVal) {
                                      setState(() {
                                        city_id = newVal;

                                      });
                                    },
                                    value: city_id,
                                    hint: Text('Select City'),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  "What type of bike you have",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: AppConstant.fontRegular),
                                ),
                                Row(
                                  children: [
                                    new Radio(
                                      value: 0,
                                      groupValue: _radioValue,
                                      activeColor: Color(0xff7EDABF),
                                      onChanged: _handleRadioValueChange,
                                    ),
                                    new Text(
                                      'Regular Bike',
                                      style: new TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontRegular),
                                    ),
                                    new Radio(
                                      value: 1,
                                      groupValue: _radioValue,
                                      activeColor: Color(0xff7EDABF),
                                      onChanged: _handleRadioValueChange,
                                    ),
                                    new Text(
                                      'E-Bike',
                                      style: new TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontRegular),
                                    ),
                                    new Radio(
                                      value: 2,
                                      groupValue: _radioValue,
                                      activeColor: Color(0xff7EDABF),
                                      onChanged: _handleRadioValueChange,
                                    ),
                                    new Text(
                                      'Bicycle',
                                      style: new TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontRegular),
                                    ),
                                  ],
                                ),
                                Padding(
                                  child: Text(
                                    "Do you have licence?",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontFamily: AppConstant.fontRegular),
                                  ),
                                  padding: EdgeInsets.only(left: 16, top: 10),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    new Radio(
                                      value: 0,
                                      groupValue: _license,
                                      activeColor: Color(0xff7EDABF),
                                      onChanged: _handleLicenseValueChange,
                                    ),
                                    new Text(
                                      'Yes',
                                      style: new TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontRegular),
                                    ),
                                    new Radio(
                                      value: 1,
                                      groupValue: _license,
                                      activeColor: Color(0xff7EDABF),
                                      onChanged: _handleLicenseValueChange,
                                    ),
                                    new Text(
                                      'No',
                                      style: new TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppConstant.fontRegular),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Attach License',
                                          style: new TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  AppConstant.fontRegular),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 0, right: 0),
                                          child: new ListTile(
                                              iconColor: license != null
                                                  ? Colors.blue
                                                  : Colors.black,
                                              leading:
                                                  new Icon(Icons.photo_library),
                                              title: new Text('UPLOAD'),
                                              onTap: () {
                                                _showPicker(context,
                                                    'license'); //license rc  proof
                                              }),
                                        ),
                                      ),
                                      license != null
                                          ? Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 0, right: 0),
                                                child: Text(
                                                    "${license!.path.split('/').last}"),
                                              ),
                                            )
                                          : Text(""),
                                    ]),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Attach Bike RC',
                                          style: new TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  AppConstant.fontRegular),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 0, right: 0),
                                          child: new ListTile(
                                              iconColor: _bikeRc != null
                                                  ? Colors.blue
                                                  : Colors.black,
                                              leading:
                                                  new Icon(Icons.photo_library),
                                              title: new Text('UPLOAD'),
                                              onTap: () {
                                                _showPicker(context, 'rc');
                                              }),
                                        ),
                                      ),
                                      _bikeRc != null
                                          ? Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 0, right: 0),
                                                child: Text(
                                                    "${_bikeRc!.path.split('/').last}"),
                                              ),
                                            )
                                          : Text(""),
                                    ]),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Attach Passport',
                                          style: new TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  AppConstant.fontRegular),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 0, right: 0),
                                          child: new ListTile(
                                              iconColor: _passport != null
                                                  ? Colors.blue
                                                  : Colors.black,
                                              leading:
                                                  new Icon(Icons.photo_library),
                                              title: new Text('UPLOAD'),
                                              onTap: () {
                                                _showPicker(
                                                    context, 'passport');
                                              }),
                                        ),
                                      ),
                                      _passport != null
                                          ? Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 0, right: 0),
                                                child: Text(
                                                    "${_passport!.path.split('/').last}"),
                                              ),
                                            )
                                          : Text(""),
                                    ]),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Attach ID proof',
                                        style: new TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                AppConstant.fontRegular),
                                      ),
                                    ),
                                    // Column(
                                    //   children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 0, right: 0),
                                        child: new ListTile(
                                            iconColor: _idProof != null
                                                ? Colors.blue
                                                : Colors.black,
                                            leading:
                                                new Icon(Icons.photo_library),
                                            title: new Text('UPLOAD'),
                                            onTap: () {
                                              _showPicker(context, 'proof');
                                            }),
                                      ),
                                    ),
                                    _idProof != null
                                        ? Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 0, right: 0),
                                              child: Text(
                                                  "${_idProof!.path.split('/').last}"),
                                            ),
                                          )
                                        : Text(""),
                                  ],
                                ),
                                // ]),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        value: isTermAccepted,
                                        onChanged: (b) {
                                          setState(() {
                                            isTermAccepted = b ?? false;
                                          });
                                        }),
                                    InkWell(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 15),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.3,
                                        child: const Text(
                                            "By continuing, you are agree to our Terms of Service & Privacy Policy        ",
                                            //maxLines: 3,
                                            //  overflow: TextOverflow.clip,

                                            style: TextStyle(
                                              fontSize: 14,
                                            )),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isTermAccepted = !isTermAccepted;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () {
                                isTermAccepted ? validation() : null;

                                /*  showDetailsVerifyDialog();*/
                              },
                              child: Opacity(
                                opacity: isTermAccepted ? 1.0 : 0.3,
                                child: Container(
                                  height: 55,
                                  width: 90,
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
                                  margin:
                                      EdgeInsets.only(bottom: 16, right: 16),
                                  child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Center(
                                        child: Image.asset(Res.ic_right_arrow,
                                            width: 20, height: 20),
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? validateName(String? value) {
    if (value!.length < 3)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  String? validateMobile(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value!))
      return 'Enter Valid Email';
    else
      return null;
  }

  void showDetailsVerifyDialog(
      String name, String phone, String emailid, String city) {
    showDialog(
        context: context,
        builder: (_) => Center(
                // Aligns the container to center
                child: GestureDetector(
              onTap: () {},
              child: Wrap(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ), // A simplified version of dialog.
                      width: 270.0,
                      height: 280.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              Res.ic_verify,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 16, top: 20, right: 16),
                                child: Text(
                                  "Details verified",
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Colors.black,
                                      fontFamily: AppConstant.fontBold,
                                      fontSize: 18),
                                )),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 16, top: 20, right: 16),
                                child: Text(
                                  "You will get a call from NOHUNG",
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Colors.grey,
                                      fontFamily: AppConstant.fontRegular,
                                      fontSize: 12),
                                )),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(
                                    context, '/loginSignUp');
                              },
                              child: Container(
                                height: 40,
                                width: 120,
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
                                margin: EdgeInsets.only(top: 25),
                                child: Center(
                                    child: Text(
                                  "Ok",
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
                      )),
                ],
              ),
            )));
  }

  void _showPicker(context, documenttype) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery(documenttype);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera(documenttype);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _uploadProfile(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _uploadimgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _uploadImgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void validation() {
    var name = _Name.text.toString();
    var phone = Contact_Number.text.toString();
    var emailid = Email.text.toString();

    if (name.isEmpty) {
      Utils.showToast("Please Enter Name");
    } else if (!RegExp(r'^[a-z A-Z]+$').hasMatch(name)) {
      Utils.showToast("Please Enter Only String in Name");
    } else if (phone.isEmpty) {
      Contact_Number.selection;
      Utils.showToast("Please Enter Number");
    } else if (phone.length != 10) {
      Contact_Number.selection;
      Utils.showToast('Mobile Number must be of 10 digit');
    } else if (emailid.isEmpty) {
      Utils.showToast("Please Enter Email");
    } else if (emailid.isNotEmpty &&
        !RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
            .hasMatch(emailid)) {
      Utils.showToast("Please Enter Valid Email");
    } else if (City == "") {
      Utils.showToast("Please Enter City");
    } else if (license == null) {
      Utils.showToast("Please Attach your License!");
    } else if (_bikeRc == null) {
      Utils.showToast("Please Attach your Bike RC!");
    } else if (_idProof == null) {
      Utils.showToast("Please Attach your ID proof!");
    } else {
      signUp(name, emailid, phone, City);
    }
  }

  Future<BeanSignUp?> signUp(
      String name, String emailid, String phone, String city) async {
    _progressDialog!.show();
    try {
      FormData data = FormData.fromMap({
        "token": "123456789",
        "name": name,
        "mobilenumber": phone,
        "email": emailid,
        "cityid": city_id,
        "stateid": state_id,
        "biketype": _radioValue == 0
            ? "Regular"
            : _radioValue == 1
                ? "E-Bike"
                : _radioValue == 2
                    ? "Bicycle"
                    : "",
        "youhavelicense": _license == 0
            ? "No"
            : _license == 1
                ? "Yes"
                : "",
        "license": license != null
            ? await MultipartFile.fromFile(license!.path,
                filename: license!.path)
            : "",
        "bike_rc": _bikeRc != null
            ? await MultipartFile.fromFile(_bikeRc!.path,
                filename: _bikeRc!.path)
            : "",
        "passport": _passport != null
            ? await MultipartFile.fromFile(_passport!.path,
                filename: _passport!.path)
            : "",
        "id_proof": _idProof != null
            ? await MultipartFile.fromFile(_idProof!.path,
                filename: _idProof!.path)
            : "",
      });
      BeanSignUp bean = await ApiProvider().registerUser(data);
      if (bean.status == true) {
        _progressDialog!.dismiss();
        PrefManager.putBool(AppConstant.session, true);
        PrefManager.putString(AppConstant.user, jsonEncode(bean));
        Utils.showToast(bean.message ?? "");
        showDetailsVerifyDialog(name, phone, emailid, City);
      } else {
        _progressDialog!.dismiss();
        Utils.showToast(bean.message ?? "");
      }
    } on HttpException catch (exception) {
      _progressDialog!.dismiss();
    } catch (exception) {
      _progressDialog!.dismiss();
    }
  }

  validationLogin() {
    var riderId = RiderId.text.toString();
    var password = passwordController.text.toString();
    if (riderId.isEmpty) {
      Utils.showToast("Please Enter Rider Id");
    } else if (password.isEmpty) {
      Utils.showToast("Please Enter Password");
    } else {
      login(riderId, password);
    }
  }

  Future<BeanLogin?> login(String riderId, String password) async {
    _progressDialog!.show();
    try {
      FormData data = FormData.fromMap({
        "token": "123456789",
        "riderid": riderId,
        "password": password,
      });
      BeanLogin bean = await ApiProvider().loginUser(data);
      _progressDialog!.dismiss();
      if (bean.status == true) {
        print("==========-----------=======PIYUSH=>");
        setState(() {
          saveLogin(true);
          saveRiderStatus(true);
          saveSessionId(bean.data!.sessionId!);
        });
        PrefManager.putBool(AppConstant.session, true);
        PrefManager.putString(AppConstant.user, jsonEncode(bean));
        Utils.showToast(bean.message ?? "");
        // Navigator.pushReplacementNamed(context, '/home');
        getCurrentOrders(context);
      } else {
        Utils.showToast(bean.message ?? "");
      }
    } on HttpException catch (exception) {
      _progressDialog!.dismiss();
    } catch (exception) {
      _progressDialog!.dismiss();
    }
  }

  void navigationPage(
      bool acceptedOrder, bool OrderStatus, String orderNumber) async {
    bool? isLogin = await getLogin();

    if (isLogin == true) {
      bool isLogined;
      try {
        isLogined = await PrefManager.getBool(AppConstant.session);
      } catch (e) {
        isLogined = false;
      }
      if (isLogined) {
        if (acceptedOrder) {
          if (OrderStatus) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => OrderScreen(0)));
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => StartDeliveryScreen(
                        deliveryAddress,
                        orderNumber,
                        order_id,
                        order_items_id,
                        customerNumber,
                        kitchenNumber,
                        deliveryTime,
                        0,
                        0)));
          }
        } else
          Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/loginSignUp');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/loginSignUp');
    }
  }

  Future getCurrentOrders(BuildContext context) async {
    try {
      var user = await Utils.getUser();
      FormData from =
          FormData.fromMap({"userid": user.data!.userId, "token": "123456789"});
      GetCurrentOrdersModel bean = await ApiProvider().getCurrentOrders(from);
      if (bean.status == true) {
        setState(() {
          acceptedOrders = bean.status ?? false;
          order_id = bean.data![0].orderId ?? '';
          order_items_id = bean.data![0].orderitemsId ?? '';
          deliveryAddress = bean.data![0].deliveryaddress ?? '';
          kitchenNumber = bean.data![0].kitchenNumber ?? '';
          customerNumber = bean.data![0].customerNumber ?? '';
          deliveryTime = bean.data![0].deliveryTime ?? '';
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => OrderScreen(0)));

        return bean;
      } else {
        setState(() {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => OrderScreen(0)));
        });
      }

      return null;
    } on HttpException catch (exception) {
      print(exception);
    } on FormatException catch (e) {
    } catch (exception) {
      print(exception);
    }
  }
}
