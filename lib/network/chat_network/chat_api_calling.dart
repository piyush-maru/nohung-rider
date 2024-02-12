import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rider_app/model/GetChat.dart';

class ChatRepo {
  ValueNotifier<List<GetChatModel>> getChatModel = ValueNotifier([]);

  //Send Chat  Message
  Future<bool> sendMessage(String sendMessage) async {
    String url = "https://nohungtesting.com/api/rider/send_message.php";

    try {
      http.Response response = await http.post(Uri.parse(url), body: {
        'token': '123456789',
        'userid': '70',
        'message': sendMessage,
      });
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //GetChat  Message

  Future<bool> getChatMessage() async {
    String Url = "https://nohungtesting.com/api/rider/get_chat.php";

    try {
      http.Response response = await http.post(Uri.parse(Url), body: {
        'token': '123456789',
        'userid': '70',
      });
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        getChatModel.value = [];

        for (var i in data['data']) {
          getChatModel.value.add(GetChatModel.fromJson(i));
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
