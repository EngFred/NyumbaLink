import 'package:flutter/material.dart';

/// Hostel rooms listing screen shell.
class HostelRoomsPage extends StatelessWidget {
  const HostelRoomsPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  final String propertyId;
  final String propertyTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(propertyTitle)),
      body: const Center(child: Text('Hostel rooms — coming next session')),
    );
  }
}
