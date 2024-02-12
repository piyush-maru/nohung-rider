// class BeanStartDelivery {
//   bool status;
//   String message;
//   List<Data> data;
//
//   BeanStartDelivery({this.status, this.message, this.data});
//
//   BeanStartDelivery.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = new List<Data>();
//       json['data'].forEach((v) {
//         data.add(new Data.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   String rider_latitude;
//   String rider_longitude;
//   String deliverylatitude;
//   String deliverylongitude;
//   String deliveryaddress;
//   String mobilenumber;
//
//   Data(
//       {this.rider_latitude,
//       this.rider_longitude,
//       this.deliverylatitude,
//       this.deliverylongitude,
//       this.deliveryaddress,
//       this.mobilenumber});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     rider_latitude = json['rider_latitude'];
//     rider_longitude = json['rider_longitude'];
//     deliverylatitude = json['deliverylatitude'];
//     deliverylongitude = json['deliverylongitude'];
//     deliveryaddress = json['deliveryaddress'];
//     mobilenumber = json['mobilenumber'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['rider_latitude'] = this.rider_latitude;
//     data['rider_longitude'] = this.rider_longitude;
//     data['deliverylatitude'] = this.deliverylatitude;
//     data['deliverylongitude'] = this.deliverylongitude;
//     data['deliveryaddress'] = this.deliveryaddress;
//     data['mobilenumber'] = this.mobilenumber;
//     return data;
//   }
// }
// To parse this JSON data, do
//
//     final searchKitchenPackageModel = searchKitchenPackageModelFromJson(jsonString);

// To parse this JSON data, do
//
//     final beanStartDelivery = beanStartDeliveryFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

BeanStartDelivery beanStartDeliveryFromJson(String str) =>
    BeanStartDelivery.fromJson(json.decode(str));

String beanStartDeliveryToJson(BeanStartDelivery data) =>
    json.encode(data.toJson());

class BeanStartDelivery {
  BeanStartDelivery({
    this.status,
    this.message,
    this.data,
  });

  bool? status;
  String? message;
  Data? data;

  factory BeanStartDelivery.fromJson(Map<String, dynamic> json) =>
      BeanStartDelivery(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data!.toJson(),
      };
}

class Data {
  Data(
      {@required this.riderLatitude,
      @required this.riderLongitude,
      @required this.deliveryLatitude,
      @required this.deliveryLongitude,
      @required this.deliveryAddress,
      @required this.mobileNumber,
      @required this.status,
      this.kitcheNname,
      this.customerName});

  final String? riderLatitude;
  final String? riderLongitude;
  final String? deliveryLatitude;
  final String? deliveryLongitude;
  final String? deliveryAddress;
  final String? mobileNumber;
  final String? status;
  String? kitcheNname;
  String? customerName;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      riderLatitude: json["rider_latitude"],
      riderLongitude: json["rider_longitude"],
      deliveryLatitude: json["delivery_latitude"],
      deliveryLongitude: json["delivery_longitude"],
      deliveryAddress: json["delivery_address"],
      mobileNumber: json["mobile_number"],
      status: json['status'],
      kitcheNname: json['kitchenname'],
      customerName: json['customername']);

  Map<String, dynamic> toJson() => {
        "rider_latitude": riderLatitude,
        "rider_longitude": riderLongitude,
        "delivery_latitude": deliveryLatitude,
        "delivery_longitude": deliveryLongitude,
        "delivery_address": deliveryAddress,
        "mobile_number": mobileNumber,
        "status": status,
        "kitchenname": kitcheNname,
        "customername": customerName
      };
}
