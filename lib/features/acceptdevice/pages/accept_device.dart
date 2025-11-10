import 'package:flutter/material.dart';

class AcceptDeviceScreen extends StatefulWidget {
  const AcceptDeviceScreen({super.key});

  @override
  State<AcceptDeviceScreen> createState() => _AcceptDeviceScreenState();
}

class _AcceptDeviceScreenState extends State<AcceptDeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(child: ElevatedButton(onPressed: (){}, child: Text('hola')),);
  }
}