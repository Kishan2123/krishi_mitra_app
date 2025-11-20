import 'package:flutter/material.dart';
// TODO: fix this import based on where your IndexScreen file actually is.
import 'screens/index_screen.dart'; 

class KrishiMitraApp extends StatelessWidget {
  const KrishiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krishi Mitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      home: const IndexScreen(), // first screen of your app
    );
  }
}
