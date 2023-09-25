import 'package:flutter/material.dart';
import 'package:shuttle_stalk_driver/view/home/home_view.dart';
import 'package:shuttle_stalk_driver/view/profile/profile_view.dart';
import 'package:shuttle_stalk_driver/view/report/report_view.dart';

import '../res/layout/bottom_nav_layout.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int selectedIndex = 0;
  List page = [
    HomeView(),
    ReportView(),
    ProfileView()
  ];

  //Functions

  void onClicked(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: page[selectedIndex],
      bottomNavigationBar: BottomNavLayout(selectedIndex: selectedIndex, onClicked: onClicked),
    );
  }
}
