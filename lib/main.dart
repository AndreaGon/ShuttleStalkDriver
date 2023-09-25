import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shuttle_stalk_driver/res/colors.dart';
import 'package:shuttle_stalk_driver/utils/router.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ShuttleStalkDriver());
}

class ShuttleStalkDriver extends StatefulWidget {
  const ShuttleStalkDriver({Key? key}) : super(key: key);

  @override
  State<ShuttleStalkDriver> createState() => _ShuttleStalkDriverState();
}

class _ShuttleStalkDriverState extends State<ShuttleStalkDriver> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Shuttle Stalk',
        onGenerateRoute: MainRouter.generateRoute,
        theme: ThemeData(
            primaryColor: lightblue
        ),
        initialRoute: '/login'
    );
  }
}
