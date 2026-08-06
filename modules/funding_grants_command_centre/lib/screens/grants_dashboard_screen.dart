import 'package:flutter/material.dart';

import '../models/grant_record.dart';
import '../repositories/grant_repository.dart';
import '../widgets/grant_card.dart';
import '../widgets/grant_totals_header.dart';

class GrantsDashboardScreen extends StatefulWidget {
  final GrantRepository repository;

  const GrantsDashboardScreen({
    super.key,
    required this.repository,
  });

  @override
  State<GrantsDashboardScreen> createState() => _GrantsDashboardScreenState();
}

class _GrantsDashboardScreenState extends State<GrantsDashboardScreen> {
  late Future<List<GrantRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.loadGrants();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GrantRecord>>(
      future: _future,
      builder: (context, snapshot) {
        final grants = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Funding & Grants Command Centre'),
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    GrantTotalsHeader(grants: grants),
                    Expanded(
                      child: ListView.builder(
                        itemCount: grants.length,
                        itemBuilder: (context, index) {
                          return GrantCard(grant: grants[index]);
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
