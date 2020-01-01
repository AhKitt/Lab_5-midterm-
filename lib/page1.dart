import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:lab_5/SlideRightRoute.dart';
import 'package:lab_5/loginscreen.dart';
import 'package:lab_5/plumber.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'job.dart';
import 'jobdetail.dart';

double perpage = 1;

class Page1 extends StatefulWidget {
  final Plumber plumber;

  Page1({Key key, this.plumber});

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  GlobalKey<RefreshIndicatorState> refreshKey;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = "Searching current location...";
  List data;

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomPadding: false,
           
            body: RefreshIndicator(
              key: refreshKey,
              color: Colors.blueAccent,
              onRefresh: () async {
                await refreshList();
              },
              child: ListView.builder(
                  //Step 6: Count the data
                  itemCount: data == null ? 1 : data.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        color: Colors.blueAccent,
                        child: Column(
                          children: <Widget>[
                            Stack(children: <Widget>[
                              Image.asset(
                                "assets/images/plumbing background2.jpg",
                                fit: BoxFit.fitWidth,
                              ),
                              Container(
                                height: 247,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5)
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child: Text("MyPlumber",
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: 300,
                                    height: 140,
                                    child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.person,
                                                    ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    widget.plumber.name
                                                            .toUpperCase() ??
                                                        "Not registered",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.location_on,
                                                    ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(_currentAddress),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.rounded_corner,
                                                    ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                      "Job Radius within " +
                                                          widget.plumber.radius +
                                                          " KM"),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.credit_card,
                                                    ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text("You have " +
                                                      widget.plumber.credit +
                                                      " Credit"),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              color: Colors.blueAccent,
                              child: Center(
                                child: Text("Jobs Available Today",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (index == data.length && perpage > 1) {
                      return Container(
                        width: 250,
                        color: Colors.white,
                        child: MaterialButton(
                          child: Text(
                            "Load More",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {},
                        ),
                      );
                    }
                    index -= 1;
                    return Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Card(
                        elevation: 2,
                        child: InkWell(
                          onTap:() => _onJobDetail(
                            data[index]['jobid'],
                            data[index]['jobtitle'],
                            data[index]['jobowner'],
                            data[index]['jobaddress'],
                            data[index]['jobdesc'],
                            data[index]['jobprice'],
                            data[index]['joblatitude'],
                            data[index]['joblongitude'],
                            data[index]['jobtime'],
                            data[index]['jobimage'],
                            data[index]['jobworker'],
                            widget.plumber.email,
                            widget.plumber.name,
                            widget.plumber.credit,
                          ),
                          onLongPress: (){},
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white),
                                      image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                    "http://mobilehost2019.com/myplumber/jobimages/${data[index]['jobimage']}.jpg"
                                  )))),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Container(
                                    margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                            data[index]['jobtitle']
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Text(data[index]['jobtime']),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.person,
                                                ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Flexible(
                                              child: Text(
                                                data[index]['jobowner']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.start,
                                        //   children: <Widget>[
                                        //     Icon(Icons.phone_android,
                                        //         ),
                                        //     SizedBox(
                                        //       width: 5,
                                        //     ),
                                        //     Flexible(
                                        //       child: Text(
                                        //         data[index]['jobphone']
                                        //                 .toString(),
                                        //         style: TextStyle(
                                        //             fontSize: 14,
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.location_on,
                                                ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Flexible(
                                              child: Text(
                                                data[index]['jobaddress']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            )));
  }

  _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition);
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name},${place.locality}, ${place.postalCode}, ${place.country}";
        init(); //load data from database into list array 'data'
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> makeRequest() async {
    String urlLoadJobs = "http://mobilehost2019.com/myplumber/php/load_jobs.php";
    ProgressDialog progress = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    progress.style(message: "Loading Jobs");
    progress.show();
    http.post(urlLoadJobs, body: {
      "email": widget.plumber.email ?? "notavail",
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
      "radius" : widget.plumber.radius ?? "15",
    }).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        data = extractdata["jobs"];
        perpage = (data.length / 10);
        print("data");
        print(data);
        progress.dismiss();
      });
    }).catchError((err) {
      print(err);
      progress.dismiss();
    });
    return null;
  }

  Future init() async {
    this.makeRequest();
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    this.makeRequest();
    return null;
  }

  

  void _onJobDetail(
      String jobid,
      String jobtitle,
      String jobowner,
      String jobadd,
      String jobdesc,
      String jobprice,
      String joblat,
      String joblng,
      String jobtime,
      String jobimage,
      String jobworker,
      String email,
      String name,
      String credit) {

    Job job = new Job(
        jobid: jobid,
        jobtitle: jobtitle,
        jobowner: jobowner,
        jobadd: jobadd,
        jobdesc: jobdesc,
        jobprice: jobprice,
        jobtime: jobtime,
        joblat: joblat,
        joblng: joblng,
        jobimage: jobimage,
        jobworker: jobworker,);
    //print(data);
    
    Navigator.push(context, SlideRightRoute(page: JobDetail(job: job, plumber: widget.plumber)));
  }

  void _onJobDelete() {
    print("Delete");
  }
}