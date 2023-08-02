import 'dart:io';

import 'package:flic_button_example/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flic_button/flic_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

void main() async {
  //Last added
  // Ensure that the Flutter binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  // Register the native part of the plugin
  const platform = MethodChannel('your_channel_name');

  platform.setMethodCallHandler((call) async {
    if (call.method == 'showLocalNotification') {
      print("channel method workssss!!!!!");
      // await notificationService.showLocalNotification(
      //   id: 0,
      //   title: "Drink Water",
      //   body: "Time to drink some water!",
      //   payload: "You just took water! Huurray!",
      // );
    }
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final MethodChannel platform = MethodChannel('flic_button_channel');
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with Flic2Listener {
  //To delete
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // flic2 starts and isn't scanning
  bool _isScanning = false;
// Initialize the MethodChannel
  static const platform = const MethodChannel('your_channel_name');
  // as we discover buttons, lets add them to a map of uuid/button to show
  final Map<String, Flic2Button> _buttonsFound = {};
  // the last click to show we are hearing the button click
  Flic2ButtonClick? _lastClick;

  // the plugin manager to use while we are active
  FlicButtonPlugin? flicButtonManager;
  var notificationService;

  @override
  void initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    super.initState();
    //Execute the getButtons function when component is loaded
    // Schedule a callback after the widget is fully built
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _getButtons();
    });
    // create the FLIC 2 manager and initialize it
    _startStopFlic2();
    //Last added
    // Listen to the MethodChannel messages
    platform.setMethodCallHandler((call) async {
      print("methoddddddddddddd");
      print(call.method);
      if (call.method == 'showLocalNotification') {
        // Handle the restartApp message and send the notification
        // Send notification
        await notificationService.showLocalNotification(
          id: 0,
          title: "Drink Water",
          body: "Time to drink some water!",
          payload: "You just took water! Huurray!",
        );
      }
    });
    //Last added
  }

  void setupReceiver() {
    // Set up the BroadcastReceiver to listen for the wake-up event
    // MethodChannel('darkerwaters.flic_button.WAKE_UP_APP')
    //     .setMethodCallHandler((call) async {
    //   print("darkerwaters.flic_button.WAKE_UP_APP");
    //   print(call.method);
    //   if (call.method == 'onWakeUpApp') {
    //     // Handle the restartApp message and send the notification
    //     // Send notification
    //     await notificationService.showLocalNotification(
    //       id: 0,
    //       title: "Drink Water",
    //       body: "Time to drink some water!",
    //       payload: "You just took water! Huurray!",
    //     );
    //   }
    // });
    // Set up the BroadcastReceiver to listen for the wake-up event
    // MethodChannel('Foreground Service Channel')
    //     .setMethodCallHandler((call) async {
    //   print("Foreground Service Channer");
    //   print(call.method);
    //   if (call.method == 'onWakeUpApp') {
    //     // Handle the restartApp message and send the notification
    //     // Send notification
    //     await notificationService.showLocalNotification(
    //       id: 0,
    //       title: "Drink Water",
    //       body: "Time to drink some water!",
    //       payload: "You just took water! Huurray!",
    //     );
    //   }
    // });
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        print("paylod");
        print(payload);
      });

  void _startStopScanningForFlic2() async {
    // start scanning for new buttons
    if (!_isScanning) {
      // not scanning yet - start - flic 2 needs permissions for FINE_LOCATION
      // when on android to perform this action
      if (Platform.isAndroid && !await Permission.location.isGranted) {
        await Permission.location.request();
      }
      flicButtonManager!.scanForFlic2();
    } else {
      // are scanning - cancel that
      flicButtonManager!.cancelScanForFlic2();
    }
    // update the UI
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _startStopFlic2() {
    // start or stop the plugin (iOS doesn't stop)
    if (null == flicButtonManager) {
      // we are not started - start listening to FLIC2 buttons
      setState(() => flicButtonManager = FlicButtonPlugin(flic2listener: this));
    } else {
      // started - so stop
      flicButtonManager!.disposeFlic2().then((value) => setState(() {
            // as the flic manager is disposed, signal that it's gone
            flicButtonManager = null;
          }));
    }
  }

  void _getButtons() {
    // get all the buttons from the plugin that were there last time
    flicButtonManager!.getFlic2Buttons().then((buttons) {
      // put all of these in the list to show the buttons
      buttons.forEach((button) {
        _addButtonAndListen(button);
      });
    });
  }

  void _addButtonAndListen(Flic2Button button) {
    // as buttons are discovered via the various methods, add them
    // to the map to show them in the list on the view
    setState(() {
      // add the button to the map
      _buttonsFound[button.uuid] = button;
      print("buttons Found 22222");
      print(_buttonsFound);
      print(_buttonsFound.toString());
      print(_buttonsFound[button.uuid]?.serialNo);
      // and listen to the button for clicks and things
      flicButtonManager!.listenToFlic2Button(button.uuid);
    });
  }

  void _connectDisconnectButton(Flic2Button button) {
    // if disconnected, connect, else disconnect the button
    if (button.connectionState == Flic2ButtonConnectionState.disconnected) {
      flicButtonManager!.connectButton(button.uuid);
      print("buttons Found 333333333");
      print(_buttonsFound);
      print(_buttonsFound.toString());
      print(_buttonsFound[button.uuid]?.serialNo);
    } else {
      flicButtonManager!.disconnectButton(button.uuid);
    }
  }

  void _forgetButton(Flic2Button button) {
    // forget the passed button so it disappears and we can search again
    flicButtonManager!.forgetButton(button.uuid).then((value) {
      if (value != null && value) {
        // button was removed
        setState(() {
          // remove from the list
          _buttonsFound.remove(button.uuid);
        });
      }
    });
  }

  //New stuff
  //Last added
  void showLocalNotification(BuildContext context) async {
    print("Gets in the showLocalNotification inside main.dart");
    try {
      await platform.invokeMethod('showLocalNotification', null);
    } on PlatformException catch (e) {
      print("Failed to invoke method: ${e.message}");
    }
  }
  //Last added

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Flic Button Plugin Example'),
          ),
          body: FutureBuilder(
            future: flicButtonManager != null
                ? flicButtonManager!.invokation
                : null,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // are not initialized yet, wait a sec - should be very quick!
                return Center(
                  child: ElevatedButton(
                    onPressed: () => _startStopFlic2(),
                    child: Text('Start and initialize Flic2'),
                  ),
                );
              } else {
                // we have completed the init call, we can perform scanning etc
                return Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Flic2 is initialized',
                      style: TextStyle(fontSize: 20),
                    ),
                    ElevatedButton(
                      onPressed: () => _startStopFlic2(),
                      child: Text('Stop Flic2'),
                    ),
                    if (flicButtonManager != null)
                      Row(
                        // if we are started then show the controls to get flic2 and scan for flic2
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () => _getButtons(),
                              child: Text('Get Buttons')),
                          ElevatedButton(
                              onPressed: () => _startStopScanningForFlic2(),
                              child: Text(_isScanning
                                  ? 'Stop Scanning'
                                  : 'Scan for buttons')),
                        ],
                      ),
                    if (null != _lastClick)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'FLIC2 @${_lastClick!.button.buttonAddr}\nclicked ${_lastClick!.timestamp - _lastClick!.button.readyTimestamp}ms from ready state\n'
                          '${_lastClick!.isSingleClick ? 'single click\n' : ''}'
                          '${_lastClick!.isDoubleClick ? 'double click\n' : ''}'
                          '${_lastClick!.isHold ? 'hold\n' : ''}',
                        ),
                      ),
                    if (_isScanning)
                      Text(
                          'Hold down your flic2 button so we can find it now we are scanning...'),
                    // and show the list of buttons we have found at this point
                    Expanded(
                      child: ListView(
                          children: _buttonsFound.values
                              .map((e) => ListTile(
                                    key: ValueKey(e.uuid),
                                    leading:
                                        Icon(Icons.radio_button_on, size: 48),
                                    title: Text('FLIC2 @${e.buttonAddr}'),
                                    subtitle: Column(
                                      children: [
                                        Text('${e.uuid}\n'
                                            'name: ${e.name}\n'
                                            'batt: ${e.battVoltage}V (${e.battPercentage}%)\n'
                                            'serial: ${e.serialNo}\n'
                                            'pressed: ${e.pressCount}\n'),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _connectDisconnectButton(e),
                                              child: Text(e.connectionState ==
                                                      Flic2ButtonConnectionState
                                                          .disconnected
                                                  ? 'connect'
                                                  : 'disconnect'),
                                            ),
                                            SizedBox(width: 20),
                                            ElevatedButton(
                                              onPressed: () => _forgetButton(e),
                                              child: Text('forget'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList()),
                    ),
                  ],
                );
              }
            },
          )),
    );
  }

  @override
  void onButtonClicked(Flic2ButtonClick buttonClick) async {
    // callback from the plugin that someone just clicked a button
    print('button ${buttonClick.button.uuid} clicked');
    // Send notification
    // await notificationService.showLocalNotification(
    //     id: 0,
    //     title: "Drink Water",
    //     body: "Time to drink some water!",
    //     payload: "You just took water! Huurray!");
    // setState(() {
    //   _lastClick = buttonClick;
    // });
  }

  @override
  void onButtonConnected() {
    super.onButtonConnected();
    print("buttonConnected 223232323233232323");
    print("buttonsFound 23332323232323");
    print(_buttonsFound.toString());

    // this changes the state of our list of buttons, set state for this
    setState(() {
      print('button connected');
    });
  }

  @override
  void onButtonDiscovered(String buttonAddress) {
    super.onButtonDiscovered(buttonAddress);
    // this is an address which we should be able to resolve to an actual button right away
    print('button @$buttonAddress discovered');
    // but we could in theory wait for it to be connected and discovered because that will happen too
    flicButtonManager!.getFlic2ButtonByAddress(buttonAddress).then((button) {
      if (button != null) {
        print(
            'button found with address $buttonAddress resolved to actual button data ${button.uuid}');
        // which we can add to the list to show right away
        _addButtonAndListen(button);
      }
    });
  }

  @override
  void onButtonFound(Flic2Button button) {
    super.onButtonFound(button);
    // we have found a new button, add to the list to show
    print('button ${button.uuid} found');
    // and add to the list to show
    _addButtonAndListen(button);
  }

  @override
  void onFlic2Error(String error) {
    super.onFlic2Error(error);
    // something went wrong somewhere, provide feedback maybe, or did you code something in the wrong order?
    print('ERROR: $error');
  }

  @override
  void onPairedButtonDiscovered(Flic2Button button) {
    super.onPairedButtonDiscovered(button);
    print('paired button ${button.uuid} discovered');
    // discovered something already paired (getButtons will return these but maybe you didn't bother and
    // just went right into a scan)
    _addButtonAndListen(button);
  }

  @override
  void onScanCompleted() {
    super.onScanCompleted();
    // scan completed, update the state of our view
    setState(() {
      _isScanning = false;
    });
  }

  @override
  void onScanStarted() {
    super.onScanStarted();
    // scan started, update the state of our view
    setState(() {
      _isScanning = true;
    });
  }
}
