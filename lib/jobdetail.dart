import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lab_5/plumber.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'job.dart';
import 'mainscreen.dart';

class JobDetail extends StatefulWidget {
  final Job job;
  final Plumber plumber;

  const JobDetail({Key key, this.job, this.plumber}) : super(key: key);

  @override
  _JobDetailState createState() => _JobDetailState();
}

class _JobDetailState extends State<JobDetail> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.blueAccent));
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold( 
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('JOB DETAILS'),
            backgroundColor: Colors.blueAccent,
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: DetailInterface(
                job: widget.job,
                plumber: widget.plumber,
              ),
            ),
          )),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            plumber: widget.plumber,
          ),
        ));
    return Future.value(false);
  }
}

class DetailInterface extends StatefulWidget {
  final Job job;
  final Plumber plumber;
  DetailInterface({this.job, this.plumber});

  @override
  _DetailInterfaceState createState() => _DetailInterfaceState();
}

class _DetailInterfaceState extends State<DetailInterface> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocation;
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    print('here is detail');
    print(widget.job.jobworker);
    print(widget.job.joblat);
    print(widget.job.joblat);
    _myLocation = CameraPosition(
      target: LatLng(
          double.parse(widget.job.joblat), double.parse(widget.job.joblng)),
      zoom: 13.5,
    );

    markers.add(Marker(
      markerId: MarkerId('myMarker'),
      infoWindow: InfoWindow(title: "Your Job Here"),
      draggable: false,
      onTap: (){
        print('Marker Tapped');
      },
      position: LatLng(double.parse(widget.job.joblat), double.parse(widget.job.joblng)),
      ));
    print(_myLocation.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(),
        Container(
          width: 280,
          height: 200,
          child: Image.network(
              'http://mobilehost2019.com/myplumber/jobimages/${widget.job.jobimage}.jpg',
              fit: BoxFit.fill),
        ),
        SizedBox(
          height: 10,
        ),
        Text(widget.job.jobtitle.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        Text(widget.job.jobtime),
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Table(children: [
                TableRow(children: [
                  Text("Job Owner",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(widget.job.jobowner,
                    style: TextStyle(fontSize: 16)),
                ]),
                TableRow(children: [
                  Text("Job Address",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(widget.job.jobadd,
                  style: TextStyle(fontSize: 16))
                ]),
              ]),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 170,
                width: 340,
                child: GoogleMap(
                  // 2
                  initialCameraPosition: _myLocation,
                  // 3
                  mapType: MapType.hybrid,
                  // 4
                  markers: Set.from(markers),
                  

                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
              SizedBox(height: 8,),
              Container(
                width: 350,
                child: hasWorker()? rejectButton():acceptButton(),
              )
            ],
          ),
        ),
      ],
    );
  }

  bool hasWorker(){
    if(widget.job.jobworker==null){
      return false;
    }else{
      return true;
    }
  }

  //-----------------------Accept Job-----------------------
  Widget acceptButton(){
    return MaterialButton(
      
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      height: 40,
      child: Text(
        'ACCEPT JOB',
        style: TextStyle(fontSize: 16),
      ),
      color: Colors.blueAccent,
      textColor: Colors.white,
      elevation: 5,
      onPressed: _onAcceptJob,
    );
  }

  void _onAcceptJob() {
    if (widget.plumber.email=="user@noregister"){
      Toast.show("Please register to view accept jobs", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    else if(widget.job.jobworker!=null){
      Toast.show("This job already accepted", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    else if(widget.plumber.email==widget.job.jobowner){
      Toast.show("Cannot accept by job owner", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    } 
    else{
      _showDialog();
    }
    print("Accept Job");
    
  }

  void _showDialog() {
    // flutter defined function
    if (int.parse(widget.plumber.credit)<1){
        Toast.show("Credit not enough ", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Accept " + widget.job.jobtitle),
          content: new Text("Are your sure?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                print("click yes");
                Navigator.of(context).pop();
                acceptRequest();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> acceptRequest() async {
    String urlLoadJobs = "http://mobilehost2019.com/myplumber/php/accept_job.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Accepting Job");
    pr.show();
    http.post(urlLoadJobs, body: {
      "jobid": widget.job.jobid,
      "email": widget.plumber.email,
      "credit": widget.plumber.credit,
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            pr.dismiss();
            print(widget.plumber.email);
            _onLogin(widget.plumber.email, context);
      } else {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            pr.dismiss();
      }
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    return null;
  }

  //-----------------------Reject Job-----------------------
  Widget rejectButton(){
    return MaterialButton(
      
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)),
      height: 40,
      child: Text(
        'REJECT JOB',
        style: TextStyle(fontSize: 16),
      ),
      color: Colors.red,
      textColor: Colors.white,
      elevation: 5,
      onPressed: _rejectJob,
    );
  }

  void _rejectJob() {
    // flutter defined function
    // if (int.parse(widget.plumber.credit)<1){
    //     Toast.show("Credit not enough ", context,
    //         duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    //         return;
    // }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Reject " + widget.job.jobtitle),
          content: new Text("Are your sure?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                print("click yes");
                Navigator.of(context).pop();
                rejectRequest();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> rejectRequest() async {
    String urlLoadJobs = "http://mobilehost2019.com/myplumber/php/reject_job.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Rejecting Job");
    pr.show();
    http.post(urlLoadJobs, body: {
      "jobid": widget.job.jobid,
      "email": widget.plumber.email,
      "credit": widget.plumber.credit,
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            pr.dismiss();
            print(widget.plumber.email);
            _onLogin(widget.plumber.email, context);
      } else {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            pr.dismiss();
      }
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    return null;
  }

   void _onLogin(String email, BuildContext ctx) {
     String urlgetuser = "http://mobilehost2019.com/myplumber/php/get_user.php";

    http.post(urlgetuser, body: {
      "email": email,
    }).then((res) {
      print(res.statusCode);
      var string = res.body;
      List dres = string.split(",");
      print(dres);
      if (dres[0] == "success") {
        Plumber plumber = new Plumber(
            name: dres[1],
            email: dres[2],
            phone: dres[3],
            credit: dres[4],
            rating: dres[5],
            radius: dres[6]);
        Navigator.push(ctx,
            MaterialPageRoute(builder: (context) => MainScreen(plumber: plumber)));
      }
    }).catchError((err) {
      print(err);
    });
  }
}
