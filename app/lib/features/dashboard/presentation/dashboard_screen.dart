import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('控制中枢')),
      body: const Center(child: Text('家庭中枢尚未接入')),
    );
  }
}
