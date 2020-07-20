import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Barcode scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraView cameraView;
  var exitCameraButton;
  var addInventoryButton;
  var historyView;
  var showBottomAppBar;

  @override
  void initState() {
    super.initState();
    showBottomAppBar = true;
    historyView = ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(
              title: Text("${index + 1}. Item$index"),
            ));
  }

  @override
  Widget build(BuildContext context) {
    addInventoryButton = RaisedButton(
      padding: EdgeInsets.symmetric(horizontal: 100),
      onPressed: () {
        setState(() {
          showBottomAppBar = false;
          cameraView = CameraView();
          exitCameraButton = IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                showBottomAppBar = true;
                exitCameraButton = null;
                cameraView = null;
              });
            },
          );
        });
      },
      child: Text("Inventariere"),
      color: Theme.of(context).primaryColorDark,
    );
    return Scaffold(
      appBar: AppBar(
        leading: exitCameraButton,
        title: Text(widget.title),
      ),
      body: (cameraView == null) ? historyView : cameraView,
      bottomNavigationBar: (showBottomAppBar) ? addInventoryButton : null,
    );
  }
}

class CameraView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CameraView();
  }
}

class _CameraView extends State<CameraView> {
  CameraController cameraController;
  Future<void> _initializeControllerFuture;
  var isCameraReady = false;
  var showCapturedPhoto = false;
  var imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    cameraController = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = cameraController.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeControllerFuture = cameraController?.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Transform.scale(
              scale: cameraController.value.aspectRatio / deviceRatio,
              child: Center(
                child: AspectRatio(
                  aspectRatio: cameraController.value.aspectRatio,
                  child: CameraPreview(cameraController), //cameraPreview
                ),
              ));
        } else {
          return Center(
              child:
                  CircularProgressIndicator()); // Otherwise, display a loading indicator.
        }
      },
    );
  }
}
