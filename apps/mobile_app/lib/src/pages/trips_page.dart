import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_trips/trips.dart';

class TripsPage extends StatelessWidget {
  final TripsRepository tripsRepository;
  final String? tripId;

  const TripsPage({super.key, required this.tripsRepository, this.tripId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TwoGoAppBar(title: 'Viagens', showBackButton: false),
      body: HandoffTripsView(tripsRepository: tripsRepository, tripId: tripId),
    );
  }
}
