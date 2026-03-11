import 'package:flutter/material.dart';
import 'package:landlord_management_app/models/unit_lease.dart';
import 'package:landlord_management_app/repositories/unit_lease_repository.dart';
import 'package:landlord_management_app/screens/unit_detail_screen.dart';
import 'package:landlord_management_app/utils/unit_lease_formatters.dart';

typedef UnitLeaseFilter = List<UnitLease> Function(
  UnitLeaseRepository repository,
);

class UnitsListScreen extends StatefulWidget {
  const UnitsListScreen({
    super.key,
    required this.repository,
    this.title = '전체 호실',
    this.filter,
    this.emptyMessage = '표시할 호실이 없습니다.',
  });

  final UnitLeaseRepository repository;
  final String title;
  final UnitLeaseFilter? filter;
  final String emptyMessage;

  @override
  State<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends State<UnitsListScreen> {
  @override
  Widget build(BuildContext context) {
    final units = widget.filter?.call(widget.repository) ??
        widget.repository.getLeasesSortedByLeaseEnd();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
      body: units.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.emptyMessage,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () async {
                      final result =
                          await Navigator.of(context).push<UnitDetailResult>(
                        MaterialPageRoute<UnitDetailResult>(
                          builder: (_) => UnitDetailScreen(unit: unit),
                        ),
                      );
                      if (result == null) return;
                      setState(() {
                        if (result.deleted) {
                          widget.repository.deleteLeaseById(unit.id);
                          return;
                        }
                        if (result.unit == null) return;
                        widget.repository.updateLease(result.unit!);
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      unit.unitNo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${unit.tenantName} · ${leaseStatusText(unit.status)} · ${formatLeaseDate(unit.leaseEnd)} 만료',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    trailing: Text(
                      formatLeaseCountdown(unit.daysRemainingUntilLeaseEnd()),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
