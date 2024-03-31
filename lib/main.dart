import 'package:betgps/app/app_module.dart';
import 'package:betgps/app/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() async {
  FlutterError.onError = (details) {
    print("ERR " + details.toString());
  };
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
