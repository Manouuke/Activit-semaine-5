import 'package:flutter/material.dart';

import 'views/redacteur_interface.dart';



void main() {
  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magazine Infos - Gestion des rédacteurs',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      home: const RedacteurInterface(),
    );
  }
}
