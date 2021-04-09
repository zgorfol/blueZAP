import 'package:bluezap/bluetoothProvider.dart';
import 'package:bluezap/bluetoothSetup.dart';
import 'package:bluezap/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:provider/provider.dart';
//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:bluezap/theraphy.dart';
//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//import 'bluetoothProvider.dart';
import 'searchonweb.dart';
//import 'package:bluezap/main.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';

class TerminalApp extends StatefulWidget {
  const TerminalApp({Key key}) : super(key: key);
  @override
  _TerminalAppState createState() => _TerminalAppState();
}

class _TerminalAppState extends State with WidgetsBindingObserver {
  AppLifecycleState state;

  final blState = locator<BluetoothProvider>();

  /*
  bool _isConnected = false;
  String lsearchStr;
  String lsearchURL;
  Theraphy ltheraphy;
  BluetoothDevice ldevice;
  */
  final List<String> _termStr = new List();

  //BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  //String _snackMessage = "";
  final ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController myController;

  @override
  void initState() {
    super.initState();
    _termStr.clear();
    myController = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    blState.onChange.listen((e) => {
          addTotermStr(e.eventData),
        });
    blState.onSnack.listen((e) => {
          if (e.eventData != "")
            {showSnack(e.eventData)}
          else
            {
              if (_scaffoldKey.currentState != null)
                {_scaffoldKey.currentState.removeCurrentSnackBar()}
            }
        });
  }

  void showSnack(
    String message, {
    Duration duration: const Duration(seconds: 1),
  }) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  //bool blStateInit = true;
/*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    
    final blueState = Provider.of<BluetoothProvider>(context);

    if (blStateInit) {
      //blState = blueState;
      blState.onChange.listen((e) => {
            addTotermStr(e.eventData),
          });
      blStateInit = false;
    }

    
    _isConnected = blState.isConnected;
    lsearchStr = blState.lsearchStr;
    lsearchURL = blState.lsearchURL;
    ltheraphy = blState.ltheraphy;
    ldevice = blState.device;

    _bluetoothState = blState.bluetoothState;
    
    _snackMessage = blState.snackMessage;
    
    String _snackMessage = blState.snackMessage;
    if (_snackMessage != "") {
      showSnack(_snackMessage);
    } else {
      if (_scaffoldKey.currentState != null) {
        _scaffoldKey.currentState.removeCurrentSnackBar();
      }
    }
  }

  void showSnack(
    String message, {
    Duration duration: const Duration(seconds: 1),
  }) {
    // WidgetsBinding.instance.addPostFrameCallback(
    //(_) =>
    _scaffoldKey.currentState
        //Scaffold.of(context)
        //..removeCurrentSnackBar()
        .showSnackBar(
      SnackBar(
        content: Text(message),
        //duration: duration,
      ),
      //    ..removeCurrentSnackBar(),
    );
  }
*/
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    myController.dispose();
    _scrollController.dispose();
    _termStr.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    super.didChangeAppLifecycleState(state);
    state = appLifecycleState;
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
    }
  }

  void addTotermStr(String addStr) {
    setState(() {
      _termStr.isEmpty
          // || _termStr.last.substring(_termStr.last.length - 1) == '\n'
          ? _termStr.add(addStr)
          : _termStr.last += addStr;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 1000,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  Widget keyboardDismisser({BuildContext context, Widget child}) {
    final gesture = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: child,
    );
    return gesture;
  }

  Widget textSearchSend() {
    return TextField(
      autofocus: false,
      controller: myController,
    );
  }

  Widget terminalBody() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Visibility(
            visible: blState.progressBar,
            child: LinearProgressIndicator(
              backgroundColor: Colors.yellow,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _termStr.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Text(_termStr[index]);
                  }),
            ),
          ),
          Column(
            children: [
              Row(
                children: <Widget>[
                  Text('Search / Send :  '),
                  Expanded(
                    child: textSearchSend(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget drawerOnly() {
    return Drawer(
        child: ListView(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Container(
              height: 142,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/launcher/icon.png",
              )),
        ),
        ListTile(
          title: Text("Terminal"),
          onTap: () {
            setState(() {
              Navigator.of(context).pop();
              terminalBody();
            });
          },
        ),
        ListTile(
          title: Text("Bluetooth setup"),
          onTap: () {
            if (blState.isConnected) {
              blState.disconnect();
            }
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => BluetoothSetup(),
                    ),
                    // _route
                    ModalRoute.withName('/'))
                .then((results) => {
                      //if (results != null && results.containsKey('device'))
                      //  {
                      // blState.device = results['device'],
                      //  }
                    });
          },
        ),
      ],
    ));
  }

  Future downloadScript() async {
    addTotermStr(blState.ltheraphy.fieldscript);
    await blState.sendMessageToBluetooth('mem\r\n@\r\n').then((valu1) => {
          Future.delayed(Duration(milliseconds: 1000)).then((value) => {
                blState
                    .sendMessageToBluetooth(
                        //    'mem @\r\n' + blState.ltheraphy.fieldscript)
                        'mem\r\n' + blState.ltheraphy.fieldscript + '\r\n@\r\n')
                    .then(
                      (value2) => {
                        showSnack('Userprogram stored!'),
                      },
                    ),
              }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return this.keyboardDismisser(
      context: context,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text("blueZAP"), actions: <Widget>[
          ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
            FlatButton.icon(
              icon: Icon(
                Icons.restore_from_trash,
                color: Theme.of(context).iconTheme.color,
              ),
              label: Text(
                "",
                style: TextStyle(
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              onPressed: () {
                setState(() {
                  _termStr.clear();
                });
              },
            ),
            FlatButton.icon(
              icon: blState.isConnected
                  ? Icon(
                      Icons.bluetooth_connected,
                      color: Theme.of(context).indicatorColor,
                    )
                  : Icon(
                      Icons.bluetooth_disabled,
                      color: Theme.of(context).errorColor,
                    ),
              label: Text(
                "",
                style: TextStyle(
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              onPressed: () {
                setState(() {
                  try {
                    blState.progressBar = true;
                    blState.isConnected
                        ? blState.disconnect().then((_) {
                            setState(() {
                              blState.progressBar = false;
                            });
                          })
                        : blState.connect().then((_) {
                            setState(() {
                              blState.progressBar = false;
                            });
                          });
                  } catch (e) {
                    print(e);
                  }
                });
              },
            ),
          ]),
        ]),
        drawer: drawerOnly(),
        body: terminalBody(),
        persistentFooterButtons: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(
                    Icons.download_sharp,
                  ),
                  label: Text(
                    "",
                  ),
                  onPressed: () {
                    try {
                      if (blState.ltheraphy.fieldscript != null) {
                        blState.isConnected
                            ? downloadScript()
                            : showSnack('Bluetooth is disconected!');
                      }
                    } catch (e) {
                      showSnack('Search a theraphy first!');
                    }
                  },
                ),
                FlatButton.icon(
                  icon: Icon(Icons.search_sharp),
                  label: Text(
                    "",
                  ),
                  onPressed: () {
                    _searchTheraphy(context);
                  },
                ),
                FlatButton.icon(
                  icon: Icon(Icons.folder_open_sharp),
                  label: Text(
                    "",
                  ),
                  onPressed: () {
                    _searchFolder(context);
                  },
                ),
                FlatButton.icon(
                  icon: Icon(Icons.keyboard_return_rounded),
                  label: Text(
                    "",
                  ),
                  onPressed: () {
                    blState.searchStr = myController.text;
                    blState.isConnected
                        ? blState.sendMessageToBluetooth(myController.text)
                        : showSnack('Bluetooth is disconected!');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _searchFolder(BuildContext context) async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        //allowed extension to choose
      );

      if (result != null) {
        //if there is selected file
        //
        File selectedFile = File(result.files.single.path);
        String fileTheraphy = await selectedFile.readAsString();
        blState.theraphy = Theraphy(fieldscript: fileTheraphy);
        addTotermStr(fileTheraphy);
      }
    } catch (e) {
      showSnack('File open execption.');
    }
  }

  Future _searchTheraphy(BuildContext context) async {
    blState.searchStr = myController.text;
    try {
      final Theraphy chooseTheraphy = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SearchOnWeb(blState.lsearchURL + myController.text),
        ),
      );
      if (chooseTheraphy != null) {
        blState.theraphy = chooseTheraphy;
        addTotermStr(chooseTheraphy.fieldscript);
      }
    } catch (e) {
      showSnack('Web theraphy exception.');
    }
  }
}
