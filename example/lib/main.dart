import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bluedotPointSdk = BluedotPointSdk();
  String projectId = "3b4d73df-486a-4b34-b121-462972126c5f";
  String destinationId = "test-long-woolworth";
  final geoTriggeringChannel = const MethodChannel(BluedotPointSdk.GEO_TRIGGERING);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    geoTriggeringChannel.setMethodCallHandler((MethodCall call) async {
      var args = call.arguments;
      switch (call.method) {
        case 'onZoneInfoUpdate':
          debugPrint("On Zone Info Update: $args");
          break;
        case 'didEnterZone':
          debugPrint("Did Enter Zone: $args");
          break;
        case 'didExitZone':
          debugPrint("Did Exit Zone: $args");
          break;
        default:
          break;
      }
    });

    // if (await Permission.locationWhenInUse.request().isGranted) {
    //   debugPrint("Is granted");
    // } else {
    //   debugPrint("Is Denied");
    // }
    //
    // if (await Permission.notification.request().isGranted) {
    //   debugPrint("Notification is granted");
    // } else {
    //   debugPrint("Notification is denied");
    // }

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
    });

  }

  void initialize() async {
    await _bluedotPointSdk.initialize(projectId).then((_) {
      debugPrint("Initialized");
      updateInitialize();
    }).catchError((err) {
      debugPrint("Error $err");
    });
  }

  void startGeoTriggering() async {
    await _bluedotPointSdk
        .geoTriggeringBuilder()
        .androidNotification("Bluedot", "Bluedot", "Start Geo Triggering",
        "Testing start geo triggering", -1)
        .start()
        .then((value) {
      debugPrint("Start geo triggering");
      updateGeoTriggering();
    }).catchError((error) {
      debugPrint("Err $error");
    });
  }

  void updateInitialize() async {
    await _bluedotPointSdk.isInitialized().then((value) {
      debugPrint("is Initialized $value");
    }).catchError((error) {
      debugPrint("Error $error");
    });
  }

  void updateGeoTriggering() async {
    await _bluedotPointSdk.isGeoTriggeringRunning().then((value) {
      debugPrint("is Geo triggering running $value");
    }).catchError((error) {
      debugPrint("Error $error");
    });
  }

  void updateTempo() async {
    await _bluedotPointSdk.isTempoRunning().then((value) {
      debugPrint("is tempo running $value");
    }).catchError((error) {
      debugPrint("Error $error");
    });
  }

  void stopGeoTriggering() async {
    await _bluedotPointSdk.stopGeoTriggering().then((value) {
      debugPrint("Stopped Geo Triggering");
    }).catchError((error) {
      debugPrint("Err $error");
    });
  }

  void startTempoTracking() async {
    var uuid = Uuid().v4();
    var metadata = {"hs_orderId": uuid, "hs_Customer Name": "Long"};
    _bluedotPointSdk.setCustomEventMetaData(metadata);
    await _bluedotPointSdk
        .tempoBuilder()
        .androidNotification("Bluedot", "Bluedot", "Start Tempo Tracking",
        "Testing tempo tracking", -1)
        .start(destinationId)
        .then((value) {
      debugPrint("Started tempo tracking");
      updateTempo();
    }).catchError((error) {
      debugPrint("Error $error");
    });
  }

  void stopTempoTracking() async {
    await _bluedotPointSdk.stopTempoTracking().then((value) {
      debugPrint("Stopped Tempo Tracking");
    }).catchError((error) {
      debugPrint("Err $error");
    });
  }

  void reset() async {
    await _bluedotPointSdk.reset().then((value) {
      debugPrint("Resetted sdk");
    }).catchError((error) {
      debugPrint("Err $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
              child: Column(children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: initialize,
                  child: const Text("INITIALIZE"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: startGeoTriggering,
                  child: const Text("START GEO-TRIGGERING"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: stopGeoTriggering,
                  child: const Text("STOP GEO-TRIGGERING"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: startTempoTracking,
                  child: const Text("START TEMPO"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: stopTempoTracking,
                  child: const Text("STOP TEMPO"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: reset,
                  child: const Text("RESET"),
                )
              ]))),
    );
  }
}

class InitializeView extends StatelessWidget {
  const InitializeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const Text("Project Id"),
              // const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your project Id goes here',
                ),
              ),
              // const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MainView()));
                },
                child: const Text("INITIALIZE"),
              )
            ],
          ),
        ));
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 20),
              const Text("Install Reference"),
              const Text("Project-id"),
              const SizedBox(height: 20),
              const Text("SDK Version"),
              const Text("sdk-version"),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MainView()));
                  },
                  child: const Text("GEO-TRIGGERING")),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MainView()));
                  },
                  child: const Text("TEMPO")),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MainView()));
                  },
                  child: const Text("RESET SDK"))
            ],
          ),
        ));
  }
}
