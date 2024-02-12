class BeanLogin {
  bool? status;
  String? message;
  Data? data;

  BeanLogin({this.status, this.message, this.data});

  BeanLogin.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    data = json['data'] != null
        ? !(json['data'] is List)
            ? new Data.fromJson(json['data'])
            : null
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  String? usertype;
  String? kitchenname;
  String? email;
  String? kitchenid;
  String? riderid;
  String? password;
  String? address;
  String? stateid;
  String? cityid;
  String? pincode;
  String? contactname;
  String? role;
  String? mobilenumber;
  String? kitchencontactnumber;
  String? fssailicenceno;
  String? expirydate;
  String? panno;
  String? gstno;
  String? menufile;
  String? firmtype;
  String? foodtype;
  String? fromtime;
  String? totime;
  String? opendays;
  String? mealtype;
  String? otpcode;
  String? isverifiedotp;
  String? otpdate;
  String? isagreeforpolicy;
  String? city;
  String? biketype;
  String? youhavelicense;
  String? licencefile;
  String? rcbookfile;
  String? passportfile;
  String? idprooffile;
  String? wallet;
  String? latitude;
  String? longitude;
  String? userstatus;
  String? status;
  String? createddate;
  String? modifieddate;
  String? sessionId;

  Data(
      {this.id,
      this.usertype,
      this.kitchenname,
      this.email,
      this.kitchenid,
      this.riderid,
      this.password,
      this.address,
      this.stateid,
      this.cityid,
      this.pincode,
      this.contactname,
      this.role,
      this.mobilenumber,
      this.kitchencontactnumber,
      this.fssailicenceno,
      this.expirydate,
      this.panno,
      this.gstno,
      this.menufile,
      this.firmtype,
      this.foodtype,
      this.fromtime,
      this.totime,
      this.opendays,
      this.mealtype,
      this.otpcode,
      this.isverifiedotp,
      this.otpdate,
      this.isagreeforpolicy,
      this.city,
      this.biketype,
      this.youhavelicense,
      this.licencefile,
      this.rcbookfile,
      this.passportfile,
      this.idprooffile,
      this.wallet,
      this.latitude,
      this.longitude,
      this.userstatus,
      this.status,
      this.createddate,
      this.modifieddate,
      this.sessionId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    usertype = json['usertype'];
    kitchenname = json['kitchenname'];
    email = json['email'];
    kitchenid = json['kitchenid'];
    riderid = json['riderid'];
    password = json['password'];
    address = json['address'];
    stateid = json['stateid'];
    cityid = json['cityid'];
    pincode = json['pincode'];
    contactname = json['contactname'];
    role = json['role'];
    mobilenumber = json['mobilenumber'];
    kitchencontactnumber = json['kitchencontactnumber'];
    fssailicenceno = json['fssailicenceno'];
    expirydate = json['expirydate'];
    panno = json['panno'];
    gstno = json['gstno'];
    menufile = json['menufile'];
    firmtype = json['firmtype'];
    foodtype = json['foodtype'];
    fromtime = json['fromtime'];
    totime = json['totime'];
    opendays = json['opendays'];
    mealtype = json['mealtype'];
    otpcode = json['otpcode'];
    isverifiedotp = json['isverifiedotp'];
    otpdate = json['otpdate'];
    isagreeforpolicy = json['isagreeforpolicy'];
    city = json['city'];
    biketype = json['biketype'];
    youhavelicense = json['youhavelicense'];
    licencefile = json['licencefile'];
    rcbookfile = json['rcbookfile'];
    passportfile = json['passportfile'];
    idprooffile = json['idprooffile'];
    wallet = json['wallet'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    userstatus = json['userstatus'];
    status = json['status'];
    createddate = json['createddate'];
    modifieddate = json['modifieddate'];
    sessionId = json['session_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['usertype'] = this.usertype;
    data['kitchenname'] = this.kitchenname;
    data['email'] = this.email;
    data['kitchenid'] = this.kitchenid;
    data['riderid'] = this.riderid;
    data['password'] = this.password;
    data['address'] = this.address;
    data['stateid'] = this.stateid;
    data['cityid'] = this.cityid;
    data['pincode'] = this.pincode;
    data['contactname'] = this.contactname;
    data['role'] = this.role;
    data['mobilenumber'] = this.mobilenumber;
    data['kitchencontactnumber'] = this.kitchencontactnumber;
    data['fssailicenceno'] = this.fssailicenceno;
    data['expirydate'] = this.expirydate;
    data['panno'] = this.panno;
    data['gstno'] = this.gstno;
    data['menufile'] = this.menufile;
    data['firmtype'] = this.firmtype;
    data['foodtype'] = this.foodtype;
    data['fromtime'] = this.fromtime;
    data['totime'] = this.totime;
    data['opendays'] = this.opendays;
    data['mealtype'] = this.mealtype;
    data['otpcode'] = this.otpcode;
    data['isverifiedotp'] = this.isverifiedotp;
    data['otpdate'] = this.otpdate;
    data['isagreeforpolicy'] = this.isagreeforpolicy;
    data['city'] = this.city;
    data['biketype'] = this.biketype;
    data['youhavelicense'] = this.youhavelicense;
    data['licencefile'] = this.licencefile;
    data['rcbookfile'] = this.rcbookfile;
    data['passportfile'] = this.passportfile;
    data['idprooffile'] = this.idprooffile;
    data['wallet'] = this.wallet;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['userstatus'] = this.userstatus;
    data['status'] = this.status;
    data['createddate'] = this.createddate;
    data['modifieddate'] = this.modifieddate;
    data['session_id'] = this.sessionId;
    return data;
  }
}
