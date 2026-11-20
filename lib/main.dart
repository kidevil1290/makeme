import 'package:flutter/material.dart';

import 'app.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  // Needed before using the device storage ahead of runApp
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  // The app only starts once the data is here
  final data = await storage.load();

  runApp(MakeMeApp(storage: storage, data: data));
}
