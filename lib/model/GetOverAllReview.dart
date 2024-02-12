class GetOverAllReview {
  bool? status;
  String? message;
  List<Data>? data;

  GetOverAllReview({this.status, this.message, this.data});

  GetOverAllReview.fromJson(Map<String, dynamic> json) {
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
  int? avgRattings;
  String? totalReview;
  String? excellent;
  String? good;
  String? average;
  String? poor;

  Data(
      {this.avgRattings,
        this.totalReview,
        this.excellent,
        this.good,
        this.average,
        this.poor});

  Data.fromJson(Map<String, dynamic> json) {
    avgRattings = json['avg_rattings'];
    totalReview = json['total_review'];
    excellent = json['excellent'];
    good = json['good'];
    average = json['average'];
    poor = json['poor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avg_rattings'] = this.avgRattings;
    data['total_review'] = this.totalReview;
    data['excellent'] = this.excellent;
    data['good'] = this.good;
    data['average'] = this.average;
    data['poor'] = this.poor;
    return data;
  }
}