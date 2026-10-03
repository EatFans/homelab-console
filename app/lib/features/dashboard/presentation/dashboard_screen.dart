import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 140),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF20312F),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.space_dashboard_rounded,
                  color: Color(0xFF9AE4D4),
                  size: 42,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '总览页面',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '这里会展示家庭状态和常用控制。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9BA8B7), fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
