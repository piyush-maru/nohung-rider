class BeanTripSummary {
  bool? status;
  String? message;
  List<Data>? data;

  BeanTripSummary({this.status, this.message, this.data});

  BeanTripSummary.fromJson(Map<String, dynamic> json) {
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
  dynamic deliveryDuration;
  dynamic tripEarning;
  dynamic pointGained;
  dynamic earningsToday;

  Data(
      {this.deliveryDuration,
      this.tripEarning,
      this.pointGained,
      this.earningsToday});

  Data.fromJson(Map<String, dynamic> json) {
    deliveryDuration = json['delivery_duration'];
    tripEarning = json['trip_earning'];
    pointGained = json['point_gained'];
    earningsToday = json['earnings_today'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['delivery_duration'] = this.deliveryDuration;
    data['trip_earning'] = this.tripEarning;
    data['point_gained'] = this.pointGained;
    data['earnings_today'] = this.earningsToday;
    return data;
  }
}
