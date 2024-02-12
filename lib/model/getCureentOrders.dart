// To parse this JSON data, do
//
//     final getCurrentOrdersModel = getCurrentOrdersModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

GetCurrentOrdersModel getCurrentOrdersModelFromJson(String str) =>
    GetCurrentOrdersModel.fromJson(json.decode(str));

String getCurrentOrdersModelToJson(GetCurrentOrdersModel data) =>
    json.encode(data.toJson());

class GetCurrentOrdersModel {
  bool? status;
  String? message;
  List<AcceptedData>? data;

  GetCurrentOrdersModel({this.status, this.message, this.data});

  GetCurrentOrdersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new AcceptedData.fromJson(v));
      });
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    } else {
      data['data'] = this.data;
    }
    return data;
  }
}

class AcceptedData {
  AcceptedData(
      {@required this.orderId,
      @required this.orderitemsId,
      @required this.orderNumber,
      @required this.customerNumber,
      @required this.kitchenNumber,
      @required this.status,
      @required this.deliveryaddress,
      @required this.deliveryTime,
      @required this.reAssigned});

  final String? orderId;
  final String? orderitemsId;
  final String? orderNumber;
  final String? kitchenNumber;
  final String? customerNumber;
  final String? status;
  final String? deliveryaddress;
  final String? deliveryTime;
  final String? reAssigned;
  factory AcceptedData.fromJson(Map<String, dynamic> json) => AcceptedData(
      orderId: json["order_id"],
      orderitemsId: json["orderitems_id"],
      orderNumber: json["ordernumber"],
      customerNumber: json['customernumber'],
      kitchenNumber: json['kitchennumber'],
      status: json["status"],
      deliveryaddress: json["deliveryaddress"],
      deliveryTime: json['deliverytime'],
      reAssigned: json['reassigned']);

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "orderitems_id": orderitemsId,
        "ordernumber": orderNumber,
        "customernumber": customerNumber,
        "kitchennumber": kitchenNumber,
        "status": status,
        "deliveryaddress": deliveryaddress,
        "deliverytime": deliveryTime,
        "reassigned": reAssigned
      };
}
