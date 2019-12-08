import 'package:flutter/material.dart';
import 'package:lab_5/page1.dart';
import 'package:lab_5/page2.dart';
import 'package:lab_5/page3.dart';
import 'plumber.dart';

class MainScreen extends StatefulWidget {
  final Plumber plumber;

  const MainScreen({Key key, this.plumber}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Widget> pages;

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    pages = [
      Page1(plumber: widget.plumber),
      Page2(plumber: widget.plumber),
      Page3(plumber: widget.plumber)
    ];
  }

  String $pagetitle = "My Plumber";

  onTapped(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
         return Scaffold(
        body: pages[currentPageIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTapped,
          currentIndex: currentPageIndex,
          type: BottomNavigationBarType.fixed,

          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text("Jobs"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event, ),
              title: Text("My Jobs"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, ),
              title: Text("Profile"),
            )
          ],
        ),
      );
  }
}
