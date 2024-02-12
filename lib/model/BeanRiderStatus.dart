

class RiderStatus {
  RiderStatus({
    this.status,
    this.message,
    this.data,
  });

  bool? status;
  String? message;
  String? data;

  factory RiderStatus.fromJson(Map<String, dynamic> json) => RiderStatus(
      status: json["status"], message: json["message"], data: json['data']);

  Map<String, dynamic> toJson() =>
      {"status": status, "message": message, "data": data};
}
