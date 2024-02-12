

class GetChatModel {
  String? createddate;
  String? time;
  String? msgType;
  String? message;

  GetChatModel({this.createddate, this.time, this.msgType, this.message});

  GetChatModel.fromJson(Map<String, dynamic> json) {
    createddate = json['createddate'];
    time = json['time'];
    msgType = json['msg_type'];
    message = json['message'];
  }


}