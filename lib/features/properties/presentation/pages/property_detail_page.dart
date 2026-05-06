import 'package:flutter/material.dart';

/// Property detail screen shell.
class PropertyDetailPage extends StatelessWidget {
  const PropertyDetailPage({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Details')),
      body: Center(child: Text('Property $propertyId — coming next session')),
    );
  }
}
