class DeliveryClass {
  DeliveryClass({
    this.status,
    this.message,
    this.data,
  });

  bool? status;
  String? message;
  List<Datum>? data;

  factory DeliveryClass.fromJson(Map<String, dynamic> json) => DeliveryClass(
    status: json["status"],
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
    this.deliveryaddress,
    this.foodieMobilenumber,
    this.kitchenMobilenumber,
  });

  String? deliveryaddress;
  String? foodieMobilenumber;
  String? kitchenMobilenumber;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    deliveryaddress: json["deliveryaddress"],
    foodieMobilenumber: json["foodie_mobilenumber"],
    kitchenMobilenumber: json["kitchen_mobilenumber"],
  );

  Map<String, dynamic> toJson() => {
    "deliveryaddress": deliveryaddress,
    "foodie_mobilenumber": foodieMobilenumber,
    "kitchen_mobilenumber": kitchenMobilenumber,
  };
}
