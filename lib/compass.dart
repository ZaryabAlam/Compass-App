import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'home.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermissions = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        body: MyApp(),
        // body: Builder(builder: (context) {
        //   if (_hasPermissions) {
        //     return _buildCompass();
        //   } else {
        //     return _buildPermissionSheet();
        //   }
        // }),
      ),
    );
  }

//////////////////////////// Compass /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
  Widget _buildCompass() {
    final _h = MediaQuery.of(context).size.height;
    final _w = MediaQuery.of(context).size.width;

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        //error msg
        if (snapshot.hasError) {
          return Text("ERROR LOADING DATA: ${snapshot.error}");
        }

        //loading data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        double? direction = snapshot.data!.heading;

        //if sensor is not working
        if (direction == null) {
          return const Center(
            child: Text("DEVICE DOESNT SUPPORT SENSORS"),
          );
        }

        // compass screen
        return Center(
          child: Container(
            height: 800,
            width: 600,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/blue5.jpg"), fit: BoxFit.cover)),
            padding: EdgeInsets.all(40),
            child: Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        height: _h * 0.35,
                        width: _w * 0.62,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white12, Colors.white10]),
                          borderRadius: BorderRadius.circular(250),
                          border: Border.all(width: 2, color: Colors.white12),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: Transform.rotate(
                        angle: direction * (math.pi / 180) * -1,
                        child: Image.asset("assets/comp.png")),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

/////////////////////////// Permission //////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
  Widget _buildPermissionSheet() {
    final _h = MediaQuery.of(context).size.height;
    final _w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          color: Color(0XFFf0f1ec),
        ),
        Center(
          child: Column(
            children: [
              SizedBox(
                height: _h * 0.2,
              ),
              Container(
                height: 230,
                width: 230,
                decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("comp-logo.png"))),
              ),
              Container(
                height: _h * 0.07,
                width: _w * 0.6,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF21313f)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ))),
                    onPressed: () {
                      Permission.locationWhenInUse.request().then((value) {
                        _fetchPermissionStatus();
                      });
                    },
                    child: const Text("Lets go!")),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: _h * 0.3,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("comp-bottom.png"), fit: BoxFit.fill)),
            ),
          ],
        )
      ],
    );
  }
}
