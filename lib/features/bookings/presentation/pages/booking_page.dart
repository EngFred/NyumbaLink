import 'package:flutter/material.dart';

/// Booking submission screen shell.
class BookingPage extends StatelessWidget {
  const BookingPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    this.hostelRoomId,
    this.roomNumber,
  });

  final String propertyId;
  final String propertyTitle;
  final String? hostelRoomId;
  final String? roomNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Property')),
      body: const Center(child: Text('Booking form — coming next session')),
    );
  }
}
