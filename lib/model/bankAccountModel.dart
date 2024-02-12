// To parse this JSON data, do
//
//     final bankAccountsModel = bankAccountsModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

BankAccountsModel bankAccountsModelFromJson(String str) =>
    BankAccountsModel.fromJson(json.decode(str));

String bankAccountsModelToJson(BankAccountsModel data) =>
    json.encode(data.toJson());

class BankAccountsModel {
  BankAccountsModel({
    @required this.status,
    @required this.message,
    @required this.data,
  });

  bool? status;
  String? message;
  List<Datum>? data;

  factory BankAccountsModel.fromJson(Map<String, dynamic> json) =>
      BankAccountsModel(
        status: json["status"]==null ? false: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    @required this.accountId,
    @required this.accountName,
    @required this.bankName,
    @required this.ifscCode,
    @required this.accountNumber,
    @required this.createddate,
  });

  String? accountId;
  String? accountName;
  String? bankName;
  String? ifscCode;
  String? accountNumber;
  String? createddate;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        accountId: json["account_id"],
        accountName: json["account_name"],
        bankName: json["bank_name"],
        ifscCode: json["ifsc_code"],
        accountNumber: json["account_number"],
        createddate: json["createddate"],
      );

  Map<String, dynamic> toJson() => {
        "account_id": accountId,
        "account_name": accountName,
        "bank_name": bankName,
        "ifsc_code": ifscCode,
        "account_number": accountNumber,
        "createddate": createddate,
      };
}
