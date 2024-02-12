class GetOrderHistory {
  bool? status;
  String? message;
  Global? global;
  List<Data>? data;

  GetOrderHistory({this.status, this.message, this.global, this.data});

  GetOrderHistory.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    global =
        json['global'] != null ? new Global.fromJson(json['global']) : null;
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
    if (this.global != null) {
      data['global'] = this.global!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Global {
  double? expectedEarnings;
  int? currentOrders;
  String? cancelled;

  Global({this.expectedEarnings, this.currentOrders, this.cancelled});

  Global.fromJson(Map<String, dynamic> json) {
    expectedEarnings = double.parse(json['expected_earnings']);
    currentOrders = json['current_orders'];
    cancelled = json['cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['expected_earnings'] = this.expectedEarnings;
    data['current_orders'] = this.currentOrders;
    data['cancelled'] = this.cancelled;
    return data;
  }
}

class Data {
  String? orderid;
  String? date;
  String? time;
  String? deliverycharge;
  String? status;
  String? deliveredTime;
  String? customerid;
  String? orderBy;
  String? cancelledTime;
  String? isLiveOrder;
  String? id;
  String? orderItemId;

  Data(
      {this.orderid,
      this.date,
      this.time,
      this.deliverycharge,
      this.status,
      this.deliveredTime,
      this.customerid,
      this.orderBy,
      this.cancelledTime,
      this.isLiveOrder,
      this.id,
      this.orderItemId});

  Data.fromJson(Map<String, dynamic> json) {
    orderid = json['orderid'];
    date = json['date'];
    time = json['time'];
    deliverycharge = json['deliverycharge'];
    deliveredTime = json['delivered_time'];
    status = json['status'];
    customerid = json['customerid'];
    orderBy = json['order_by'];
    cancelledTime = json['cancel_time'];
    isLiveOrder = json['is_live_order'];
    id = json['id'];
    orderItemId = json['orderitem_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderid'] = this.orderid;
    data['date'] = this.date;
    data['time'] = this.time;
    data['deliverycharge'] = this.deliverycharge;
    data['status'] = this.status;
    data['delivered_time'] = this.deliveredTime;
    data['customerid'] = this.customerid;
    data['order_by'] = this.orderBy;
    data['cancel_time'] = this.cancelledTime;
    data['is_live_order'] = this.isLiveOrder;
    data['id'] = this.id;
    data['orderitem_id'] = this.orderItemId;
    return data;
  }
}
