import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rider_app/model/BeanAcceptOrder.dart';
import 'package:rider_app/model/BeanCheckApiModel.dart';
import 'package:rider_app/model/BeanForgotPassword.dart';
import 'package:rider_app/model/BeanGetFeedback.dart';
import 'package:rider_app/model/BeanGetOrder.dart';
import 'package:rider_app/model/BeanGetProfile.dart';
import 'package:rider_app/model/BeanLogin.dart';
import 'package:rider_app/model/BeanRiderStatus.dart';
import 'package:rider_app/model/BeanSendFeedback.dart';
import 'package:rider_app/model/BeanSendMessage.dart';
import 'package:rider_app/model/BeanSignUp.dart';
import 'package:rider_app/model/BeanStartDelivery.dart';
import 'package:rider_app/model/BeanTripSummary.dart';
import 'package:rider_app/model/BeanWithdrawpayment.dart';
import 'package:rider_app/model/BeanrejectOrder.dart';
import 'package:rider_app/model/GetCustomerFeedback.dart';
import 'package:rider_app/model/GetOrdeHistory.dart';
import 'package:rider_app/model/GetOrderDetails.dart';
import 'package:rider_app/model/GetOverAllReview.dart';
import 'package:rider_app/model/bankAccountModel.dart';
import 'package:rider_app/model/getCureentOrders.dart';
import 'package:rider_app/utils/DioLogger.dart';

import 'EndPoints.dart';

class ApiProvider {
  static const _baseUrl = "https://nohungtest.tech/api/rider/";
  //static const _baseUrl = "https://nohungtesting.com/api/rider/";
  //static const _baseUrl = "https://nohung.com/api/rider/";
  static const String TAG = "ApiProvider";

  Dio? _dio;
  DioError? _dioError;

  // ApiProvider() {
  //   BaseOptions dioOptions = BaseOptions()..baseUrl = ApiProvider._baseUrl;
  //   _dio = Dio(dioOptioyns);
  //   _dio.interceptors
  //       .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
  //     options.headers = {
  //       'Content-Type': 'multipart/form-data',
  //     };
  //     DioLogger.onSend(TAG, options);
  //     return options;
  //   }, onResponse: (Response response) {
  //     DioLogger.onSuccess(TAG, response);
  //     return response;
  //   }, onError: (DioError error) {
  //     DioLogger.onError(TAG, error);
  //     return error;
  //   }));
  // }

  ApiProvider() {
    _dio = Dio(BaseOptions(baseUrl: ApiProvider._baseUrl));

    _dio!.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers = {
        'Content-Type': 'multipart/form-data',
      };
      DioLogger.onSend(TAG, options);
      return handler.next(options);
    }, onResponse: (Response response, ResponseInterceptorHandler handler) {
      DioLogger.onSuccess(TAG, response);
      return handler.next(response);
    }, onError: (DioError err, ErrorInterceptorHandler handler) {
      DioLogger.onError(TAG, err);
      return handler.next(err);
    }));
  }

  Future registerUser(FormData params) async {
    try {
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.register, data: params);
      return BeanSignUp.fromJson(json.decode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future addBankAccount(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.add_account_detail, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.add_account_detail,
          data: params);
      return jsonDecode(response.data);
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getBankAccounts(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.get_bank_accounts, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.get_bank_accounts,
          data: params);
      return BankAccountsModel.fromJson(json.decode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future editBankAccounts(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.edit_bank_account, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.edit_bank_account,
          data: params);
      return json.decode(response.data);
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future deleteBankAccounts(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.delete_bank_account, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.delete_bank_account,
          data: params);
      return json.decode(response.data);
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getFeedback(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.get_received_reviews, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.get_received_reviews,
          data: params);
      return BeanGetFeedback.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getOrderDetails(FormData params) async {
    try {
      print(params.fields);
      // Response response =
      // await _dio.post(EndPoints.get_order_detail, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.get_order_detail,
          data: params);
      print("response.statusCodddde");
      print(response.statusCode);
      print(jsonDecode(response.data));
      return GetOrderDetails.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getOrder(FormData params) async {
    try {
      // Response response = await _dio.post(EndPoints.get_orders, data: params);
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.get_orders, data: params);
      return BeanGetOrder.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future rejectOrder(FormData params) async {
    try {
      //Response response = await _dio.post(EndPoints.reject_order, data: params);
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.reject_order, data: params);
      return BeanRejectOrder.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future acceptOrder(FormData params) async {
    try {
      //Response response = await _dio.post(EndPoints.accept_order, data: params);
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.accept_order, data: params);
      return BeanAcceptOrder.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future riderStatusUpdate(FormData params) async {
    try {
      //Response response = await _dio.post(EndPoints.accept_order, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.rider_status_update,
          data: params);
      return BeanCheckApiModel.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future riderOrderDelay(FormData params) async {
    try {
      //Response response = await _dio.post(EndPoints.accept_order, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.rider_order_delay,
          data: params);
      return BeanCheckApiModel.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future riderOrderIssue(FormData params) async {
    try {
      //Response response = await _dio.post(EndPoints.accept_order, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.rider_order_issue,
          data: params);
      return BeanCheckApiModel.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future orderCancelRequest(FormData params) async {
    try {
      //Response response = await _dio.post(EndPoints.accept_order, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.order_cancel_request,
          data: params);
      return BeanCheckApiModel.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getCustomerFeedback(FormData params) async {
    try {
      // Response response = await _dio.post(
      //     EndPoints.get_customer_feedback_improvement_options,
      //     data: params);

      Response response = await Dio().post(
          ApiProvider._baseUrl +
              EndPoints.get_customer_feedback_improvement_options,
          data: params);
      return GetCustomerFeedback.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getProfile(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.get_my_profile, data: params);

      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.get_my_profile, data: params);

      return GetProfile.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future withdrawPayment(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.whitdraw_payment, data: params);

      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.whitdraw_payment,
          data: params);

      return BeanWithdrawPayment.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getOverAllReview(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.get_overall_received_reviews, data: params);

      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.get_overall_received_reviews,
          data: params);

      return GetOverAllReview.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  // Future getChat(FormData params) async {
  //   try {
  //     //Response response = await _dio.post(EndPoints.get_chat, data: params);
  //     Response response = await Dio()
  //         .post(ApiProvider._baseUrl + EndPoints.get_chat, data: params);
  //
  //     return  GetChat.fromJson(jsonDecode(response.data));
  //   } catch (error, stacktrace) {
  //     Map<dynamic, dynamic> map = _dioError.response.data;
  //     if (_dioError.response.statusCode == 500) {
  //       throwIfNoSuccess(map['message']);
  //     } else {
  //       throwIfNoSuccess("Something gone wrong.");
  //     }
  //   }
  //   return null;
  // }

  Future getOrderHistory(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.order_history, data: params);

      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.order_history, data: params);
      return GetOrderHistory.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future loginUser(FormData params) async {
    try {
      // Response response = await _dio.post(
      //   EndPoints.login,
      //   data: params,
      // );
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.login, data: params);
      return BeanLogin.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getState(FormData params) async {
    try {
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.get_state, data: params);
      return jsonDecode(response.data);
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getCity(FormData params) async {
    try {
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.get_city, data: params);
      return jsonDecode(response.data);
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;

    // Response response = await _dio.post(EndPoints.get_city, data: params);
    // return json.decode(response.data);
  }

  Future sendFeedback(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.send_customer_feedback, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.send_customer_feedback,
          data: params);

      return BeanSendFeedback.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future tripSummary(FormData params) async {
    try {
      //Response response = await _dio.post(EndPoints.trip_summary, data: params);
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.trip_summary, data: params);

      return BeanTripSummary.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future sendMessage(FormData params) async {
    try {
      //Response response = await _dio.post(ApiProvider._baseUrl + EndPoints.send_message, data: params);

      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.send_message, data: params);

      return BeanSendMessage.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future<BeanForgotPassword?> forgotPassword(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.forgot_password, data: params);

      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.forgot_password, data: params);

      return BeanForgotPassword.fromJson(json.decode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future starDelivery(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.start_delivery, data: params);
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.start_delivery, data: params);

      return BeanStartDelivery.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future updateOrderTrack(FormData params) async {
    try {
      // Response response =
      // await _dio.post(EndPoints.update_order_track, data: params);
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.update_order_track,
          data: params);

      return BeanStartDelivery.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future getCurrentOrders(FormData params) async {
    try {
      Response response = await Dio().post(
          ApiProvider._baseUrl + EndPoints.get_current_orders,
          data: params);
      // Response response =
      // await _dio.post(EndPoints.get_current_orders, data: params);
      // return null;
      return GetCurrentOrdersModel.fromJson(jsonDecode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future delivered(FormData params) async {
    try {
      // Response response = await _dio.post(EndPoints.delivered, data: params);
      Response response = await Dio()
          .post(ApiProvider._baseUrl + EndPoints.delivered, data: params);

      return json.decode(response.data);
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  Future<RiderStatus?> updateRiderAvailability(FormData value) async {
    try {
      Response response =
          await _dio!.post(EndPoints.change_available_status, data: value);
      return RiderStatus.fromJson(json.decode(response.data));
    } catch (error, stacktrace) {
      Map<dynamic, dynamic> map = _dioError!.response!.data;
      if (_dioError!.response!.statusCode == 500) {
        throwIfNoSuccess(map['message']);
      } else {
        throwIfNoSuccess("Something gone wrong.");
      }
    }
    return null;
  }

  void throwIfNoSuccess(String response) {
    throw new HttpException(response);
  }
}
