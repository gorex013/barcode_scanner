import 'dart:convert';
import 'dart:io';

import 'package:barcode_scanner/product_registration/fast_product_dialog.dart';
import 'package:barcode_scanner/product_registration/product_page.dart';
import 'package:barcode_scanner/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'export_warehouse.dart';
import 'home_page.dart';
import 'import_warehouse.dart';

void main() {
  runApp(App('192.168.88.227', '8000'));
}

class App extends StatelessWidget {
  final host;
  final port;

  readKey() async {
    var apiKey;
    var dir = await getApplicationDocumentsDirectory();
    var apiFile = File('${dir.path}/warehouse.key');
    if (await apiFile.exists()) {
      apiKey = utf8.decode(await apiFile.readAsBytes());
    } else
      apiKey = null;
    return apiKey;
  }

  final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: MaterialColor(
      0xFF6AA84F,
      {
        50: Color(0xFFCEE2C5),
        100: Color(0xFFC2DBB7),
        200: Color(0xFFB3D2A5),
        300: Color(0xFFA0C78E),
        400: Color(0xFF88B972),
        500: Color(0xFF6AA84F),
        600: Color(0xFF55863F),
        700: Color(0xFF446B32),
        800: Color(0xFF365628),
        900: Color(0xFF2B4520),
      },
    ),
    visualDensity: VisualDensity.comfortable,
    accentColorBrightness: Brightness.dark,
    accentColor: Color(0xFF6B3244),
  );

  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: MaterialColor(0xFF446B32, {
      50: Color(0xFFC1CFBC),
      100: Color(0xFFB2C3AB),
      200: Color(0xFF9FB496),
      300: Color(0xFF87A17C),
      400: Color(0xFF69895B),
      500: Color(0xFF446B32),
      600: Color(0xFF365628),
      700: Color(0xFF2B4520),
      800: Color(0xFF22371A),
      900: Color(0xFF1B2C15),
    }),
    visualDensity: VisualDensity.comfortable,
    accentColorBrightness: Brightness.light,
    accentColor: Color(0xFFB4969F),
  );

  App(
    this.host,
    this.port, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var apiKey;
        return MaterialApp(
          title: 'Manager depozit',
          initialRoute: '/',
          routes: {
            '/': (context) => HomePage(
                  host: host,
                  port: port,
                ),
            '/register-product': (context) =>
                RegisterProduct(host: host, port: port),
            '/fast-register-product': (context) => FastProductDialog(
                  host: host,
                  port: port,
                  apiKey: apiKey,
                ),
            '/import-warehouse': (context) =>
                ImportWarehouse(host: host, port: port),
            '/export-warehouse': (context) =>
                ExportWarehouse(host: host, port: port),
            '/settings': (context) => SettingsPage(host: host, port: port)
          },
          theme: lightTheme,
          darkTheme: darkTheme,
        );
  }
}
