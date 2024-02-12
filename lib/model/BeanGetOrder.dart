class BeanGetOrder {
  bool? status;
  String? message;
  Global? global;
  List<Data>? data;

  BeanGetOrder({this.status, this.message, this.global, this.data});

  BeanGetOrder.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    global =
        json['global'] != null ? new Global.fromJson(json['global']) : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.global != null) {
      data['global'] = this.global!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Global {
  int? tripDistance;
  int? expectedEarnings;

  Global({this.tripDistance, this.expectedEarnings});

  Global.fromJson(Map<String, dynamic> json) {
    tripDistance = json['trip_distance'];
    expectedEarnings = json['expected_earnings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trip_distance'] = this.tripDistance;
    data['expected_earnings'] = this.expectedEarnings;
    return data;
  }
}

class Data {
  String? orderId;
  String? orderItemsId;
  String? orderType;
  String? orderNumber;
  String? kitchenName;
  String? kitchenAddress;
  String? pickTime;
  String? deliveryTime;
  String? deliveryAddress;
  String? status;
  String? deliveryLat;
  String? deliveryLong;
  String? pickDistance;
  String? delDistance;
  String? deliveryDate;

  Data(
      {this.orderId,
      this.kitchenName,
      this.kitchenAddress,
      this.orderType,
      this.orderItemsId,
      this.orderNumber,
      this.deliveryTime,
      this.pickTime,
      this.deliveryAddress,
      this.deliveryLat,
      this.deliveryLong,
      this.pickDistance,
      this.delDistance,
      this.status,
      this.deliveryDate});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['orderid'];
    orderItemsId = json['orderitems_id'];
    orderType = json['ordertype'];
    orderNumber = json['ordernumber'];
    kitchenName = json['kitchenname'];
    kitchenAddress = json['kitchen_address'];
    deliveryTime = json['deliverytime'];
    pickTime = json['picktime'];
    deliveryAddress = json['deliveryaddress'];
    status = json['status'];
    deliveryLat = json['deliverylatitude'];
    deliveryLong = json['deliverylongitude'];
    pickDistance = json['pickdistance'];
    delDistance = json['deldistance'];
    deliveryDate = json['delivery_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderid'] = this.orderId;
    data['orderitems_id'] = this.orderItemsId;
    data['ordertype'] = this.orderType;
    data['ordernumber'] = this.orderNumber;
    data['kitchenname'] = this.kitchenName;
    data['kitchen_address'] = this.kitchenAddress;
    data['deliverytime'] = this.deliveryTime;
    data['picktime'] = this.pickTime;
    data['deliveryaddress'] = this.deliveryAddress;
    data['status'] = this.status;
    data['deliverylatitude'] = this.deliveryLat;
    data['deliverylongitude'] = this.deliveryLong;
    data['pickdistance'] = this.pickDistance;
    data['deldistance'] = this.delDistance;
    data['delivery_date'] = this.deliveryDate;
    return data;
  }
}
