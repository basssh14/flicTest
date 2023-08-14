import 'package:flic_button_example/copy.dart';
import 'package:flic_button_example/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flic_button/flic_button.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'flic_provider.dart';

void main() async {
  // Ensure that the Flutter binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  // Note: Dont remove this, this prevents a notification sended when app starts
  const platform = MethodChannel('your_channel_name');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'showLocalNotification') {
      //This shouldn't do anything, it just prevents the other method channel
      // to be executed when the app starts....
      print("channel method workssss!!!!!");
    }
  });

  runApp(ChangeNotifierProvider(
      create: (context) => CounterProvider(), child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: FlicButtonPage());
  }
}

class FlicButtonPage extends StatefulWidget {
  @override
  _FlicButtonPageState createState() => _FlicButtonPageState();
}

class _FlicButtonPageState extends State<FlicButtonPage> {
  //To delete
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
// Initialize the MethodChannel
  static const platform = const MethodChannel('your_channel_name');
  // the plugin manager to use while we are active
  // Initialize the FlicButtonManagerSingleton
  var counterProvider;
  var flicButtonManager;
  void initializeProvider() {
    counterProvider = Provider.of<CounterProvider>(context, listen: false);
    flicButtonManager = counterProvider.flicButtonManager;
  }

  var notificationService;

  @override
  void initState() {
    // create the FLIC 2 manager and initialize it
    initializeProvider();
    notificationService = NotificationService();
    notificationService.initializePlatformNotifications();
    super.initState();
    // Listen to the MethodChannel messages
    platform.setMethodCallHandler((call) async {
      print("methoddddddddddddd3434343434433");
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Flic Button Plugin Example'),
        ),
        body: FutureBuilder(
          future: model.flicButtonManager?.invokation,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              // are not initialized yet, wait a sec - should be very quick!
              return Center(
                child: ElevatedButton(
                  onPressed: () => model.startStopFlic2(),
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
                    onPressed: () => model.startStopFlic2(),
                    child: Text('Stop Flic2'),
                  ),
                  if (model.flicButtonManager != null)
                    Row(
                      // if we are started then show the controls to get flic2 and scan for flic2
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () => model.getButtons(),
                            child: Text('Get Buttons')),
                        ElevatedButton(
                            onPressed: () => model.startStopScanningForFlic2(),
                            child: Text(model.isScanning
                                ? 'Stop Scanning'
                                : 'Scan for buttons')),
                      ],
                    ),
                  if (null != model.lastClick)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'FLIC2 @${model.lastClick!.button.buttonAddr}\nclicked ${model.lastClick!.timestamp - model.lastClick!.button.readyTimestamp}ms from ready state\n'
                        '${model.lastClick!.isSingleClick ? 'single click\n' : ''}'
                        '${model.lastClick!.isDoubleClick ? 'double click\n' : ''}'
                        '${model.lastClick!.isHold ? 'hold\n' : ''}',
                      ),
                    ),
                  if (model.isScanning)
                    Text(
                        'Hold down your flic2 button so we can find it now we are scanning...'),
                  // and show the list of buttons we have found at this point
                  Expanded(
                      child: ListView.builder(
                    itemCount: model.buttonsFound.length,
                    itemBuilder: (context, index) {
                      final e = model.buttonsFound.values.toList()[index];
                      return ListTile(
                        key: ValueKey(e.uuid),
                        leading: Icon(Icons.radio_button_on, size: 48),
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
                                      model.connectDisconnectButton(e),
                                  child: Text(e.connectionState ==
                                          Flic2ButtonConnectionState
                                              .disconnected
                                      ? 'connect'
                                      : 'disconnect'),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () => model.forgetButton(e),
                                  child: Text('forget'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )),
                ],
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Copy()),
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.navigation),
        ),
      ),
    );
  }
}
