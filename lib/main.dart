import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
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
            padding: EdgeInsets.all(40),
            child: Transform.rotate(
                angle: direction * (math.pi / 180) * -1,
                child: Image.asset("comp.png")),
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
