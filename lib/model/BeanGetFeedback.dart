class BeanGetFeedback {
  bool? status;
  String? message;
  List<Data>? data;

  BeanGetFeedback({this.status, this.message, this.data});

  BeanGetFeedback.fromJson(Map<String, dynamic> json) {
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
  String? userName;
  String? ratting;
  String? reviewDescription;
  String? time;

  Data({this.userName, this.ratting, this.reviewDescription, this.time});

  Data.fromJson(Map<String, dynamic> json) {
    userName = json['user_name'];
    ratting = json['ratting'];
    reviewDescription = json['review_description'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_name'] = this.userName;
    data['ratting'] = this.ratting;
    data['review_description'] = this.reviewDescription;
    data['time'] = this.time;
    return data;
  }
}