import 'package:rider_app/model/BeanGetFeedback.dart';

class BeanSendFeedback {
  bool? status;
  String? message;
  List<Data>? data;

  BeanSendFeedback({this.status, this.message, this.data});

  BeanSendFeedback.fromJson(Map<String, dynamic> json) {
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