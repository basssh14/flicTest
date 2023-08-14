import 'package:flutter/material.dart';
import 'package:flic_button/flic_button.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class CounterProvider extends ChangeNotifier with Flic2Listener {
  int _counter = 0;
  FlicButtonPlugin? _flicButtonManager = null;
  Map<String, Flic2Button> _buttonsFound = {};
  bool _isScanning = false;
  Flic2ButtonClick? _lastClick;
  int get counter => _counter;
  FlicButtonPlugin? get flicButtonManager => _flicButtonManager;
  Map<String, Flic2Button> get buttonsFound => _buttonsFound;
  bool get isScanning => _isScanning;
  Flic2ButtonClick? get lastClick => _lastClick;

  CounterProvider() {
    // Call startStopFlic2 automatically when the provider is first loaded
    startStopFlic2();
    // Wait for a short delay before calling getButtons
    Future.delayed(Duration(milliseconds: 1000), () {
      getButtons();
    });
  }

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void startStopScanningForFlic2() async {
    // start scanning for new buttons
    if (!_isScanning) {
      // not scanning yet - start - flic 2 needs permissions for FINE_LOCATION
      // when on android to perform this action
      if (Platform.isAndroid && !await Permission.location.isGranted) {
        await Permission.location.request();
      }
      _flicButtonManager!.scanForFlic2();
    } else {
      // are scanning - cancel that
      _flicButtonManager!.cancelScanForFlic2();
    }
    // update the UI
    _isScanning = !_isScanning;
    notifyListeners();
  }

  void startStopFlic2() {
    //start or stop the plugin (iOS doesn't stop)
    if (null == _flicButtonManager) {
      // we are not started - start listening to FLIC2 buttons
      _flicButtonManager = FlicButtonPlugin(flic2listener: this);
    } else {
      // started - so stop
      _flicButtonManager!.disposeFlic2().then((value) => {
            // as the flic manager is disposed, signal that it's gone
            _flicButtonManager = null
          });
    }
    notifyListeners();
  }

  void getButtons() {
    // get all the buttons from the plugin that were there last time
    _flicButtonManager!.getFlic2Buttons().then((buttons) {
      // put all of these in the list to show the buttons
      buttons.forEach((button) {
        addButtonAndListen(button);
      });
      notifyListeners();
    });
  }

  void addButtonAndListen(Flic2Button button) {
    // add the button to the map
    _buttonsFound[button.uuid] = button;
    // and listen to the button for clicks and things
    _flicButtonManager!.listenToFlic2Button(button.uuid);
    notifyListeners();
  }

  void connectDisconnectButton(Flic2Button button) {
    // if disconnected, connect, else disconnect the button
    if (button.connectionState == Flic2ButtonConnectionState.disconnected) {
      _flicButtonManager!.connectButton(button.uuid);
      getButtons();
    } else {
      _flicButtonManager!.disconnectButton(button.uuid);
      getButtons();
    }
    notifyListeners();
  }

  void forgetButton(Flic2Button button) {
    // forget the passed button so it disappears and we can search again
    _flicButtonManager!.forgetButton(button.uuid).then((value) {
      if (value != null && value) {
        _buttonsFound.remove(button.uuid);
      }
      getButtons();
      notifyListeners();
    });
  }

  //The callbacks to execute specific code based on some flic actions....
  @override
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    _lastClick = buttonClick;
    notifyListeners();
  }

  @override
  void onButtonConnected() {
    getButtons();
    notifyListeners();
  }

  @override
  void onButtonDiscovered(String buttonAddress) {
    super.onButtonDiscovered(buttonAddress);
    // this is an address which we should be able to resolve to an actual button right away
    // but we could in theory wait for it to be connected and discovered because that will happen too
    _flicButtonManager!.getFlic2ButtonByAddress(buttonAddress).then((button) {
      if (button != null) {
        // which we can add to the list to show right away
        addButtonAndListen(button);
      }
    });
  }

  @override
  void onButtonFound(Flic2Button button) {
    super.onButtonFound(button);
    // we have found a new button, add to the list to show
    // and add to the list to show
    addButtonAndListen(button);
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
    // discovered something already paired (getButtons will return these but maybe you didn't bother and
    // just went right into a scan)
    addButtonAndListen(button);
  }

  @override
  void onScanCompleted() {
    super.onScanCompleted();
    // scan completed, update the state of our view

    _isScanning = false;
  }

  @override
  void onScanStarted() {
    super.onScanStarted();
    // scan started, update the state of our view

    _isScanning = true;
  }
}
