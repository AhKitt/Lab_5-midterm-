import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'loginscreen.dart';
import 'mainscreen.dart';
import 'plumber.dart';

void main() => runApp(SplashScreen());

String _email, _password;
String url = "https://mobilehost2019.com/myplumber/php/login_user.php";

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/mylogo.png',
                scale: 2,
              ),
              SizedBox(
                height: 20,
              ),
              new ProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => new _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          if (animation.value > 0.99) {
            print('Sucess Login');
            loadpref(context);
          }
        });
      });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Container(
      width: 200,
      color: Colors.teal,
      child: LinearProgressIndicator(
        value: animation.value,
        backgroundColor: Colors.black,
        valueColor:
            new AlwaysStoppedAnimation<Color>(Color.fromRGBO(74, 210, 255, 1)),
      ),
    ));
  }
}

void loadpref(BuildContext context) async {
  print('Inside loadpref()');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _email = (prefs.getString('email')??'');
  _password = (prefs.getString('pass')??'');
  print("Splash:Preference");
  print(_email);
  print(_password);
  if (_isEmailValid(_email??"no email")) {
    //try to login if got email;
    _onLogin(_email, _password, context);
  } else {
    //login as unregistered user
    Plumber plumber = new Plumber(
      name: "not register",
      email: "user@noregister",
      phone: "not register",
      credit: "0",
      rating: "0");
    Navigator.push(
      context, MaterialPageRoute(builder: (context) => MainScreen(plumber: plumber)));
  }
}

bool _isEmailValid(String email) {
  return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}

void _onLogin(String email, String pass, BuildContext context) {
  http.post(urlLogin, body: {
    "email": _email,
    "password": _password,
  }).then((res) {
    print(res.statusCode);
    var string = res.body;
    List dres = string.split(",");
    print("SPLASH:loading");
    print(dres);
    if (dres[0] == "success") {
      Plumber plumber = new Plumber(
          name: dres[1],
          email: dres[2],
          phone: dres[3],);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen(plumber: plumber)));
    } else {
      //allow login as unregistered user
      Plumber plumber = new Plumber(
          name: "not register",
          email: "user@noregister",
          phone: "not register",);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen(plumber: plumber)));
    }
  }).catchError((err) {
    print(err);
  });
}



Map<int, Color> color = {
  50: Color.fromRGBO(74, 210, 255, .1),
  100: Color.fromRGBO(74, 210, 255, .2),
  200: Color.fromRGBO(74, 210, 255, .3),
  300: Color.fromRGBO(74, 210, 255, .4),
  400: Color.fromRGBO(74, 210, 255, .5),
  500: Color.fromRGBO(74, 210, 255, .6),
  600: Color.fromRGBO(74, 210, 255, .7),
  700: Color.fromRGBO(74, 210, 255, .8),
  800: Color.fromRGBO(74, 210, 255, .9),
  900: Color.fromRGBO(74, 210, 255, 1),
};
