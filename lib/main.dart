import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import 'dart:ui';

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
        body: Builder(builder: (context) {
          if (_hasPermissions) {
            return _buildCompass();
          } else {
            return _buildPermissionSheet();
          }
        }),
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
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Permission.locationWhenInUse.request().then((value) {
              _fetchPermissionStatus();
            });
          },
          child: const Text("Request Permission")),
    );
  }
}
