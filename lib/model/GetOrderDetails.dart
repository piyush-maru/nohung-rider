class GetOrderDetails {
  bool? status;
  String? message;
  List<Data>? data;

  GetOrderDetails({this.status, this.message, this.data});

  GetOrderDetails.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  final String? orderid;
  final String? ordernumber;
  final String? pickby;
  final String? deliverytime;
  final String? status;
  final String? deliveryDate;
  final String? kitchenname;
  final String? kitchenAddress;
  final String? kitchenLatitude;
  final String? kitchenLongitude;
  final String? kitchencontactnumber;
  final String? customername;
  final String? customermobilenumber;
  final String? deliveryaddress;
  final String? deliverylongitude;
  final String? deliverylatitude;
  final String? orderdate;
  final String? ordertype;
  final String? deliveredDate;
  final String? orderPickedTime;
  final List<ItemDetail>? itemDetails;
  final String? riderStatus;

  Data({
    this.orderid,
    this.ordernumber,
    this.pickby,
    this.deliverytime,
    this.status,
    this.deliveryDate,
    this.kitchenname,
    this.kitchenAddress,
    this.kitchenLatitude,
    this.kitchenLongitude,
    this.kitchencontactnumber,
    this.customername,
    this.customermobilenumber,
    this.deliveryaddress,
    this.deliverylongitude,
    this.deliverylatitude,
    this.orderdate,
    this.ordertype,
    this.deliveredDate,
    this.orderPickedTime,
    this.itemDetails,
    this.riderStatus,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderid: json["orderid"],
        ordernumber: json["ordernumber"],
        pickby: json["pickby"],
        deliverytime: json["deliverytime"],
        status: json["status"],
        deliveryDate: json["delivery_date"],
        kitchenname: json["kitchenname"],
        kitchenAddress: json["kitchen_address"],
        kitchenLatitude: json["kitchen_latitude"],
        kitchenLongitude: json["kitchen_longitude"],
        kitchencontactnumber: json["kitchencontactnumber"],
        customername: json["customername"],
        customermobilenumber: json["customermobilenumber"],
        deliveryaddress: json["deliveryaddress"],
        deliverylongitude: json["deliverylongitude"],
        deliverylatitude: json["deliverylatitude"],
        orderdate: json["orderdate"],
        ordertype: json["ordertype"],
        deliveredDate: json["delivered_date"],
        orderPickedTime: json["order_picked_time"],
        itemDetails: json["item_details"] == null
            ? []
            : List<ItemDetail>.from(
                json["item_details"]!.map((x) => ItemDetail.fromJson(x))),
        riderStatus: json["rider_status"],
      );

  Map<String, dynamic> toJson() => {
        "orderid": orderid,
        "ordernumber": ordernumber,
        "pickby": pickby,
        "deliverytime": deliverytime,
        "status": status,
        "delivery_date": deliveryDate,
        "kitchenname": kitchenname,
        "kitchen_address": kitchenAddress,
        "kitchen_latitude": kitchenLatitude,
        "kitchen_longitude": kitchenLongitude,
        "kitchencontactnumber": kitchencontactnumber,
        "customername": customername,
        "customermobilenumber": customermobilenumber,
        "deliveryaddress": deliveryaddress,
        "deliverylongitude": deliverylongitude,
        "deliverylatitude": deliverylatitude,
        "orderdate": orderdate,
        "ordertype": ordertype,
        "delivered_date": deliveredDate,
        "order_picked_time": orderPickedTime,
        "item_details": itemDetails == null
            ? []
            : List<dynamic>.from(itemDetails!.map((x) => x.toJson())),
        "rider_status": riderStatus,
      };
}

class ItemDetail {
  final dynamic quantity;
  final String? itemName;

  ItemDetail({
    this.quantity,
    this.itemName,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) => ItemDetail(
        quantity: json["quantity"],
        itemName: json["item_name"],
      );

  Map<String, dynamic> toJson() => {
        "quantity": quantity,
        "item_name": itemName,
      };
}
