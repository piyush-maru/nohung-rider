class GetCustomerFeedback {
  bool? status;
  String? message;
  List<Data>? data;

  GetCustomerFeedback({this.status, this.message, this.data});

  GetCustomerFeedback.fromJson(Map<String, dynamic> json) {
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
  String? improveId;
  String? option;

  Data({this.improveId, this.option});

  Data.fromJson(Map<String, dynamic> json) {
    improveId = json['improve_id'];
    option = json['option'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['improve_id'] = this.improveId;
    data['option'] = this.option;
    return data;
  }
}