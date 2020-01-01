import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lab_5/forgotpassword.dart';
import 'package:lab_5/mainscreen.dart';
import 'package:lab_5/registerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:lab_5/plumber.dart';

String urlLogin = "https://mobilehost2019.com/myplumber/php/login_user.php";
String urlSecurityCodeForResetPass ='https://mobilehost2019.com/myplumber/php/security_code.php';
final TextEditingController _emcontroller = TextEditingController();
String _email = "";
final TextEditingController _passcontroller = TextEditingController();
String _password = "";
bool _isChecked = false;
Plumber plumber;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    //loadpref();
    print('Init: $_email');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        
        onWillPop: _onBackPressAppBar,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Container(
            decoration: new BoxDecoration(color: Color.fromRGBO(199, 241, 255, 1)),
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/mylogo.png',
                  scale: 1.5,
                ),
                TextField(
                    controller: _emcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Email', icon: Icon(Icons.email))),
                TextField(
                  controller: _passcontroller,
                  decoration: InputDecoration(
                      labelText: 'Password', icon: Icon(Icons.lock)),
                  obscureText: true,
                ),
                SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  minWidth: 300,
                  height: 50,
                  child: Text('Login', style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  color: Color.fromRGBO(0, 186, 247, 1),
                  textColor: Colors.white,
                  elevation: 15,
                  onPressed: _onLogin,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      checkColor: Colors.grey,
                      value: _isChecked,
                      onChanged: (bool value) {
                        _onChange(value);
                      },
                    ),
                    Text('Remember Me', style: TextStyle(fontSize: 16))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _register,
                  child: Text(
                    "Register New Account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(130, 130, 130, 1)
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _onForgot,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(130, 130, 130, 1)
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void _onLogin() {
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    if (_isEmailValid(_email) && (_password.length > 4)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Login in");
      pr.show();
      http.post(urlLogin, body: {
        "email": _email,
        "password": _password,
      }).then((res) {
        print(res.statusCode);
        var string = res.body;
        List dres = string.split(",");
        print(dres);
        Toast.show(dres[0], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        if (dres[0] == "success") {
          pr.dismiss();
          print(dres);
          print(dres[1]);
          Plumber plumber = new Plumber(name:dres[1], email:dres[2], phone:dres[3], credit:dres[4], rating:dres[5], radius:dres[6]);
          Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => MainScreen(plumber: plumber)
                )
          );
        }else{
          pr.dismiss();
        }
        
      }).catchError((err) {
        pr.dismiss();
        print(err);
      });
    } else {}
  }

  void _register(){
    print('onRegister');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  void _onChange(bool value) {
    setState(() {
      _isChecked = value;
      savepref(value);
    });
  }

  void loadpref() async {
    print('Inside loadpref()');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = (prefs.getString('email'));
    _password = (prefs.getString('pass'));
    print(_email);
    print(_password);
    if (_email.length > 1) {
      _emcontroller.text = _email;
      _passcontroller.text = _password;
      setState(() {
        _isChecked = true;
      });
    } else {
      print('No pref');
      setState(() {
        _isChecked = false;
      });
    }
  }

  void savepref(bool value) async {
    print('Inside savepref');
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //true save pref
      if (_isEmailValid(_email) && (_password.length > 5)) {
        await prefs.setString('email', _email);
        await prefs.setString('pass', _password);
        print('Save pref $_email');
        print('Save pref $_password');
        Toast.show("Preferences have been saved", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        print('No email');
        setState(() {
          _isChecked = false;
        });
        Toast.show("Check your credentials", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } else {
      await prefs.setString('email', '');
      await prefs.setString('pass', '');
      setState(() {
        //_emcontroller.text = '';
        //_passcontroller.text = '';
        _isChecked = false;
      });
      print('Remove pref');
      Toast.show("Preferences have been removed", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void _onForgot() {
    _email = _emcontroller.text;

    if (_isEmailValid(_email)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Sending Email");
      pr.show();
      http.post(urlSecurityCodeForResetPass, body: {
        "email": _email,
      }).then((res) {
        print("secure code : " + res.body);
        if (res.body == "error") {
          pr.dismiss();
          Toast.show('error', context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else {
          pr.dismiss();
          _saveEmailForPassReset(_email);
          _saveSecureCode(res.body); //save secure code for password reset
          Toast.show('Security code sent to your email', context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ForgotPassword()));
        }
      }).catchError((err) {
        pr.dismiss();
        print(err);
      });
    } else {
      Toast.show('Invalid Email', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _saveEmailForPassReset(String email) async {
    print('saving preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('resetPassEmail', email);
  }

  void _saveSecureCode(String code) async {
    print('saving preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('secureCode', code);
  }

  Future<bool> _onBackPressAppBar() async {
    Plumber plumber = new Plumber(
          name: "not register",
          email: "user@noregister",
          phone: "not register",
          credit: "0",
          rating: "0");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(plumber: plumber),
        ));
    return Future.value(false);
  }
}