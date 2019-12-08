import 'dart:async';
import 'package:lab_5/plumber.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'mainscreen.dart';

class PaymentScreen extends StatefulWidget {

  final Plumber plumber;
  final String orderid,val;
  PaymentScreen({this.plumber,this.orderid,this.val});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
    Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        appBar: AppBar(
            title: Text('PAYMENT'),
            backgroundColor: Colors.blueAccent,
          ),
      body: Column(children: <Widget>[
        Expanded(child:  WebView(
        initialUrl: 'http://mobilehost2019.com/myplumber/php/payment.php?email='+widget.plumber.email+'&mobile='+widget.plumber.phone+'&name='+widget.plumber.name+'&amount='+widget.val+'&orderid='+widget.orderid,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),)
      ],)
    ));
  }


  Future<bool> _onBackPressAppBar() async {
    print("onbackpress payment");
    String urlgetuser = "http://mobilehost2019.com/myplumber/php/get_user.php";

    http.post(urlgetuser, body: {
      "email": widget.plumber.email,
    }).then((res) {
      print(res.statusCode);
      var string = res.body;
      List dres = string.split(",");
      print(dres);
      if (dres[0] == "success") {
        Plumber updateuser = new Plumber(
            name: dres[1],
            email: dres[2],
            phone: dres[3],
            credit: dres[4],);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainScreen(plumber: updateuser)));
      }
    }).catchError((err) {
      print(err);
    });
    return Future.value(false);
  }
}