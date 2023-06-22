import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';

void main() {
  TorchController().initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = TorchController();
  late StreamSubscription<bool> _subscription;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();
    controller.isTorchActive.then((isOn) {
      if (_isBlinking && isOn!) {
        _blinkTorch();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _blinkTorch() async {
    await controller.toggle();
    await Future.delayed(Duration(milliseconds: 500));
    await controller.toggle();
    await Future.delayed(Duration(milliseconds: 500));
    if (_isBlinking) {
      _blinkTorch();
    }
  }

  void _toggleBlinking() {
    setState(() {
      _isBlinking = !_isBlinking;
      if (_isBlinking) {
        _blinkTorch();
      } else {
        controller.toggle(
            intensity: 0); // turn off torch when blinking is stopped
      }
    });
  }

  void _toggleTorch() {
    setState(() {
      controller.toggle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(child: const Text('Flash Light App')),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: AssetImage(
                  "assets/spotlight-shining-down-into-grunge-interior.jpg"),
              fit: BoxFit.cover,
              color: Colors.black12,
              colorBlendMode: BlendMode.darken,
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 3)),
                    child: FutureBuilder<bool?>(
                      future: controller.isTorchActive,
                      builder: (_, snapshot) {
                        if (snapshot.hasData) {
                          final snapshotData = snapshot.data!;
                          return Center(
                            child: Text(
                              'Is torch on?  ${snapshotData ? 'Yes!' : 'No '}',
                              style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child:
                        Text(_isBlinking ? 'Stop Blinking' : 'Start Blinking'),
                    onPressed: _toggleBlinking,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: Text('Turn off/on '),
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
