class GetProfile {
  bool? status;
  String? message;
  List<Data>? data;

  GetProfile({this.status, this.message, this.data});

  GetProfile.fromJson(Map<String, dynamic> json) {
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
  String? username;
  int? avgRatings;
  String? riderId;
  String? mobileNumber;
  String? status;
  String? acceptenceStatus;
  String? address;
  int? totalEarning;

  Data(
      {this.username,
      this.avgRatings,
      this.riderId,
      this.mobileNumber,
      this.address,
      this.status,
      this.acceptenceStatus,
      this.totalEarning});

  Data.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    avgRatings = json['avg_rattings'];
    mobileNumber = json['mobilenumber'];
    riderId = json['riderid'];
    status = json['status'];
    acceptenceStatus = json['userstatus'];
    address = json['address'];
    totalEarning = json['total_earning'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['avg_rattings'] = this.avgRatings;
    data['riderid'] = this.riderId;
    data['mobilenumber'] = this.mobileNumber;
    data['address'] = this.address;
    data['status'] = this.status;
    data['userstatus'] = this.acceptenceStatus;
    data['total_earning'] = this.totalEarning;
    return data;
  }
}
