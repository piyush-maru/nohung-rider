//AgreementAndPolicyScreen
import 'package:flutter/material.dart';
import 'package:rider_app/res.dart';
import 'package:rider_app/utils/Constents.dart';
import 'package:rider_app/utils/progress_dialog.dart';

class AgreementAndPolicyScreen extends StatefulWidget {
  @override
  AgreementAndPolicyScreenState createState() =>
      AgreementAndPolicyScreenState();
}

class AgreementAndPolicyScreenState extends State<AgreementAndPolicyScreen> {
  ProgressDialog? progressDialog;
  var terms_data = "Our terms of service are as follows and are subject to change at any point in time. You will be notified of the same when such changes are made: \n  \n" +
      " 1) Delivery Food Quality  \n \n" +
      " We are not liable for the quality, quantity or packaging of the food you ordered. If something is missing or the kitchen got your order wrong, kindly contact them to rectify the issue and state your concern. \n\n" +
      " 2) Deliveries: Address \n \n" +
      " You are responsible for ensuring that the delivery address for your order is correct and unambiguous. We cannot guarantee a successful delivery if this condition is not met. If further specifications regarding your location are needed, it should be provided in the 'notes' section which will be provided while placing your order. \n\n" +
      " 3) Delivery Time  \n\n" +
      " Our drivers will strive to deliver your order in the appointed time. However, unexpected delays may occur. Please be aware that restaurants can occasionally be delayed in their preparation, which we are not liable for. Additionally, drivers may get delayed due to bad weather or traffic conditions. We will do our best to notify you of any such delays. \n\n" +
      " 4) Service Availability  \n\n" +
      " We reserve the right to disable our delivery services temporarily due to factors out of our control, like weather conditions, driver availability or any other unforeseen circumstances. Items that are not available will not be displayed on our website but if for any reason, at the last minute an item/items is unavailable, you will be notified immediately and the order will automatically be cancelled so that you can choose another item to replace it and you can place a new order.\n \n" +
      " 5) Receiving your order \n\n" +
      " Upon arrival, the driver will attempt to make contact with you by ringing the doorbell or calling the provided phone number. If the call is not answered or the provided number is not available, and if contact cannot be made within 5 minutes, the driver will place the order in a safe place. If the food is not delivered to you in such a situation do reach out to us so we can help you with this issue. For verification purposes, you may be asked in person to confirm details about your order. \n\n" +
      " 6) Sharing your personal information \n\n" +
      " We do not sell, trade, or rent user's personal identification information to others. We may share generic aggregated demographic information not linked to any personal identification information regarding visitors and users with our business partners, trusted affiliates and advertisers for the purposes outlined above. \n\n" +
      " 7) Allergens \n\n" +
      " Please be aware that the food may contain or come into contact with common allergens, such as dairy, eggs, wheat, soybeans, tree nuts, peanuts, fish, shellfish or wheat. We kindly request you to mention in the comment box if you are allergic to any items to ensure that you have a safe dining experience.\n \n" +
      " 8) Refund Policy and Order Cancellation: \n\n" +
      " If for any reason you choose to cancel your order you may do so within a time period of x minutes. If the order is cancelled beyond this time period, you will not be eligible for a full refund. If you have cancelled your order within x minutes, you will be eligible for a full refund. If for some reason you are unsatisfied with the quality of the food, you may reach out to us at support@nohung.com and we will try to reimburse you. You will be refunded immediately, or it may take 2 to 3 business days after the bank procedure. You can also choose to add the refund amount to your Nohung Wallet, this process can be completed in 1 to 2 hours. \n\n" +
      " 9) Wallet: \n\n" +
      " Nohung Wallet is in partnership with (bank name) which allows for you to make hassle-free payments on our app directly instead of having to redirect to online payment options or having to fetch your credit card when you’re in a rush. You may load upto (amount) rupees onto your Nohung wallet.\n \n" +
      " 10) Online Payment:\n \n" +
      " All of your transactions with Nohung are secure and none of your transactions will go unauthorised with our 3D Secure Payment method which has a two-step verification process. We accept (enter forms of online payment you will be accepting) …. \n\n" +
      " 11) Intellectual Property Rights \n\n" +
      " The copyright, trademarks, database right and other intellectual property right of any nature in all material contained on, in, or available through the Websites including all information, the Consent, logo, data, text, music, sound, photographs, graphics and video messages, the selection and arrangement thereof, and all source code, software compilations and other material (“Material“) is owned by or licensed to Nohung or its group companies. All rights are reserved. You cannot use, copy, edit, vary, reproduce, publish, display, distribute, store, transmit, commercially exploit or disseminate the Material without the prior written consent of Homey or the relevant group company or the relevant third party partner of Nohung.\n \n" +
      " 12) Cookies \n\n" +
      " By using our Services with your browser settings to accept cookies, you are consenting to our use of cookies in the manner described in this section. We may also allow third parties to provide audience measurement and analytics services for us, to serve advertisements on our behalf across the Internet, and track and report on the performance of those advertisements. To modify your cookie settings, please visit your browser’s settings.\n \n" +
      " 13) Account \n\n" +
      " In order to create an account with Nohung, you need to be at least 18 years of age. While registering with Nohung you will be required to provide basic personal information such as your name, age, phone number, e-mail address, and at least one mode of payment (you may choose between any valid online payment method or a credit card). Providing us with false information will lead to the suspension of your account and you will no longer be allowed to avail services from Nohung. You may only hold one account at a time with Nohung. \n\n" +
      " 14) Coupons  \n\n" +
      " Coupons cannot be clubbed with any other discount or offer and only one coupon may be used per order. When you are placing your order you will be asked to enter your coupon code so as to avail the offer. The prices will be inclusive of taxes.";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                        padding: EdgeInsets.only(top: 20, left: 20),
                        child: Image.asset(
                          Res.ic_back,
                          width: 20,
                          height: 20,
                        )),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "Terms and Conditions",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: AppConstant.fontBold),
                      ),
                    ),
                  ),
                  Container()
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 30),
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "$terms_data",
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 20,
                width: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
