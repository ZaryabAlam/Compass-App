import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {},
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
