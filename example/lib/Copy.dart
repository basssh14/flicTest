import 'package:flic_button/flic_button.dart';
import 'package:flic_button_example/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Test.dart';

class Copy extends StatefulWidget {
  // final CounterProvider counterProvider;
  const Copy({Key? key}) : super(key: key);
  @override
  State<Copy> createState() => _CopyState();
}

class _CopyState extends State<Copy> {
  // Initialize the FlicButtonManagerSingleton
  // var counterProvider;
  // var flicButtonManager;
  // void initializeProvider() {
  //   counterProvider = Provider.of<CounterProvider>(context, listen: false);
  //   flicButtonManager = counterProvider.flicButtonManager;
  // }
  //
  // @override
  // void initState() {
  //   initializeProvider();
  //   super.initState();
  // }

  //Last added
  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Flic Button Plugin Example 22'),
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
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.navigation),
        ),
      ),
    );
  }
}
