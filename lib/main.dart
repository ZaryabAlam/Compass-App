import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import 'dart:ui';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _advancedDrawerController = AdvancedDrawerController();
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
    AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      child: SizedBox(),
      drawer: SizedBox(),
    );

    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (context, value, child) {
                return Icon(
                  value.visible ? Icons.clear_rounded : Icons.menu_rounded,
                  color: Colors.black54,
                  size: 30,
                );
              },
            ),
          ),
        ),
        body: Builder(builder: (context) {
          if (_hasPermissions) {
            return _buildCompass();
          } else {
            return _buildPermissionSheet();
          }
        }),
      ),
      drawer: SafeArea(
        child: Container(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 125.0,
                  height: 125.0,
                  margin: const EdgeInsets.only(
                    top: 15.0,
                    bottom: 35.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    'https://i.ibb.co/f833VSL/2199882.png',
                  ),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.account_circle_rounded),
                  title: Text('Zaryab Alam'),
                ),
                ListTile(
                    onTap: () {},
                    leading: Icon(Icons.home_filled),
                    title: Text('My Compass')),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.favorite),
                  title: Text('Flutter SDK'),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
                Spacer(),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              "https://i.ibb.co/LYSsfBq/qrcode.png"))),
                ),
                Column(
                  children: [
                    Text(
                      "Scan for more!",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6.0,
                    ),
                    child: Column(
                      children: [
                        Text("All Rights Reserve 2022 © DevCat | Zaryab Alam"),
                        Text('Terms of Service | Privacy Policy'),
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
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
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

//////////////////////////// Permission /////////////////////////////////////////////
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
                    image: DecorationImage(
                        image: AssetImage("assets/comp-logo.png"))),
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
                      image: AssetImage("assets/comp-bottom.png"),
                      fit: BoxFit.fill)),
            ),
          ],
        )
      ],
    );
  }
}
