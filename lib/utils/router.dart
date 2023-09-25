import 'package:flutter/material.dart';

import '../view/authentication/login_view.dart';

class MainRouter {
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case '/login':
        return MaterialPageRoute(builder: (_)=> Login());
      default:
        return MaterialPageRoute(builder: (_)=> Login());
    }
  }
}